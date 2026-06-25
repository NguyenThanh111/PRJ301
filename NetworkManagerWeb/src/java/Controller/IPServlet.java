
package Controller;

import Models_DAO.IPAddressManagementDAO;
import Models_DAO.NetworkDeviceDAO;
import Models.IPAddressManagementDTO;
import Models.NetworkDeviceDTO;
import java.io.IOException;
import java.util.ArrayList;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(
        name = "IPServlet",
        urlPatterns = {"/IPServlet"}
)
public class IPServlet extends HttpServlet {

    private static final int PAGE_SIZE = 9;
    private final IPAddressManagementDAO ipDAO
            = new IPAddressManagementDAO();
    private final NetworkDeviceDAO deviceDAO
            = new NetworkDeviceDAO();

    protected void processRequest(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType(
                "text/html;charset=UTF-8"
        );

        String action = request.getParameter("action");

        if (action == null || action.trim().isEmpty()) {
            action = "ipList";
        }

        switch (action) {
            case "ipList":
                listIPs(request, response);
                break;

            case "ipAssign":
                assignIP(request, response);
                break;

            case "ipRelease":
                releaseIP(request, response);
                break;

            default:
                listIPs(request, response);
                break;
        }
    }

    private void listIPs(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = cleanText(
                request.getParameter("keyword")
        );

        Integer pageValue = parseInteger(
                request.getParameter("page")
        );

        int currentPage = 1;

        if (pageValue != null && pageValue > 0) {
            currentPage = pageValue;
        }

        long totalRecords = ipDAO.countIPs(keyword);

        int totalPages = (int) Math.ceil(
                (double) totalRecords / PAGE_SIZE
        );

        ArrayList<IPAddressManagementDTO> ipList
                = ipDAO.getIPsByPage(
                        currentPage,
                        PAGE_SIZE,
                        keyword
                );

        long availableCount
                = ipDAO.countByStatus("AVAILABLE");

        long assignedCount
                = ipDAO.countByStatus("ASSIGNED");

        ArrayList<NetworkDeviceDTO> availableDevices
                = getAvailableDevices();

        request.setAttribute("ipList", ipList);
        request.setAttribute("keyword", keyword);
        request.setAttribute(
                "availableDevices",
                availableDevices
        );
        request.setAttribute(
                "currentPage",
                currentPage
        );
        request.setAttribute(
                "totalPages",
                totalPages
        );
        request.setAttribute(
                "totalRecords",
                totalRecords
        );
        request.setAttribute(
                "availableCount",
                availableCount
        );
        request.setAttribute(
                "assignedCount",
                assignedCount
        );

        RequestDispatcher rd
                = request.getRequestDispatcher(
                        "ip-list.jsp"
                );

        rd.forward(request, response);
    }

    private void assignIP(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        Integer ipId = parseInteger(
                request.getParameter("ipId")
        );

        Integer deviceId = parseInteger(
                request.getParameter("deviceId")
        );

        if (ipId == null || ipId <= 0) {
            request.setAttribute(
                    "error",
                    "Invalid IP ID."
            );
            listIPs(request, response);
            return;
        }

        if (deviceId == null || deviceId <= 0) {
            request.setAttribute(
                    "error",
                    "Device ID must be a valid positive number."
            );
            listIPs(request, response);
            return;
        }

        NetworkDeviceDTO device = deviceDAO.searchById(deviceId);

        if (device == null) {
            request.setAttribute(
                    "error",
                    "Selected device does not exist."
            );
            listIPs(request, response);
            return;
        }

        if (ipDAO.findByDevice(deviceId) != null) {
            request.setAttribute(
                    "error",
                    "Selected device already has an assigned IP."
            );
            listIPs(request, response);
            return;
        }

        boolean success = ipDAO.assignIP(
                ipId,
                deviceId
        );

        if (!success) {
            request.setAttribute(
                    "error",
                    "Cannot assign this IP. It may already be assigned, or the device may already have an IP."
            );
            listIPs(request, response);
            return;
        }

        redirectToCurrentPage(request, response);
    }

    private void releaseIP(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        Integer ipId = parseInteger(
                request.getParameter("ipId")
        );

        if (ipId == null || ipId <= 0) {
            request.setAttribute(
                    "error",
                    "Invalid IP ID."
            );
            listIPs(request, response);
            return;
        }

        boolean success = ipDAO.releaseIP(ipId);

        if (!success) {
            request.setAttribute(
                    "error",
                    "Cannot release this IP."
            );
            listIPs(request, response);
            return;
        }

        redirectToCurrentPage(request, response);
    }

    private void redirectToCurrentPage(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        if ("dashboard".equals(request.getParameter("returnTo"))) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/staffDashboard.jsp?page=ipmanage"
            );
            return;
        }

        Integer pageValue = parseInteger(
                request.getParameter("page")
        );

        int page = 1;

        if (pageValue != null && pageValue > 0) {
            page = pageValue;
        }

        response.sendRedirect(
                request.getContextPath()
                + "/MainController?action=ipList&page="
                + page
                + buildKeywordParameter(request)
        );
    }

    private ArrayList<NetworkDeviceDTO> getAvailableDevices() {
        ArrayList<NetworkDeviceDTO> devices
                = deviceDAO.ListAll();

        ArrayList<NetworkDeviceDTO> availableDevices
                = new ArrayList<>();

        for (NetworkDeviceDTO device : devices) {
            if (device == null || device.getDeviceId() <= 0) {
                continue;
            }

            if (ipDAO.findByDevice(device.getDeviceId()) == null) {
                availableDevices.add(device);
            }
        }

        return availableDevices;
    }

    private Integer parseInteger(String value) {

        if (value == null
                || value.trim().isEmpty()) {

            return null;
        }

        try {
            return Integer.valueOf(value.trim());

        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String cleanText(String value) {
        if (value == null) {
            return null;
        }

        String cleanedValue = value.trim();

        if (cleanedValue.isEmpty()) {
            return null;
        }

        return cleanedValue;
    }

    private String buildKeywordParameter(HttpServletRequest request)
            throws IOException {

        String keyword = cleanText(request.getParameter("keyword"));

        if (keyword == null) {
            return "";
        }

        return "&keyword=" + java.net.URLEncoder.encode(
                keyword,
                "UTF-8"
        );
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        processRequest(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "IP Address Management List Servlet";
    }
}
