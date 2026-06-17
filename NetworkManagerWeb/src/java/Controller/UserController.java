package Controller;

import Models.RoleDAO;
import Models.RoleDTO;
import Models.UserDAO;
import Models.UserDTO;
import Models.UserRoleDAO;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "UserController", urlPatterns = {"/UserController"})
public class UserController extends HttpServlet {

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

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        try {
            switch (action) {
                case "search":
                    searchUsers(request, response);
                    break;
                case "add":
                    addUser(request, response);
                    break;
                case "update":
                    updateUser(request, response);
                    break;
                case "delete":
                    deleteUser(request, response);
                    break;
                case "list":
                default:
                    listUsers(request, response);
                    break;
            }
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    private void listUsers(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        UserDAO dao = new UserDAO();
        UserRoleDAO roleDAO = new UserRoleDAO();
        RoleDAO allRoles = new RoleDAO();

        ArrayList<UserDTO> list = dao.ListAll();
        Map<Integer, String> roleMap = new HashMap<>();
        for (UserDTO u : list) {
            roleMap.put(u.getUserId(), roleDAO.findRoleByUser(u.getUserId()));
        }
        ArrayList<RoleDTO> roleList = allRoles.ListAll();

        request.setAttribute("userList", list);
        request.setAttribute("roleMap", roleMap);
        request.setAttribute("roleList", roleList);
        request.setAttribute("activeTab", "users");
        request.getRequestDispatcher("manage-user.jsp").forward(request, response);
    }

    private void searchUsers(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        UserDAO dao = new UserDAO();
        UserRoleDAO roleDAO = new UserRoleDAO();
        RoleDAO allRoles = new RoleDAO();

        ArrayList<UserDTO> list = dao.searchListByKeyword(keyword);
        Map<Integer, String> roleMap = new HashMap<>();
        for (UserDTO u : list) {
            roleMap.put(u.getUserId(), roleDAO.findRoleByUser(u.getUserId()));
        }
        ArrayList<RoleDTO> roleList = allRoles.ListAll();

        request.setAttribute("userList", list);
        request.setAttribute("roleMap", roleMap);
        request.setAttribute("roleList", roleList);
        request.setAttribute("keyword", keyword);
        request.setAttribute("activeTab", "users");
        request.getRequestDispatcher("manage-user.jsp").forward(request, response);
    }

    private void addUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String username = request.getParameter("username");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String roleIdStr = request.getParameter("roleId");

        UserDTO user = new UserDTO(username, password, fullName, email);
        UserDAO dao = new UserDAO();
        dao.insert(user);

        UserDTO created = dao.searchByNameOrEmail(username);
        if (created != null && roleIdStr != null && !roleIdStr.trim().isEmpty()) {
            int roleId = Integer.parseInt(roleIdStr);
            new UserRoleDAO().assignRole(created.getUserId(), roleId);
        }

        response.sendRedirect("UserController?action=list");
    }

    private void updateUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int userId = Integer.parseInt(request.getParameter("userId"));
        String username = request.getParameter("username");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        boolean status = request.getParameter("status") != null;
        String roleIdStr = request.getParameter("roleId");

        UserDTO user = new UserDTO(username, password, fullName, email);
        user.setUserId(userId);
        user.setStatus(status);

        UserDAO dao = new UserDAO();
        dao.update(user);

        if (roleIdStr != null && !roleIdStr.trim().isEmpty()) {
            int roleId = Integer.parseInt(roleIdStr);
            UserRoleDAO roleDAO = new UserRoleDAO();
            roleDAO.removeAllRoles(userId);
            roleDAO.assignRole(userId, roleId);
        }

        response.sendRedirect("UserController?action=list");
    }

    private void deleteUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int userId = Integer.parseInt(request.getParameter("userId"));
        UserDAO dao = new UserDAO();
        dao.softDelete(userId);
        response.sendRedirect("UserController?action=list");
    }
}
