package Controller;

import Models.PaymentPlan;
import Models.PaymentTransactionDTO;
import Models.UserDTO;
import Models_DAO.PaymentTransactionDAO;
import Utils.PaymentPlanCatalog;
import Utils.VnpayConfig;
import Utils.VnpayService;
import java.io.IOException;
import java.security.SecureRandom;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class PaymentCheckoutController extends HttpServlet {

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final Set<String> BANK_CODES = new HashSet<String>(
            Arrays.asList("", "VNPAYQR", "VNBANK", "INTCARD"));

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        prepareResponse(request, response);
        UserDTO user = authenticatedUser(request, response);
        if (user == null) return;

        PaymentPlan selected = PaymentPlanCatalog.find(request.getParameter("plan"));
        if (selected == null) selected = PaymentPlanCatalog.getAll().get(0);
        request.setAttribute("selectedPlan", selected);
        loadPageData(request, user);
        request.getRequestDispatcher("/WEB-INF/views/payment-checkout.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        prepareResponse(request, response);
        UserDTO user = authenticatedUser(request, response);
        if (user == null) return;

        PaymentPlan plan = PaymentPlanCatalog.find(request.getParameter("planCode"));
        request.setAttribute("selectedPlan", plan == null ? PaymentPlanCatalog.getAll().get(0) : plan);
        if (!consumeCsrf(request)) {
            showError(request, response, user, "Phiên thanh toán không hợp lệ. Vui lòng tải lại trang và thử lại.");
            return;
        }
        if (plan == null) {
            showError(request, response, user, "Gói dịch vụ không hợp lệ.");
            return;
        }

        String bankCode = value(request.getParameter("bankCode"));
        if (!BANK_CODES.contains(bankCode)) {
            showError(request, response, user, "Phương thức thanh toán không hợp lệ.");
            return;
        }

        VnpayConfig config = VnpayConfig.load(getServletContext());
        if (!config.isConfigured()) {
            showError(request, response, user,
                    "VNPAY chưa có TMN Code/Hash Secret. Hãy thêm khóa được VNPAY cấp vào cấu hình.");
            return;
        }

        String txnRef = VnpayService.generateTxnRef(user.getUserId());
        String orderInfo = "Thanh toan goi " + plan.getCode() + " cho tai khoan " + user.getUserId();
        String clientIp = VnpayService.clientIp(request);
        PaymentTransactionDTO payment = new PaymentTransactionDTO();
        payment.setTxnRef(txnRef);
        payment.setUserId(user.getUserId());
        payment.setPlanCode(plan.getCode());
        payment.setPlanName(plan.getName());
        payment.setDurationDays(plan.getDurationDays());
        payment.setAmount(plan.getAmount());
        payment.setCurrency("VND");
        payment.setOrderInfo(orderInfo);
        payment.setClientIp(clientIp);

        try {
            new PaymentTransactionDAO().create(payment);
            String paymentUrl = VnpayService.createPaymentUrl(config, txnRef, plan.getAmount(),
                    orderInfo, bankCode, clientIp, config.resolveReturnUrl(request));
            response.sendRedirect(paymentUrl);
        } catch (SQLException ex) {
            getServletContext().log("Cannot create VNPAY payment " + txnRef, ex);
            showError(request, response, user,
                    "Không thể tạo giao dịch. Hãy chạy file VnpayMigration.sql và kiểm tra kết nối database.");
        } catch (RuntimeException ex) {
            getServletContext().log("Cannot build VNPAY URL " + txnRef, ex);
            showError(request, response, user, "Không thể kết nối cấu hình VNPAY. Vui lòng kiểm tra lại khóa tích hợp.");
        }
    }

    private void loadPageData(HttpServletRequest request, UserDTO user) {
        request.setAttribute("plans", PaymentPlanCatalog.getAll());
        VnpayConfig config = VnpayConfig.load(getServletContext());
        request.setAttribute("vnpayConfigured", config.isConfigured());
        request.setAttribute("ipnUrl", config.resolveIpnUrl(request));
        request.setAttribute("csrfToken", csrfToken(request.getSession()));
        try {
            PaymentTransactionDAO dao = new PaymentTransactionDAO();
            request.setAttribute("payments", dao.findRecentByUser(user.getUserId()));
            request.setAttribute("subscription", dao.findSubscription(user.getUserId()));
        } catch (SQLException ex) {
            getServletContext().log("Cannot load payment data", ex);
            request.setAttribute("databaseReady", false);
        }
    }

    private void showError(HttpServletRequest request, HttpServletResponse response,
            UserDTO user, String message) throws ServletException, IOException {
        request.setAttribute("error", message);
        loadPageData(request, user);
        request.getRequestDispatcher("/WEB-INF/views/payment-checkout.jsp").forward(request, response);
    }

    private UserDTO authenticatedUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !(session.getAttribute("user") instanceof UserDTO)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return null;
        }
        return (UserDTO) session.getAttribute("user");
    }

    private boolean consumeCsrf(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        String actual = request.getParameter("csrfToken");
        synchronized (session) {
            String expected = (String) session.getAttribute("paymentCsrfToken");
            if (expected == null || !expected.equals(actual)) return false;
            session.removeAttribute("paymentCsrfToken");
            return true;
        }
    }

    private String csrfToken(HttpSession session) {
        String token = (String) session.getAttribute("paymentCsrfToken");
        if (token != null) return token;
        byte[] bytes = new byte[24];
        RANDOM.nextBytes(bytes);
        StringBuilder result = new StringBuilder();
        for (byte b : bytes) result.append(String.format("%02x", b & 0xff));
        token = result.toString();
        session.setAttribute("paymentCsrfToken", token);
        return token;
    }

    private void prepareResponse(HttpServletRequest request, HttpServletResponse response)
            throws java.io.UnsupportedEncodingException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
        response.setHeader("Pragma", "no-cache");
    }

    private String value(String input) {
        return input == null ? "" : input.trim().toUpperCase();
    }
}
