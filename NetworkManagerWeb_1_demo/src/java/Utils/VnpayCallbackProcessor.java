package Utils;

import Models.PaymentTransactionDTO;
import Models_DAO.PaymentTransactionDAO;
import java.sql.SQLException;
import java.util.Date;
import java.util.Map;

public final class VnpayCallbackProcessor {

    private VnpayCallbackProcessor() {
    }

    public static VnpayCallbackResult process(Map<String, String> params, VnpayConfig config,
            PaymentTransactionDAO dao) throws SQLException {
        if (!config.isConfigured()) {
            return new VnpayCallbackResult("99", "Merchant is not configured", null, false);
        }
        if (!VnpayService.verifySignature(params, config.getHashSecret())
                || !config.getTmnCode().equals(params.get("vnp_TmnCode"))) {
            return new VnpayCallbackResult("97", "Invalid Checksum", null, false);
        }

        String txnRef = params.get("vnp_TxnRef");
        PaymentTransactionDTO payment = dao.findByTxnRef(txnRef);
        if (payment == null) {
            return new VnpayCallbackResult("01", "Order not found", null, true);
        }

        long gatewayAmount = VnpayService.parseGatewayAmount(params.get("vnp_Amount"));
        if (gatewayAmount < 0 || gatewayAmount != payment.getAmount()) {
            return new VnpayCallbackResult("04", "Invalid Amount", payment, true);
        }

        if (!"PENDING".equalsIgnoreCase(payment.getStatus())) {
            return new VnpayCallbackResult("02", "Order already confirmed", payment, true);
        }

        String responseCode = params.get("vnp_ResponseCode");
        String transactionStatus = params.get("vnp_TransactionStatus");
        boolean successful = "00".equals(responseCode) && "00".equals(transactionStatus);
        String finalStatus = finalStatus(responseCode, successful);
        Date payDate = VnpayService.parsePayDate(params.get("vnp_PayDate"));

        boolean changed = dao.confirm(txnRef, successful, finalStatus, responseCode,
                transactionStatus, params.get("vnp_TransactionNo"), params.get("vnp_BankCode"),
                params.get("vnp_CardType"), payDate, VnpayService.auditData(params));
        PaymentTransactionDTO updated = dao.findByTxnRef(txnRef);
        return changed
                ? new VnpayCallbackResult("00", "Confirm Success", updated, true)
                : new VnpayCallbackResult("02", "Order already confirmed", updated, true);
    }

    private static String finalStatus(String responseCode, boolean successful) {
        if (successful) return "SUCCESS";
        if ("24".equals(responseCode)) return "CANCELLED";
        if ("11".equals(responseCode)) return "EXPIRED";
        return "FAILED";
    }
}
