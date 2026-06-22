/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package Controller;

import Models_DAO.SystemLogDAO;
import Models.SystemLogDTO;
import java.io.IOException;
import java.util.ArrayList;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class SystemLogController extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");
        
        // Basic security check - only admin should view logs
        if (role == null || !role.equalsIgnoreCase("Admin")) {
            response.sendRedirect("login.jsp");
            return;
        }

        SystemLogDAO dao = new SystemLogDAO();
        ArrayList<SystemLogDTO> list = dao.findAll();
        
        request.setAttribute("systemLogs", list);
        request.setAttribute("activeTab", "systemlogs");
        request.getRequestDispatcher("systemLog.jsp").forward(request, response);
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
        return "SystemLog Controller";
    }

}
