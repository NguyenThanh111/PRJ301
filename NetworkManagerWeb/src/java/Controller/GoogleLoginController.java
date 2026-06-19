package Controller;

import Models.AuthenticationLogDAO;
import Models.AuthenticationLogDTO;
import Models.UserDAO;
import Models.UserDTO;
import Models.UserRoleDAO;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import java.io.IOException;
import java.util.Collections;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class GoogleLoginController extends HttpServlet {

    private static final String CLIENT_ID = "353952447542-f2u39lhvfn0j2ikufm0pbl9jcc84q1hj.apps.googleusercontent.com";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("completeGoogleRegistration".equalsIgnoreCase(action)) {
            HttpSession session = request.getSession(false);

            if (session == null) {
                response.sendRedirect("login.jsp");
                return;
            }

            String googleEmail = (String) session.getAttribute("googleEmail");
            if (googleEmail == null || googleEmail.trim().isEmpty()) {
                response.sendRedirect("login.jsp");
                return;
            }

            UserDAO userDAO = new UserDAO();
            UserRoleDAO roleDAO = new UserRoleDAO();
            UserDTO user = userDAO.searchByNameOrEmail(googleEmail);

            if (user == null) {
                request.setAttribute("error", "Google registration is not completed.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }

            if (!user.isActive()) {
                request.setAttribute("error", "⚠ Your account is locked.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }

            String role = roleDAO.findRoleByUser(user.getUserId());
            session.setAttribute("user", user);
            session.setAttribute("role", role);

            new AuthenticationLogDAO().insert(new AuthenticationLogDTO(
                    googleEmail, AuthenticationLogDTO.STATUS_SUCCESS,
                    request.getRemoteAddr(), user.getUserId()));

            session.removeAttribute("googleFirstLogin");
            session.removeAttribute("googleName");
            session.removeAttribute("googleSub");
            session.removeAttribute("googleEmail");

            String url = ("Admin".equalsIgnoreCase(role) || "Technician".equalsIgnoreCase(role))
                    ? "staffDashboard.jsp"
                    : "userDashboard.jsp";
            response.sendRedirect(url);
            return;
        }

        response.sendRedirect("login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String credential = request.getParameter("credential");

        if (credential == null || credential.trim().isEmpty()) {
            request.setAttribute("error", "Google login failed. Missing credential.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        try {
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(
                    new NetHttpTransport(), GsonFactory.getDefaultInstance())
                    .setAudience(Collections.singletonList(CLIENT_ID))
                    .build();

            GoogleIdToken idToken = verifier.verify(credential);

            if (idToken == null) {
                request.setAttribute("error", "Google login failed. Invalid token.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }

            GoogleIdToken.Payload payload = idToken.getPayload();
            String email = payload.getEmail();
            String name = (String) payload.get("name");
            String sub = payload.getSubject();

            UserDAO userDAO = new UserDAO();
            UserRoleDAO roleDAO = new UserRoleDAO();
            UserDTO user = userDAO.searchByNameOrEmail(email);
            HttpSession session = request.getSession();

            if (user == null) {
                session.setAttribute("googleFirstLogin", true);
                session.setAttribute("googleEmail", email);
                session.setAttribute("googleName", name);
                session.setAttribute("googleSub", sub);
                response.sendRedirect("user-form.jsp");
                return;
            }

            if (!user.isActive()) {
                request.setAttribute("error", "⚠ Your account is locked.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }

            String role = roleDAO.findRoleByUser(user.getUserId());
            session.setAttribute("user", user);
            session.setAttribute("role", role);

            new AuthenticationLogDAO().insert(new AuthenticationLogDTO(
                    email, AuthenticationLogDTO.STATUS_SUCCESS,
                    request.getRemoteAddr(), user.getUserId()));

            String url = ("Admin".equalsIgnoreCase(role) || "Technician".equalsIgnoreCase(role))
                    ? "staffDashboard.jsp"
                    : "userDashboard.jsp";
            response.sendRedirect(url);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred. Please try again.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Google login controller";
    }
}
