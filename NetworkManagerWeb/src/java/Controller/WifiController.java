package Controller;

import Models.AccessPointDAO;
import Models.AccessPointDTO;
import Models.WiFiAnalyticsDAO;
import Models.WiFiAnalyticsDTO;
import java.io.IOException;
import java.util.ArrayList;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class WifiController extends HttpServlet {

    private final WiFiAnalyticsDAO analyticsDAO = new WiFiAnalyticsDAO();
    private final AccessPointDAO apDAO = new AccessPointDAO();

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "list":
                listAnalytics(request, response);
                break;

            case "apAnalytics":
                showAPAnalytics(request, response);
                break;

            case "generate":
                generateAnalytics(request, response);
                break;

            case "monthly":
                showMonthlyReport(request, response);
                break;

            default:
                listAnalytics(request, response);
                break;
        }
    }

    private void listAnalytics(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        ArrayList<WiFiAnalyticsDTO> analyticsList = analyticsDAO.ListAll();
        ArrayList<AccessPointDTO> apList = apDAO.ListAll();

        request.setAttribute("analyticsList", analyticsList);
        request.setAttribute("apList", apList);

        RequestDispatcher rd = request.getRequestDispatcher("wifi-analytics.jsp");
        rd.forward(request, response);
    }

    private void showAPAnalytics(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String apIdParam = request.getParameter("apId");
        if (apIdParam == null || apIdParam.trim().isEmpty()) {
            response.sendRedirect("WifiController?action=list");
            return;
        }

        int apId = Integer.parseInt(apIdParam);
        ArrayList<WiFiAnalyticsDTO> analyticsList = analyticsDAO.findByAP(apId);
        AccessPointDTO ap = apDAO.searchById(apId);

        request.setAttribute("analyticsList", analyticsList);
        request.setAttribute("selectedAP", ap);

        RequestDispatcher rd = request.getRequestDispatcher("wifi-analytics.jsp");
        rd.forward(request, response);
    }

    private void generateAnalytics(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String apIdParam = request.getParameter("apId");
        String totalUsersParam = request.getParameter("totalUsers");
        String peakUsersParam = request.getParameter("peakUsers");
        String avgSpeedParam = request.getParameter("avgSpeed");

        if (apIdParam == null || totalUsersParam == null || peakUsersParam == null || avgSpeedParam == null) {
            response.sendRedirect("WifiController?action=list&error=missing_params");
            return;
        }

        int apId = Integer.parseInt(apIdParam);
        int totalUsers = Integer.parseInt(totalUsersParam);
        int peakUsers = Integer.parseInt(peakUsersParam);
        double avgSpeed = Double.parseDouble(avgSpeedParam);

        boolean success = analyticsDAO.generateDailyAnalytics(apId, totalUsers, peakUsers, avgSpeed);

        String redirectUrl = success
                ? "WifiController?action=apAnalytics&apId=" + apId + "&msg=generated"
                : "WifiController?action=apAnalytics&apId=" + apId + "&error=generate_failed";

        response.sendRedirect(redirectUrl);
    }

    private void showMonthlyReport(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String apIdParam = request.getParameter("apId");
        String yearParam = request.getParameter("year");
        String monthParam = request.getParameter("month");

        if (apIdParam == null || yearParam == null || monthParam == null) {
            response.sendRedirect("WifiController?action=list");
            return;
        }

        int apId = Integer.parseInt(apIdParam);
        int year = Integer.parseInt(yearParam);
        int month = Integer.parseInt(monthParam);

        ArrayList<WiFiAnalyticsDTO> monthlyData = analyticsDAO.generateMonthlyAnalytics(apId, year, month);
        AccessPointDTO ap = apDAO.searchById(apId);

        request.setAttribute("monthlyData", monthlyData);
        request.setAttribute("selectedAP", ap);
        request.setAttribute("reportYear", year);
        request.setAttribute("reportMonth", month);

        RequestDispatcher rd = request.getRequestDispatcher("wifi-analytics.jsp");
        rd.forward(request, response);
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
        return "WiFi Analytics Controller";
    }
}