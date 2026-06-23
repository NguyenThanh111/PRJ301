/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package Controller;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author User
 */
public class MainController extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        if (action == null) {
            action = "";
        }

        String url;

        switch (action) {
            //=================LOGIN=================
            case "login":
            case "dologin":
                url = "LoginController";
                break;
            //=================GG-LOGIN=================
            case "googleLogin":
            case "handleGoogleLogin":
                url = "GoogleLoginController";
                break;                
            //=================LOGOUT=================
            case "logout":
                url = "LoginController";
                break;
            //===============ROUTER==================
            case "routerList":
            case "routerAdd":
            case "routerEdit":
            case "routerInsert":
            case "routerUpdate":
            case "routerDelete":
            case "routerRestart":
            case "routerUpdateStatus":
                url = "RouterServlet";
                break;
            //==============AccessPoint==============
            case "apList":
            case "apAdd":
            case "apEdit":
            case "apInsert":
            case "apUpdate":
            case "apDelete":
                url = "AccessPointServlet";
                break;
            //=================SWITCH=================
            case "switchList":
            case "switchAdd":
            case "switchEdit":
            case "switchInsert":
            case "switchUpdate":
            case "switchDelete":
                url = "SwitchServlet";
                break;
            //=================DEVICE=================
            case "deviceList":
            case "deviceAdd":
            case "deviceEdit":
            case "deviceInsert":
            case "deviceUpdate":
            case "deviceDelete":
                url = "NetworkDeviceServlet";
                break;
            //===============BANDWIDTH===============
            case "bandwidthList":
            case "bandwidthAdd":
            case "bandwidthInsert":
            case "bandwidthDelete":
                url = "BandwidthServlet";
                break;
            //==============MAINTENANCE==============
            case "maintenanceList":
            case "maintenanceAdd":
            case "maintenanceEdit":
            case "maintenanceInsert":
            case "maintenanceUpdate":
            case "maintenanceDelete":
            case "maintenanceComplete":
                url = "MaintenanceServlet";
                break;
             //===============Room==================
            case "roomList":
            case "roomAdd":
            case "roomEdit":
            case "roomInsert":
            case "roomUpdate":
            case "roomDelete":
                url = "RoomServlet";
                break;
            //===============Vlan==================
            case "vlanList":
            case "vlanAdd":
            case "vlanEdit":
            case "vlanInsert":
            case "vlanUpdate":
            case "vlanDelete":
                url = "VLANServlet";
                break;
            //===============Id==================
            case "ipList":
                url = "IPServlet";
                break;
            //===============Support Ticket==================
            case "ticketList":
            case "ticketAdd":
            case "ticketEdit":
            case "ticketInsert":
            case "ticketUpdate":
            case "ticketUpdateStatus":
            case "ticketDelete":
                url = "TicketServlet";
                break;
                
                //default is Login page!
            default:
                url = "login.jsp";
                break;
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
