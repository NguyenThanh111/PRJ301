package Controller;

import Models.AccessPointDAO;
import Models.AccessPointDTO;
import Models.NetworkAlertDAO;
import Models.NetworkAlertDTO;
import Models.RouterDAO;
import Models.RouterDTO;
import Models.SwitchDAO;
import Models.SwitchDTO;
import java.io.IOException;
import java.util.ArrayList;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class NetworkAlertController extends HttpServlet {

    private final NetworkAlertDAO alertDAO = new NetworkAlertDAO();
    private final RouterDAO routerDAO = new RouterDAO();
    private final AccessPointDAO apDAO = new AccessPointDAO();
    private final SwitchDAO switchDAO = new SwitchDAO();

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
                listAlerts(request, response);
                break;

            case "filter":
                filterAlerts(request, response);
                break;

            case "resolve":
                resolveAlert(request, response);
                break;

            case "create":
                createAlert(request, response);
                break;

            case "deviceAlerts":
                showDeviceAlerts(request, response);
                break;

            default:
                listAlerts(request, response);
                break;
        }
    }

    private void listAlerts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        ArrayList<NetworkAlertDTO> alerts = alertDAO.ListAll();
        ArrayList<RouterDTO> routerList = routerDAO.ListAll();

        request.setAttribute("alerts", alerts);
        request.setAttribute("routerList", routerList);
        request.setAttribute("severityFilter", "ALL");
        request.setAttribute("totalAlerts", alertDAO.countAll());
        
        request.getRequestDispatcher("network-alerts.jsp").forward(request, response);
    }

    private void filterAlerts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String severity = request.getParameter("severity");
        if (severity == null || severity.trim().isEmpty()) {
            severity = "ALL";
        }

        ArrayList<NetworkAlertDTO> alerts;
        if ("ALL".equalsIgnoreCase(severity)) {
            alerts = alertDAO.ListAll();
        } else {
            alerts = alertDAO.findBySeverity(severity);
        }

        request.setAttribute("alerts", alerts);
        request.setAttribute("severityFilter", severity);

        ArrayList<RouterDTO> routerList = routerDAO.ListAll();
        request.setAttribute("routerList", routerList);
        request.setAttribute("totalAlerts", alertDAO.countAll());
        
        request.getRequestDispatcher("network-alerts.jsp").forward(request, response);
    }

    private void resolveAlert(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String alertIdParam = request.getParameter("alertId");
        if (alertIdParam == null || alertIdParam.trim().isEmpty()) {
            response.sendRedirect("NetworkAlertController?action=list&error=missing_id");
            return;
        }

        int alertId = Integer.parseInt(alertIdParam);
        boolean success = alertDAO.resolveAlert(alertId);

        String redirectUrl = success
                ? "NetworkAlertController?action=list&msg=resolved"
                : "NetworkAlertController?action=list&error=resolve_failed";

        response.sendRedirect(redirectUrl);
    }

    private void createAlert(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String alertType = request.getParameter("alertType");
        String message = request.getParameter("message");
        String severity = request.getParameter("severity");
        String routerIdParam = request.getParameter("routerId");
        String apIdParam = request.getParameter("apId");
        String switchIdParam = request.getParameter("switchId");

        if (alertType == null || message == null || severity == null) {
            response.sendRedirect("NetworkAlertController?action=list&error=missing_fields");
            return;
        }

        NetworkAlertDTO alert = new NetworkAlertDTO();
        alert.setAlertType(alertType);
        alert.setMessage(message);
        alert.setSeverity(severity);

        if (routerIdParam != null && !routerIdParam.trim().isEmpty()) {
            alert.setRouterId(Integer.parseInt(routerIdParam));
        }
        if (apIdParam != null && !apIdParam.trim().isEmpty()) {
            alert.setApId(Integer.parseInt(apIdParam));
        }
        if (switchIdParam != null && !switchIdParam.trim().isEmpty()) {
            alert.setSwitchId(Integer.parseInt(switchIdParam));
        }

        boolean success = alertDAO.insert(alert);

        String redirectUrl = success
                ? "NetworkAlertController?action=list&msg=created"
                : "NetworkAlertController?action=list&error=create_failed";

        response.sendRedirect(redirectUrl);
    }

    private void showDeviceAlerts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String deviceType = request.getParameter("deviceType");
        String deviceIdParam = request.getParameter("deviceId");

        if (deviceType == null || deviceIdParam == null || deviceIdParam.trim().isEmpty()) {
            response.sendRedirect("NetworkAlertController?action=list");
            return;
        }

        int deviceId = Integer.parseInt(deviceIdParam);
        ArrayList<NetworkAlertDTO> alerts;

        switch (deviceType.toLowerCase()) {
            case "router":
                alerts = alertDAO.findByDevice(deviceId, null, null);
                RouterDTO router = routerDAO.searchById(deviceId);
                request.setAttribute("deviceName", router != null ? router.getRouterName() : "Unknown Router");
                break;
            case "ap":
                alerts = alertDAO.findByDevice(null, deviceId, null);
                AccessPointDTO ap = apDAO.searchById(deviceId);
                request.setAttribute("deviceName", ap != null ? ap.getApName() : "Unknown AP");
                break;
            case "switch":
                alerts = alertDAO.findByDevice(null, null, deviceId);
                SwitchDTO sw = switchDAO.searchById(deviceId);
                request.setAttribute("deviceName", sw != null ? sw.getSwitchName() : "Unknown Switch");
                break;
            default:
                response.sendRedirect("NetworkAlertController?action=list");
                return;
        }

        request.setAttribute("alerts", alerts);
        request.setAttribute("deviceType", deviceType);
        request.setAttribute("deviceId", deviceId);
        request.setAttribute("severityFilter", "ALL");

        ArrayList<RouterDTO> routerList = routerDAO.ListAll();
        request.setAttribute("routerList", routerList);

        request.getRequestDispatcher("network-alerts.jsp").forward(request, response);
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
        return "Network Alert Controller";
    }
}
