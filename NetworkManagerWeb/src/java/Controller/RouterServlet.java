/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package Controller;

import Models.RouterDAO;
import Models.RouterDTO;
import java.io.IOException;
import java.io.PrintWriter;
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
        RequestDispatcher rd = request.getRequestDispatcher("router-list.jsp");
        rd.forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = Integer.parseInt(request.getParameter("id"));

        RouterDTO router=routerDAO.searchById(id);
        RequestDispatcher rd = request.getRequestDispatcher("router-form.jsp");
        request.setAttribute("router", router);
        rd.forward(request, response);
    }
    private void insertRouter(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int routerId = Integer.parseInt(request.getParameter("routerId"));
        String routerName = request.getParameter("routerName");
        String ipAddress = request.getParameter("ipAddress");
        String macAddress = request.getParameter("macAddress");
        String model = request.getParameter("model");
        String firmware = request.getParameter("firmware");
        String status = request.getParameter("status");
        String location = request.getParameter("location");
        int roomId = Integer.parseInt(request.getParameter("roomId"));
        RouterDTO router = new RouterDTO(
                routerId, routerName, ipAddress, macAddress, model, firmware, status, location, roomId);
        routerDAO.insert(router);
        response.sendRedirect("MainController?action=routerList");
        
    }
    private void updateRouter(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int routerId = Integer.parseInt(request.getParameter("routerId"));
        String routerName = request.getParameter("routerName");
        String ipAddress = request.getParameter("ipAddress");
        String macAddress = request.getParameter("macAddress");
        String model = request.getParameter("model");
        String firmware = request.getParameter("firmware");
        String status = request.getParameter("status");
        String location = request.getParameter("location");
        int roomId = Integer.parseInt(request.getParameter("roomId"));
        RouterDTO router = new RouterDTO(
                routerId, routerName, ipAddress, macAddress, model, firmware, status, location, roomId);
        routerDAO.update(router);
        response.sendRedirect("MainController?action=routerList");
        
    }
    private void deleteRouter(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("routerId"));
        routerDAO.softDelete(id);
        response.sendRedirect("MainController?action=routerList");
    }
    private void restartRouter(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int id = Integer.parseInt(request.getParameter("id"));

        routerDAO.restartRouter(id);

        response.sendRedirect("MainController?action=routerList");
    }

    private void updateStatus(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int id = Integer.parseInt(request.getParameter("id"));
        String status = request.getParameter("status");

        routerDAO.updateStatus(id, status);

        response.sendRedirect("MainController?action=routerList");
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
