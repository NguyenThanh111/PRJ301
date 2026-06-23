package Models_DAO;

import Models.PaymentTransactionDTO;
import Models.UserSubscriptionDTO;
import Utils.DbUtils;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class PaymentTransactionDAO {

    public void create(PaymentTransactionDTO payment) throws SQLException {
        String sql = "INSERT INTO PaymentTransaction "
                + "(txn_ref, user_id, plan_code, plan_name, duration_days, amount, currency, "
                + "order_info, status, client_ip) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'PENDING', ?)";
        try (Connection connection = connection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, payment.getTxnRef());
            statement.setInt(2, payment.getUserId());
            statement.setString(3, payment.getPlanCode());
            statement.setString(4, payment.getPlanName());
            statement.setInt(5, payment.getDurationDays());
            statement.setLong(6, payment.getAmount());
            statement.setString(7, payment.getCurrency());
            statement.setString(8, payment.getOrderInfo());
            statement.setString(9, payment.getClientIp());
            statement.executeUpdate();
        }
    }

    public PaymentTransactionDTO findByTxnRef(String txnRef) throws SQLException {
        if (!hasText(txnRef)) return null;
        String sql = "SELECT payment_id, txn_ref, user_id, plan_code, plan_name, duration_days, amount, "
                + "currency, order_info, status, bank_code, card_type, vnp_transaction_no, response_code, "
                + "transaction_status, pay_date, created_at, updated_at, confirmed_at "
                + "FROM PaymentTransaction WHERE txn_ref = ?";
        try (Connection connection = connection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, txnRef);
            try (ResultSet result = statement.executeQuery()) {
                return result.next() ? map(result) : null;
            }
        }
    }

    public List<PaymentTransactionDTO> findRecentByUser(int userId) throws SQLException {
        String sql = "SELECT TOP 20 payment_id, txn_ref, user_id, plan_code, plan_name, duration_days, amount, "
                + "currency, order_info, status, bank_code, card_type, vnp_transaction_no, response_code, "
                + "transaction_status, pay_date, created_at, updated_at, confirmed_at "
                + "FROM PaymentTransaction WHERE user_id = ? ORDER BY payment_id DESC";
        List<PaymentTransactionDTO> payments = new ArrayList<PaymentTransactionDTO>();
        try (Connection connection = connection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) payments.add(map(result));
            }
        }
        return payments;
    }

    public UserSubscriptionDTO findSubscription(int userId) throws SQLException {
        String sql = "SELECT user_id, plan_code, plan_name, status, started_at, expires_at "
                + "FROM UserSubscription WHERE user_id = ?";
        try (Connection connection = connection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            try (ResultSet result = statement.executeQuery()) {
                if (!result.next()) return null;
                UserSubscriptionDTO subscription = new UserSubscriptionDTO();
                subscription.setUserId(result.getInt("user_id"));
                subscription.setPlanCode(result.getString("plan_code"));
                subscription.setPlanName(result.getString("plan_name"));
                subscription.setStatus(result.getString("status"));
                subscription.setStartedAt(result.getTimestamp("started_at"));
                subscription.setExpiresAt(result.getTimestamp("expires_at"));
                return subscription;
            }
        }
    }

    /**
     * Records one signed gateway result. The conditional status update makes Return URL and IPN safe
     * when they arrive concurrently or are retried by VNPAY.
     *
     * @return true only when this call changed a PENDING payment.
     */
    public boolean confirm(String txnRef, boolean successful, String finalStatus,
            String responseCode, String transactionStatus, String transactionNo,
            String bankCode, String cardType, Date payDate, String gatewayData) throws SQLException {
        String update = "UPDATE PaymentTransaction SET status = ?, response_code = ?, transaction_status = ?, "
                + "vnp_transaction_no = ?, bank_code = ?, card_type = ?, pay_date = ?, gateway_data = ?, "
                + "confirmed_at = GETDATE(), updated_at = GETDATE() WHERE txn_ref = ? AND status = 'PENDING'";

        Connection connection = null;
        try {
            connection = connection();
            connection.setAutoCommit(false);
            int changed;
            try (PreparedStatement statement = connection.prepareStatement(update)) {
                statement.setString(1, finalStatus);
                statement.setString(2, responseCode);
                statement.setString(3, transactionStatus);
                statement.setString(4, transactionNo);
                statement.setString(5, bankCode);
                statement.setString(6, cardType);
                statement.setTimestamp(7, payDate == null ? null : new Timestamp(payDate.getTime()));
                statement.setString(8, limit(gatewayData, 8000));
                statement.setString(9, txnRef);
                changed = statement.executeUpdate();
            }

            if (changed == 1 && successful) activateSubscription(connection, txnRef);
            connection.commit();
            return changed == 1;
        } catch (SQLException ex) {
            if (connection != null) {
                try { connection.rollback(); } catch (SQLException ignored) { }
            }
            throw ex;
        } finally {
            if (connection != null) {
                try { connection.setAutoCommit(true); } catch (SQLException ignored) { }
                try { connection.close(); } catch (SQLException ignored) { }
            }
        }
    }

    private void activateSubscription(Connection connection, String txnRef) throws SQLException {
        String update = "UPDATE s SET s.plan_code = p.plan_code, s.plan_name = p.plan_name, "
                + "s.started_at = CASE WHEN s.status = 'ACTIVE' AND s.expires_at > GETDATE() "
                + "THEN s.started_at ELSE GETDATE() END, "
                + "s.expires_at = CASE WHEN s.status = 'ACTIVE' AND s.expires_at > GETDATE() "
                + "THEN DATEADD(DAY, p.duration_days, s.expires_at) "
                + "ELSE DATEADD(DAY, p.duration_days, GETDATE()) END, "
                + "s.status = 'ACTIVE', s.updated_at = GETDATE() "
                + "FROM UserSubscription s INNER JOIN PaymentTransaction p ON p.user_id = s.user_id "
                + "WHERE p.txn_ref = ?";
        int changed;
        try (PreparedStatement statement = connection.prepareStatement(update)) {
            statement.setString(1, txnRef);
            changed = statement.executeUpdate();
        }
        if (changed == 0) {
            String insert = "INSERT INTO UserSubscription "
                    + "(user_id, plan_code, plan_name, status, started_at, expires_at, updated_at) "
                    + "SELECT user_id, plan_code, plan_name, 'ACTIVE', GETDATE(), "
                    + "DATEADD(DAY, duration_days, GETDATE()), GETDATE() "
                    + "FROM PaymentTransaction WHERE txn_ref = ?";
            try (PreparedStatement statement = connection.prepareStatement(insert)) {
                statement.setString(1, txnRef);
                statement.executeUpdate();
            }
        }
    }

    private PaymentTransactionDTO map(ResultSet result) throws SQLException {
        PaymentTransactionDTO payment = new PaymentTransactionDTO();
        payment.setPaymentId(result.getLong("payment_id"));
        payment.setTxnRef(result.getString("txn_ref"));
        payment.setUserId(result.getInt("user_id"));
        payment.setPlanCode(result.getString("plan_code"));
        payment.setPlanName(result.getString("plan_name"));
        payment.setDurationDays(result.getInt("duration_days"));
        payment.setAmount(result.getLong("amount"));
        payment.setCurrency(result.getString("currency"));
        payment.setOrderInfo(result.getString("order_info"));
        payment.setStatus(result.getString("status"));
        payment.setBankCode(result.getString("bank_code"));
        payment.setCardType(result.getString("card_type"));
        payment.setGatewayTransactionNo(result.getString("vnp_transaction_no"));
        payment.setResponseCode(result.getString("response_code"));
        payment.setTransactionStatus(result.getString("transaction_status"));
        payment.setPayDate(result.getTimestamp("pay_date"));
        payment.setCreatedAt(result.getTimestamp("created_at"));
        payment.setUpdatedAt(result.getTimestamp("updated_at"));
        payment.setConfirmedAt(result.getTimestamp("confirmed_at"));
        return payment;
    }

    private Connection connection() throws SQLException {
        try {
            return DbUtils.getConnection();
        } catch (ClassNotFoundException ex) {
            throw new SQLException("Không tìm thấy SQL Server JDBC driver", ex);
        }
    }

    private static String limit(String value, int max) {
        if (value == null || value.length() <= max) return value;
        return value.substring(0, max);
    }

    private static boolean hasText(String value) {
        return value != null && !value.trim().isEmpty();
    }
}
