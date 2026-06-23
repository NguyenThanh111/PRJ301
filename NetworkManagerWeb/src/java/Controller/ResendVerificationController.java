package Controller;

import Models.UserDTO;
import Models.VerificationToken;
import Models_DAO.UserDAO;
import Models_DAO.VerificationTokenDAO;
import Utils.EmailUtils;
import Utils.TokenUtils;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "ResendVerificationController", urlPatterns = {"/ResendVerificationController"})
public class ResendVerificationController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        UserDTO user = (UserDTO) session.getAttribute("LOGIN_USER");
        if (user == null || !"PENDING".equals(user.getStatus())) {
            response.sendRedirect("login.jsp");
            return;
        }

        VerificationTokenDAO tokenDAO = new VerificationTokenDAO();

        // Cooldown check: 5 minutes
        long recent = tokenDAO.countRecentByUser(user.getUserId(), "VERIFICATION", 5);
        if (recent > 0) {
            request.setAttribute("error", "A verification email was already sent recently. Please check your email.");
            request.getRequestDispatcher("check-email.jsp").forward(request, response);
            return;
        }

        try {
            String token = TokenUtils.generateToken();
            VerificationToken vt = new VerificationToken(
                user.getUserId(), token, "VERIFICATION", TokenUtils.getExpiryDate(24));
            tokenDAO.save(vt);

            String baseUrl = request.getScheme() + "://" + request.getServerName()
                + ":" + request.getServerPort() + request.getContextPath();
            String verifyLink = baseUrl + "/VerifyEmailController?token=" + token;

            Map<String, String> placeholders = new HashMap<>();
            placeholders.put("USERNAME", user.getUsername());
            placeholders.put("VERIFY_LINK", verifyLink);
            placeholders.put("EXPIRY_HOURS", "24");

            String htmlBody = EmailUtils.loadTemplate(
                getServletContext(), "verify-email", placeholders);
            EmailUtils.sendEmail(user.getEmail(), "Verify your account", htmlBody);

            request.setAttribute("success", "Verification email sent. Please check your inbox.");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Cannot send email. Please try again later.");
        }

        request.getRequestDispatcher("check-email.jsp").forward(request, response);
    }
}
