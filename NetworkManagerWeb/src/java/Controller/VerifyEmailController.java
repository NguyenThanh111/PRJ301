package Controller;

import Models.UserDTO;
import Models.VerificationToken;
import Models_DAO.UserDAO;
import Models_DAO.VerificationTokenDAO;
import Utils.EmailUtils;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "VerifyEmailController", urlPatterns = {"/VerifyEmailController"})
public class VerifyEmailController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String token = request.getParameter("token");
        if (token == null || token.trim().isEmpty()) {
            request.setAttribute("error", "Invalid verification link.");
            request.getRequestDispatcher("verify-email-failed.jsp").forward(request, response);
            return;
        }

        VerificationTokenDAO tokenDAO = new VerificationTokenDAO();
        VerificationToken vt = tokenDAO.findByToken(token.trim());

        if (vt == null) {
            request.setAttribute("error", "Invalid verification link.");
            request.getRequestDispatcher("verify-email-failed.jsp").forward(request, response);
            return;
        }

        if (vt.isUsed()) {
            request.setAttribute("error", "This link has already been used.");
            request.getRequestDispatcher("verify-email-failed.jsp").forward(request, response);
            return;
        }

        if (vt.isExpired()) {
            request.setAttribute("error", "Verification link has expired. Please request a new one.");
            request.getRequestDispatcher("verify-email-failed.jsp").forward(request, response);
            return;
        }

        UserDAO userDAO = new UserDAO();
        UserDTO user = userDAO.searchById(vt.getUserId());

        if (user == null) {
            request.setAttribute("error", "User not found.");
            request.getRequestDispatcher("verify-email-failed.jsp").forward(request, response);
            return;
        }

        if ("ACTIVE".equals(user.getStatus())) {
            request.setAttribute("error", "Your account is already verified. Please login.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        // Activate user
        user.setStatus("ACTIVE");
        userDAO.update(user);
        tokenDAO.markUsed(vt.getId());

        // Send welcome email (best-effort)
        try {
            String baseUrl = request.getScheme() + "://" + request.getServerName()
                + ":" + request.getServerPort() + request.getContextPath();
            Map<String, String> placeholders = new HashMap<>();
            placeholders.put("USERNAME", user.getUsername());
            placeholders.put("DASHBOARD_LINK", baseUrl + "/login.jsp");
            String htmlBody = EmailUtils.loadTemplate(
                getServletContext(), "welcome", placeholders);
            EmailUtils.sendEmail(user.getEmail(), "Welcome to Network Manager", htmlBody);
        } catch (Exception e) {
            e.printStackTrace(); // log and ignore — welcome is best-effort
        }

        request.setAttribute("success", "Email verified successfully! You can now login.");
        request.getRequestDispatcher("email-verified.jsp").forward(request, response);
    }
}
