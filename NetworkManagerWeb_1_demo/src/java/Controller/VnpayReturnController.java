package Controller;

import Models.PaymentTransactionDTO;
import Models_DAO.PaymentTransactionDAO;
import Utils.VnpayCallbackProcessor;
import Utils.VnpayCallbackResult;
import Utils.VnpayConfig;
import Utils.VnpayService;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class VnpayReturnController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
        Map<String, String> params = VnpayService.extractVnpayParams(request);
        try {
            PaymentTransactionDAO dao = new PaymentTransactionDAO();
            VnpayCallbackResult result = VnpayCallbackProcessor.process(params,
                    VnpayConfig.load(getServletContext()), dao);
            PaymentTransactionDTO payment = result.getPayment();
            request.setAttribute("callbackResult", result);
            request.setAttribute("payment", payment);
            if (payment != null) {
                request.setAttribute("subscription", dao.findSubscription(payment.getUserId()));
            }
        } catch (SQLException ex) {
            getServletContext().log("Cannot process VNPAY Return URL", ex);
            request.setAttribute("processingError", true);
        }
        request.getRequestDispatcher("/WEB-INF/views/payment-result.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
