package Controller;

import Models_DAO.PaymentTransactionDAO;
import Utils.VnpayCallbackProcessor;
import Utils.VnpayCallbackResult;
import Utils.VnpayConfig;
import Utils.VnpayService;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Map;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class VnpayIpnController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        respond(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        respond(request, response);
    }

    private void respond(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setStatus(HttpServletResponse.SC_OK);
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");
        String code = "99";
        String message = "Unknown error";
        try {
            Map<String, String> params = VnpayService.extractVnpayParams(request);
            VnpayCallbackResult result = VnpayCallbackProcessor.process(params,
                    VnpayConfig.load(getServletContext()), new PaymentTransactionDAO());
            code = result.getResponseCode();
            message = result.getMessage();
        } catch (SQLException ex) {
            getServletContext().log("Cannot process VNPAY IPN", ex);
        } catch (RuntimeException ex) {
            getServletContext().log("Invalid VNPAY IPN", ex);
        }
        response.getWriter().write("{\"RspCode\":\"" + code + "\",\"Message\":\"" + message + "\"}");
    }
}
