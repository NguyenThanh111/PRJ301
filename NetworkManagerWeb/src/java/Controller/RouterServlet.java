/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package Controller;

import Models_DAO.RouterDAO;
import Models.RouterDTO;
import java.io.IOException;
import java.util.ArrayList;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author User
 */
public class RouterServlet extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    RouterDAO routerDAO = new RouterDAO();

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null) {
            action = "routerList";
        }
        switch (action) {
            case "routerList":
                listRouters(request, response);
                break;

            case "routerAdd":
                showAddForm(request, response);
                break;

            case "routerEdit":
                showEditForm(request, response);
                break;

            case "routerInsert":
                insertRouter(request, response);
                break;

            case "routerUpdate":
                updateRouter(request, response);
                break;

            case "routerDelete":
                deleteRouter(request, response);
                break;

            case "routerRestart":
                restartRouter(request, response);
                break;

            case "routerUpdateStatus":
                updateStatus(request, response);
                break;

            default:
                listRouters(request, response);
                break;
        }

    }

    private void listRouters(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        ArrayList<RouterDTO> routers = routerDAO.ListAll();
        request.setAttribute("routers", routers);
        RequestDispatcher rd = request.getRequestDispatcher("router-list.jsp");
        rd.forward(request, response);
    }

    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("returnTo", request.getParameter("returnTo"));
        RequestDispatcher rd = request.getRequestDispatcher("router-form.jsp");
        rd.forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        RouterDTO router = routerDAO.searchById(id);
        request.setAttribute("router", router);
        request.setAttribute("returnTo", request.getParameter("returnTo"));
        RequestDispatcher rd = request.getRequestDispatcher("router-form.jsp");
        rd.forward(request, response);
    }

    private void insertRouter(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String routerName = cleanText(request.getParameter("routerName"));
        String ipAddress = cleanText(request.getParameter("ipAddress"));
        String macAddress = cleanText(request.getParameter("macAddress"));
        String model = cleanText(request.getParameter("model"));
        String firmware = cleanText(request.getParameter("firmware"));
        String status = cleanText(request.getParameter("status"));
        String location = cleanText(request.getParameter("location"));
        int roomId = parseIntOrDefault(request.getParameter("roomId"), 0);

        if (routerName == null || routerName.isEmpty()) {
            request.setAttribute("error", "Router name is required.");
            request.setAttribute("formRouter", new RouterDTO(0, routerName, ipAddress, macAddress, model, firmware, status, location, roomId));
            request.setAttribute("returnTo", request.getParameter("returnTo"));
            RequestDispatcher rd = request.getRequestDispatcher("router-form.jsp");
            rd.forward(request, response);
            return;
        }

        if (status == null || status.isEmpty()) {
            status = "ONLINE";
        }

        RouterDTO router = new RouterDTO(
                0, routerName, ipAddress, macAddress, model, firmware, status, location, roomId);
        boolean success = routerDAO.insert(router);
        if (!success) {
            request.setAttribute("error", "Fail");
            request.setAttribute("formRouter", router);
            request.setAttribute("returnTo", request.getParameter("returnTo"));
            RequestDispatcher rd = request.getRequestDispatcher("router-form.jsp");
            rd.forward(request, response);
            return;
        }
        redirectAfterAction(request, response);
        
    }
    private void updateRouter(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int routerId = Integer.parseInt(request.getParameter("routerId"));
        String routerName = cleanText(request.getParameter("routerName"));
        String ipAddress = cleanText(request.getParameter("ipAddress"));
        String macAddress = cleanText(request.getParameter("macAddress"));
        String model = cleanText(request.getParameter("model"));
        String firmware = cleanText(request.getParameter("firmware"));
        String status = cleanText(request.getParameter("status"));
        String location = cleanText(request.getParameter("location"));
        int roomId = parseIntOrDefault(request.getParameter("roomId"), 0);

        if (routerName == null || routerName.isEmpty()) {
            request.setAttribute("error", "Router name is required.");
            request.setAttribute("router", new RouterDTO(routerId, routerName, ipAddress, macAddress, model, firmware, status, location, roomId));
            request.setAttribute("returnTo", request.getParameter("returnTo"));
            RequestDispatcher rd = request.getRequestDispatcher("router-form.jsp");
            rd.forward(request, response);
            return;
        }

        if (status == null || status.isEmpty()) {
            status = "ONLINE";
        }

        RouterDTO router = new RouterDTO(
                routerId, routerName, ipAddress, macAddress, model, firmware, status, location, roomId);
        boolean success = routerDAO.update(router);
        if (!success) {
            request.setAttribute("error", "Fail");
            request.setAttribute("router", router);
            request.setAttribute("returnTo", request.getParameter("returnTo"));
            RequestDispatcher rd = request.getRequestDispatcher("router-form.jsp");
            rd.forward(request, response);
            return;
        }
        redirectAfterAction(request, response);
        
    }
    private void deleteRouter(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idValue = request.getParameter("routerId");
        if (idValue == null) {
            idValue = request.getParameter("id");
        }
        int id = Integer.parseInt(idValue);
        boolean success = routerDAO.softDelete(id);
        if (!success) {
            request.setAttribute("error", "Cannot delete router.");
        }
        redirectAfterAction(request, response);
    }
    private void restartRouter(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int id = Integer.parseInt(request.getParameter("id"));

        boolean success = routerDAO.restartRouter(id);
        if (!success) {
            request.setAttribute("error", "Cannot restart router.");
        }

        redirectAfterAction(request, response);
    }

    private void updateStatus(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int id = Integer.parseInt(request.getParameter("id"));
        String status = cleanText(request.getParameter("status"));
        if (status == null) {
            status = "ONLINE";
        }

        boolean success = routerDAO.updateStatus(id, status);
        if (!success) {
            request.setAttribute("error", "Cannot update router status.");
        }

        redirectAfterAction(request, response);
    }

    private void redirectAfterAction(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String returnTo = request.getParameter("returnTo");
        if ("dashboard".equals(returnTo)) {
            response.sendRedirect("staffDashboard.jsp?page=routers");
            return;
        }
        response.sendRedirect("MainController?action=routerList");
    }

    private int parseIntOrDefault(String value, int defaultValue) {
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private String cleanText(String value) {
        if (value == null) {
            return null;
        }
        value = value.trim();
        return value.isEmpty() ? null : value;
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
