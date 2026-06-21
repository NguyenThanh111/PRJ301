package Controller;

import Models_DAO.AccessPointDAO;
import Models.AccessPointDTO;
import Models_DAO.NetworkAlertDAO;
import Models.NetworkAlertDTO;
import Models_DAO.NetworkDeviceDAO;
import Models.NetworkDeviceDTO;
import Models_DAO.RouterDAO;
import Models.RouterDTO;
import Models_DAO.SwitchDAO;
import Models.SwitchDTO;
import Models_DAO.UserDAO;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "HomeController", urlPatterns = {"/home"})
public class HomeController extends HttpServlet {

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

        try {
            RouterDAO routerDAO = new RouterDAO();
            AccessPointDAO apDAO = new AccessPointDAO();
            SwitchDAO switchDAO = new SwitchDAO();
            NetworkDeviceDAO deviceDAO = new NetworkDeviceDAO();
            NetworkAlertDAO alertDAO = new NetworkAlertDAO();

            ArrayList<RouterDTO> routers = routerDAO.ListAll();
            ArrayList<AccessPointDTO> aps = apDAO.ListAll();
            ArrayList<SwitchDTO> switches = switchDAO.ListAll();
            ArrayList<NetworkDeviceDTO> devices = deviceDAO.ListAll();

            long routerTotal = routers.size();
            long routerOnline = countByStatus(routers, "ONLINE");
            long routerOffline = countByStatus(routers, "OFFLINE");

            long apTotal = aps.size();
            long apOnline = countByStatus(aps, "ONLINE");
            long apOffline = countByStatus(aps, "OFFLINE");

            long switchTotal = switches.size();
            long switchOnline = countByStatus(switches, "ONLINE");
            long switchMaint = countByStatus(switches, "MAINTENANCE");

            long deviceTotal = devices.size();
            long deviceAllowed = countByDeviceStatus(devices, "ALLOWED");
            long deviceBlocked = countByDeviceStatus(devices, "BLOCKED");

            ArrayList<NetworkAlertDTO> allAlerts = alertDAO.ListAll();
            long alertTotal = allAlerts.size();
            long alertCritical = countBySeverity(allAlerts, "CRITICAL");
            long alertWarning = countBySeverity(allAlerts, "WARNING");

            List<NetworkAlertDTO> recentAlerts = allAlerts.stream()
                    .limit(5).collect(Collectors.toList());

            UserDAO userDAO = new UserDAO();
            long userTotal = userDAO.ListAll().size();

            request.setAttribute("routerTotal", routerTotal);
            request.setAttribute("routerOnline", routerOnline);
            request.setAttribute("routerOffline", routerOffline);
            request.setAttribute("apTotal", apTotal);
            request.setAttribute("apOnline", apOnline);
            request.setAttribute("apOffline", apOffline);
            request.setAttribute("switchTotal", switchTotal);
            request.setAttribute("switchOnline", switchOnline);
            request.setAttribute("switchMaint", switchMaint);
            request.setAttribute("deviceTotal", deviceTotal);
            request.setAttribute("deviceAllowed", deviceAllowed);
            request.setAttribute("deviceBlocked", deviceBlocked);
            request.setAttribute("alertTotal", alertTotal);
            request.setAttribute("alertCritical", alertCritical);
            request.setAttribute("alertWarning", alertWarning);
            request.setAttribute("userTotal", userTotal);
            request.setAttribute("recentAlerts", recentAlerts);

        } catch (Exception e) {
            e.printStackTrace();
        }

        request.getRequestDispatcher("index.jsp").forward(request, response);
    }

    private long countByStatus(ArrayList<?> list, String status) {
        return list.stream()
                .filter(dto -> {
                    try {
                        if (dto instanceof RouterDTO)
                            return ((RouterDTO) dto).getStatus().equalsIgnoreCase(status);
                        if (dto instanceof AccessPointDTO)
                            return ((AccessPointDTO) dto).getStatus().equalsIgnoreCase(status);
                        if (dto instanceof SwitchDTO)
                            return ((SwitchDTO) dto).getStatus().equalsIgnoreCase(status);
                    } catch (Exception e) { }
                    return false;
                })
                .count();
    }

    private long countByDeviceStatus(ArrayList<NetworkDeviceDTO> list, String status) {
        return list.stream()
                .filter(d -> d.getStatus() != null && d.getStatus().equalsIgnoreCase(status))
                .count();
    }

    private long countBySeverity(ArrayList<NetworkAlertDTO> list, String severity) {
        return list.stream()
                .filter(a -> a.getSeverity() != null && a.getSeverity().equalsIgnoreCase(severity))
                .count();
    }
}
