
package Controller;

import Models_DAO.UserDAO;
import Models.UserDTO;
import Models_DAO.UserRoleDAO;
import Models.VerificationToken;
import Models_DAO.VerificationTokenDAO;
import Utils.EmailUtils;
import Utils.PasswordUtils;
import Utils.TokenUtils;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class RegisterUserController extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        String source = request.getParameter("source");
        if ("google".equalsIgnoreCase(source)) {
            handleGoogleFirstRegister(request, response);
            return;
        }

        handleNormalRegister(request, response);
    }

    private void handleNormalRegister(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String roleIdRaw = request.getParameter("roleId");
        String confirmPassword = request.getParameter("confirmPassword");

        String url = "user-form.jsp";

        try {
            UserDAO userDAO = new UserDAO();

            if (isBlank(username) || isBlank(password) || isBlank(confirmPassword) || isBlank(email) || isBlank(fullName)) {
                request.setAttribute("error", "All fields are required.");
                request.setAttribute("source", "normal");
                request.getRequestDispatcher(url).forward(request, response);
                return;
            }

            if (!password.equals(confirmPassword)) {
                request.setAttribute("error", "Confirm password does not match.");
                request.setAttribute("source", "normal");
                request.getRequestDispatcher(url).forward(request, response);
                return;
            }

            UserDTO existed = userDAO.searchByNameOrEmail(username);
            if (existed == null) {
                existed = userDAO.searchByNameOrEmail(email);
            }

            if (existed != null) {
                request.setAttribute("error", "Username or email already exists.");
                request.setAttribute("source", "normal");
                request.getRequestDispatcher(url).forward(request, response);
                return;
            }

            String hashedPassword = PasswordUtils.hashPassword(password);
            UserDTO newUser = new UserDTO(username, hashedPassword, fullName, email);
            boolean inserted = userDAO.insert(newUser);

            if (!inserted) {
                request.setAttribute("error", "Cannot create user. Please try again.");
                request.setAttribute("source", "normal");
                request.getRequestDispatcher(url).forward(request, response);
                return;
            }

            UserDTO created = userDAO.searchByNameOrEmail(username);
            int roleId = 3;
            if (!isBlank(roleIdRaw)) {
                roleId = Integer.parseInt(roleIdRaw);
            }

            if (created != null) {
                boolean roleAssigned = new UserRoleDAO().assignRole(created.getUserId(), roleId);
                if (!roleAssigned) {
                    request.setAttribute("error", "Cannot assign default role. Please contact administrator.");
                    request.setAttribute("source", "normal");
                    request.getRequestDispatcher(url).forward(request, response);
                    return;
                }
            }

            // Set user status to PENDING
            created.setStatus("PENDING");
            userDAO.update(created);

            // Store user in session for resend feature
            HttpSession sess = request.getSession();
            sess.setAttribute("LOGIN_USER", created);

            // Create verification token and send email
            try {
                String token = TokenUtils.generateToken();
                VerificationToken vt = new VerificationToken(
                    created.getUserId(), token, "VERIFICATION", TokenUtils.getExpiryDate(24));
                new VerificationTokenDAO().save(vt);

                String baseUrl = request.getScheme() + "://" + request.getServerName()
                    + ":" + request.getServerPort() + request.getContextPath();
                String verifyLink = baseUrl + "/VerifyEmailController?token=" + token;

                Map<String, String> placeholders = new HashMap<>();
                placeholders.put("USERNAME", username);
                placeholders.put("VERIFY_LINK", verifyLink);
                placeholders.put("EXPIRY_HOURS", "24");

                String htmlBody = EmailUtils.loadTemplate(
                    getServletContext(), "verify-email", placeholders);
                EmailUtils.sendEmail(email, "Verify your account", htmlBody);
            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("error", "Cannot send verification email. Please use Resend Verification below.");
                request.getRequestDispatcher("check-email.jsp").forward(request, response);
                return;
            }

            request.setAttribute("success", "Register successfully. Please check your email to verify.");
            request.getRequestDispatcher("check-email.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Unexpected error: " + e.getMessage());
            request.setAttribute("source", "normal");
            request.getRequestDispatcher(url).forward(request, response);
        }
    }

    private void handleGoogleFirstRegister(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("googleFirstLogin") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String email = (String) session.getAttribute("googleEmail");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String fullName = request.getParameter("fullName");

        if (isBlank(email) || isBlank(username) || isBlank(password) || isBlank(confirmPassword) || isBlank(fullName)) {
            request.setAttribute("error", "All fields are required.");
            request.setAttribute("source", "google");
            request.getRequestDispatcher("user-form.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Confirm password does not match.");
            request.setAttribute("source", "google");
            request.getRequestDispatcher("user-form.jsp").forward(request, response);
            return;
        }

        try {
            UserDAO userDAO = new UserDAO();
            UserRoleDAO roleDAO = new UserRoleDAO();

            UserDTO existed = userDAO.searchByNameOrEmail(username);
            if (existed == null) {
                existed = userDAO.searchByNameOrEmail(email);
            }

            if (existed != null) {
                request.setAttribute("error", "Username or email already exists.");
                request.setAttribute("source", "google");
                request.getRequestDispatcher("user-form.jsp").forward(request, response);
                return;
            }

            String hashedPassword = PasswordUtils.hashPassword(password);
            UserDTO newUser = new UserDTO(username, hashedPassword, fullName, email);
            boolean inserted = userDAO.insert(newUser);

            if (!inserted) {
                request.setAttribute("error", "Cannot create user. Please try again.");
                request.setAttribute("source", "google");
                request.getRequestDispatcher("user-form.jsp").forward(request, response);
                return;
            }

            UserDTO created = userDAO.searchByNameOrEmail(username);
            if (created != null) {
                boolean roleAssigned = roleDAO.assignRole(created.getUserId(), 3);
                if (!roleAssigned) {
                    request.setAttribute("error", "Cannot assign default role. Please contact administrator.");
                    request.setAttribute("source", "google");
                    request.getRequestDispatcher("user-form.jsp").forward(request, response);
                    return;
                }
            }

            // Set user status to PENDING
            created.setStatus("PENDING");
            userDAO.update(created);

            // Store user in session for resend feature
            HttpSession sess = request.getSession();
            sess.setAttribute("LOGIN_USER", created);

            // Create verification token and send email
            try {
                String token = TokenUtils.generateToken();
                VerificationToken vt = new VerificationToken(
                    created.getUserId(), token, "VERIFICATION", TokenUtils.getExpiryDate(24));
                new VerificationTokenDAO().save(vt);

                String baseUrl = request.getScheme() + "://" + request.getServerName()
                    + ":" + request.getServerPort() + request.getContextPath();
                String verifyLink = baseUrl + "/VerifyEmailController?token=" + token;

                Map<String, String> placeholders = new HashMap<>();
                placeholders.put("USERNAME", username);
                placeholders.put("VERIFY_LINK", verifyLink);
                placeholders.put("EXPIRY_HOURS", "24");

                String htmlBody = EmailUtils.loadTemplate(
                    getServletContext(), "verify-email", placeholders);
                EmailUtils.sendEmail(email, "Verify your account", htmlBody);
            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("error", "Cannot send verification email. Please use Resend Verification below.");
                request.getRequestDispatcher("check-email.jsp").forward(request, response);
                return;
            }

            request.setAttribute("success", "Register successfully. Please check your email to verify.");
            request.getRequestDispatcher("check-email.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Unexpected error: " + e.getMessage());
            request.setAttribute("source", "google");
            request.getRequestDispatcher("user-form.jsp").forward(request, response);
        }
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Register user controller";
    }
}
