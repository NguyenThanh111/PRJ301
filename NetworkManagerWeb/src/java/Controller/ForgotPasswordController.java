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

@WebServlet(name = "ForgotPasswordController", urlPatterns = {"/ForgotPasswordController"})
public class ForgotPasswordController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Please enter your email.");
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            return;
        }

        UserDAO userDAO = new UserDAO();
        UserDTO user = userDAO.searchByNameOrEmail(email.trim());

        if (user == null) {
            request.setAttribute("error", "No account found with this email.");
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            return;
        }

        VerificationTokenDAO tokenDAO = new VerificationTokenDAO();

        long recent = tokenDAO.countRecentByUser(user.getUserId(), "RESET", 5);
        if (recent > 0) {
            request.setAttribute("error", "A reset email was already sent recently. Please check your inbox.");
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            return;
        }

        try {
            String token = TokenUtils.generateToken();
            VerificationToken vt = new VerificationToken(
                user.getUserId(), token, "RESET", TokenUtils.getExpiryDate(24));
            tokenDAO.save(vt);

            String baseUrl = request.getScheme() + "://" + request.getServerName()
                + ":" + request.getServerPort() + request.getContextPath();
            String resetLink = baseUrl + "/ResetPasswordController?token=" + token;

            Map<String, String> placeholders = new HashMap<>();
            placeholders.put("USERNAME", user.getUsername());
            placeholders.put("RESET_LINK", resetLink);
            placeholders.put("EXPIRY_HOURS", "24");

            String htmlBody = EmailUtils.loadTemplate(
                getServletContext(), "reset-password", placeholders);
            EmailUtils.sendEmail(user.getEmail(), "Reset your password", htmlBody);

            request.setAttribute("success", "Reset link sent. Please check your email.");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Cannot send email. Please try again later.");
        }

        request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
    }
}
