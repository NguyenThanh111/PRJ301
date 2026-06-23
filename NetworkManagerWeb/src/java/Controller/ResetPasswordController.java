package Controller;

import Models.UserDTO;
import Models.VerificationToken;
import Models_DAO.UserDAO;
import Models_DAO.VerificationTokenDAO;
import Utils.PasswordUtils;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "ResetPasswordController", urlPatterns = {"/ResetPasswordController"})
public class ResetPasswordController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String token = request.getParameter("token");
        if (token == null || token.trim().isEmpty()) {
            request.setAttribute("error", "Invalid reset link.");
            request.getRequestDispatcher("verify-email-failed.jsp").forward(request, response);
            return;
        }

        VerificationTokenDAO tokenDAO = new VerificationTokenDAO();
        VerificationToken vt = tokenDAO.findByToken(token.trim());

        if (vt == null) {
            request.setAttribute("error", "Invalid reset link.");
            request.getRequestDispatcher("verify-email-failed.jsp").forward(request, response);
            return;
        }

        if (vt.isUsed()) {
            request.setAttribute("error", "This reset link has already been used.");
            request.getRequestDispatcher("verify-email-failed.jsp").forward(request, response);
            return;
        }

        if (vt.isExpired()) {
            request.setAttribute("error", "Reset link has expired. Please request a new one.");
            request.getRequestDispatcher("verify-email-failed.jsp").forward(request, response);
            return;
        }

        request.setAttribute("token", token);
        response.setHeader("Referrer-Policy", "no-referrer");
        request.getRequestDispatcher("reset-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String token = request.getParameter("token");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (token == null || newPassword == null || confirmPassword == null
            || newPassword.trim().isEmpty() || confirmPassword.trim().isEmpty()) {
            request.setAttribute("error", "All fields are required.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("reset-password.jsp").forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("reset-password.jsp").forward(request, response);
            return;
        }

        VerificationTokenDAO tokenDAO = new VerificationTokenDAO();
        VerificationToken vt = tokenDAO.findByToken(token);

        if (vt == null || vt.isUsed() || vt.isExpired()) {
            request.setAttribute("error", "Invalid or expired reset link.");
            request.getRequestDispatcher("verify-email-failed.jsp").forward(request, response);
            return;
        }

        UserDAO userDAO = new UserDAO();
        UserDTO user = userDAO.searchById(vt.getUserId());
        if (user != null) {
            user.setPassword(PasswordUtils.hashPassword(newPassword));
            if ("PENDING".equals(user.getStatus())) {
                user.setStatus("ACTIVE");
            }
            userDAO.update(user);
        }
        tokenDAO.markAllUsed(vt.getUserId(), "RESET");

        request.setAttribute("success", "Password reset successfully. Please login.");
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
}
