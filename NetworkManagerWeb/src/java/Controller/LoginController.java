
package Controller;

import Models_DAO.AuthenticationLogDAO;
import Models.AuthenticationLogDTO;
import Models_DAO.UserDAO;
import Models.UserDTO;
import Models_DAO.UserRoleDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpServlet;


public class LoginController extends HttpServlet {

    
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    response.setContentType("text/html;charset=UTF-8");
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    HttpSession session = request.getSession();

    // 1. Xử lý Đăng xuất (Logout) trước
    String action = request.getParameter("action");
    if ("logout".equals(action)) {
        session.invalidate(); // Xóa sạch thông tin đăng nhập
        response.sendRedirect("login.jsp");
        return;
    }
    // 2. Nếu đã đăng nhập mà cố tình vào lại trang login hoặc reload trang → redirect luôn
    if (session.getAttribute("user") != null) {
        String role = (String) session.getAttribute("role");
        if ("Admin".equalsIgnoreCase(role) || "Technician".equalsIgnoreCase(role)) {
            response.sendRedirect("staffDashboard.jsp");
        } else {
            response.sendRedirect("userDashboard.jsp"); 
        }
        return;
    }

    String username = request.getParameter("username");
    String password = request.getParameter("password");

    //  Kiểm tra null/empty → dừng ngay
    if (username == null || password == null ||
            username.trim().isEmpty() || password.trim().isEmpty()) {
        request.setAttribute("error", "Please enter username/email and password");
        request.getRequestDispatcher("login.jsp").forward(request, response);
        return;
    }

    UserDAO userDAO     = new UserDAO();
    UserRoleDAO roleDAO = new UserRoleDAO();
    AuthenticationLogDAO logDAO = new AuthenticationLogDAO();

    UserDTO user = userDAO.searchByNameOrEmail(username);
    String url   = "login.jsp"; // Mặc định quay về login khi có lỗi

    if (user == null) {
        logDAO.insert(new AuthenticationLogDTO(username, AuthenticationLogDTO.STATUS_FAILED,
                request.getRemoteAddr(), null));
        request.setAttribute("error", "⚠ Invalid username/email or password");

    } else if (!user.isActive()) {
        logDAO.insert(new AuthenticationLogDTO(username, AuthenticationLogDTO.STATUS_FAILED,
                request.getRemoteAddr(), user.getUserId()));
        request.setAttribute("error", "⚠ Your account is locked");

    } else if (!user.getPassword().equals(password)) {
        logDAO.insert(new AuthenticationLogDTO(username, AuthenticationLogDTO.STATUS_FAILED,
                request.getRemoteAddr(), user.getUserId()));
        request.setAttribute("error", "⚠ Username or password is wrong");

    } else {
        logDAO.insert(new AuthenticationLogDTO(username, AuthenticationLogDTO.STATUS_SUCCESS,
                request.getRemoteAddr(), user.getUserId()));
        String role = roleDAO.findRoleByUser(user.getUserId());
        session.setAttribute("user", user);
        session.setAttribute("role", role);
        url = ("Admin".equalsIgnoreCase(role) || "Technician".equalsIgnoreCase(role))
                ? "staffDashboard.jsp"
                : "userDashboard.jsp";
    }

    request.getRequestDispatcher(url).forward(request, response);
}

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>
}