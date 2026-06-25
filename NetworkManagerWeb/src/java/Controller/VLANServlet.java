
package Controller;

import Models_DAO.RoomDAO;
import Models_DAO.VLANDAO;
import Models.VLANDTO;
import java.io.IOException;
import java.util.ArrayList;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class VLANServlet extends HttpServlet {

    private static final int PAGE_SIZE = 9;
    private final VLANDAO vlanDAO = new VLANDAO();
    private final RoomDAO roomDAO = new RoomDAO();

    protected void processRequest(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String action = request.getParameter("action");

        if (action == null || action.trim().isEmpty()) {
            action = "vlanList";
        }

        switch (action) {
            case "vlanList":
                listVLANs(request, response);
                break;

            case "vlanAdd":
                showAddForm(request, response);
                break;

            case "vlanEdit":
                showEditForm(request, response);
                break;

            case "vlanInsert":
                insertVLAN(request, response);
                break;

            case "vlanUpdate":
                updateVLAN(request, response);
                break;

            case "vlanDelete":
                deleteVLAN(request, response);
                break;

            default:
                listVLANs(request, response);
                break;
        }
    }

    private void listVLANs(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = cleanText(request.getParameter("keyword"));

        Integer pageValue = parseInteger(
                request.getParameter("page")
        );

        int currentPage;

        if (pageValue == null || pageValue < 1) {
            currentPage = 1;
        } else {
            currentPage = pageValue;
        }

        long totalRecords = vlanDAO.countVLANs(keyword);

        int totalPages = (int) Math.ceil(
                (double) totalRecords / PAGE_SIZE
        );

        ArrayList<VLANDTO> vlans
                = vlanDAO.getVLANsByPage(
                        currentPage,
                        PAGE_SIZE,
                        keyword
                );

        request.setAttribute("vlans", vlans);
        request.setAttribute("keyword", keyword);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);

        RequestDispatcher rd
                = request.getRequestDispatcher("vlan-list.jsp");

        rd.forward(request, response);
    }
    
    private void showAddForm(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        // Danh sách Room để hiển thị trong select
        request.setAttribute(
                "rooms",
                roomDAO.ListAll()
        );

        request.setAttribute(
                "returnTo",
                request.getParameter("returnTo")
        );

        RequestDispatcher rd
                = request.getRequestDispatcher("vlan-form.jsp");

        rd.forward(request, response);
    }

    private void showEditForm(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        Integer vlanId = parseInteger(
                request.getParameter("id")
        );

        if (vlanId == null || vlanId <= 0) {
            request.setAttribute(
                    "error",
                    "Invalid VLAN ID."
            );

            listVLANs(request, response);
            return;
        }

        VLANDTO vlan = vlanDAO.searchById(vlanId);

        if (vlan == null) {
            request.setAttribute(
                    "error",
                    "VLAN does not exist."
            );

            listVLANs(request, response);
            return;
        }

        request.setAttribute("vlan", vlan);

        request.setAttribute(
                "rooms",
                roomDAO.ListAll()
        );

        request.setAttribute(
                "returnTo",
                request.getParameter("returnTo")
        );

        RequestDispatcher rd
                = request.getRequestDispatcher("vlan-form.jsp");

        rd.forward(request, response);
    }
    
    private void insertVLAN(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String vlanName = cleanText(
                request.getParameter("vlanName")
        );

        String subnet = cleanText(
                request.getParameter("subnet")
        );

        String purpose = cleanText(
                request.getParameter("purpose")
        );

        String roomIdText = cleanText(
                request.getParameter("roomId")
        );

        Integer roomId = parseInteger(roomIdText);

        VLANDTO formVLAN = new VLANDTO(
                0,
                vlanName,
                subnet,
                purpose,
                roomId
        );

        String error = validateVLAN(
                vlanName,
                subnet,
                purpose,
                roomIdText,
                roomId,
                null
        );

        if (error != null) {
            forwardToVLANForm(
                    request,
                    response,
                    formVLAN,
                    error
            );

            return;
        }

        boolean success = vlanDAO.insert(formVLAN);

        if (!success) {
            forwardToVLANForm(
                    request,
                    response,
                    formVLAN,
                    "Cannot insert VLAN. Please try again."
            );

            return;
        }

        redirectAfterAction(request, response);
    }
    private void updateVLAN(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        Integer vlanId = parseInteger(
                request.getParameter("vlanId")
        );

        String vlanName = cleanText(
                request.getParameter("vlanName")
        );

        String subnet = cleanText(
                request.getParameter("subnet")
        );

        String purpose = cleanText(
                request.getParameter("purpose")
        );

        String roomIdText = cleanText(
                request.getParameter("roomId")
        );

        Integer roomId = parseInteger(roomIdText);

        if (vlanId == null || vlanId <= 0) {
            request.setAttribute(
                    "error",
                    "Invalid VLAN ID."
            );

            listVLANs(request, response);
            return;
        }

        VLANDTO existingVLAN
                = vlanDAO.searchById(vlanId);

        if (existingVLAN == null) {
            request.setAttribute(
                    "error",
                    "VLAN does not exist."
            );

            listVLANs(request, response);
            return;
        }

        VLANDTO formVLAN = new VLANDTO(
                vlanId,
                vlanName,
                subnet,
                purpose,
                roomId
        );

        String error = validateVLAN(
                vlanName,
                subnet,
                purpose,
                roomIdText,
                roomId,
                vlanId
        );

        if (error != null) {
            forwardToVLANForm(
                    request,
                    response,
                    formVLAN,
                    error
            );

            return;
        }

        boolean success = vlanDAO.update(formVLAN);

        if (!success) {
            forwardToVLANForm(
                    request,
                    response,
                    formVLAN,
                    "Cannot update VLAN. Please try again."
            );

            return;
        }

        redirectAfterAction(request, response);
    }

    private void deleteVLAN(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        Integer vlanId = parseInteger(
                request.getParameter("vlanId")
        );

        if (vlanId == null || vlanId <= 0) {
            request.setAttribute(
                    "error",
                    "Invalid VLAN ID."
            );

            listVLANs(request, response);
            return;
        }

        VLANDTO vlan = vlanDAO.searchById(vlanId);

        if (vlan == null) {
            request.setAttribute(
                    "error",
                    "VLAN does not exist."
            );

            listVLANs(request, response);
            return;
        }

        boolean success = vlanDAO.remove(vlan);

        if (!success) {
            request.setAttribute(
                    "error",
                    "Cannot delete this VLAN because it may "
                    + "be assigned to a network device or "
                    + "referenced by another record."
            );

            listVLANs(request, response);
            return;
        }

        redirectAfterAction(request, response);
    }
    private String validateVLAN(
            String vlanName,
            String subnet,
            String purpose,
            String roomIdText,
            Integer roomId,
            Integer currentVlanId) {

        if (vlanName == null) {
            return "VLAN name is required.";
        }

        if (vlanName.length() > 100) {
            return "VLAN name must not exceed 100 characters.";
        }

        if (subnet != null && subnet.length() > 50) {
            return "Subnet must not exceed 50 characters.";
        }

        if (subnet != null && !isValidIPv4CIDR(subnet)) {
            return "Subnet must use CIDR format, for example: "
                    + "192.168.10.0/24.";
        }

        if (purpose != null && purpose.length() > 255) {
            return "Purpose must not exceed 255 characters.";
        }

        /*
         * Nếu người dùng có nhập Room ID:
         * - phải là số nguyên dương
         * - Room phải tồn tại
         */
        if (roomIdText != null) {

            if (roomId == null || roomId <= 0) {
                return "Room ID must be a valid positive number.";
            }

            if (!vlanDAO.roomExists(roomId)) {
                return "Selected room does not exist.";
            }
        }

        /*
         * Kiểm tra tên VLAN và subnet không được trùng.
         * Khi Update thì bỏ qua chính VLAN đang sửa.
         */
        ArrayList<VLANDTO> existingVLANs
                = vlanDAO.ListAll();

        for (VLANDTO existing : existingVLANs) {

            boolean sameRecord
                    = currentVlanId != null
                    && existing.getVlanId() == currentVlanId;

            if (sameRecord) {
                continue;
            }

            if (existing.getVlanName() != null
                    && existing.getVlanName()
                            .equalsIgnoreCase(vlanName)) {

                return "VLAN name already exists.";
            }

            if (subnet != null
                    && existing.getSubnet() != null
                    && existing.getSubnet()
                            .equalsIgnoreCase(subnet)) {

                return "Subnet is already assigned to another VLAN.";
            }
        }

        return null;
    }

    // =====================================================
    // KIỂM TRA SUBNET IPv4 CIDR
    // Ví dụ hợp lệ: 192.168.10.0/24
    // =====================================================
    private boolean isValidIPv4CIDR(String subnet) {

        if (subnet == null) {
            return true;
        }

        String[] cidrParts = subnet.split("/", -1);

        if (cidrParts.length != 2) {
            return false;
        }

        String ipAddress = cidrParts[0];
        String prefixText = cidrParts[1];

        Integer prefix = parseInteger(prefixText);

        if (prefix == null || prefix < 0 || prefix > 32) {
            return false;
        }

        String[] octets = ipAddress.split("\\.", -1);

        if (octets.length != 4) {
            return false;
        }

        for (String octet : octets) {

            Integer value = parseInteger(octet);

            if (value == null || value < 0 || value > 255) {
                return false;
            }
        }

        return true;
    }

    // =====================================================
    // FORWARD LẠI FORM KHI LỖI
    // =====================================================
    private void forwardToVLANForm(
            HttpServletRequest request,
            HttpServletResponse response,
            VLANDTO formVLAN,
            String error)
            throws ServletException, IOException {

        request.setAttribute("error", error);
        request.setAttribute("formVLAN", formVLAN);

        request.setAttribute(
                "rooms",
                roomDAO.ListAll()
        );

        request.setAttribute(
                "returnTo",
                request.getParameter("returnTo")
        );

        RequestDispatcher rd
                = request.getRequestDispatcher("vlan-form.jsp");

        rd.forward(request, response);
    }

    // =====================================================
    // REDIRECT SAU KHI CRUD THÀNH CÔNG
    // =====================================================
    private void redirectAfterAction(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        String returnTo
                = request.getParameter("returnTo");

        String contextPath
                = request.getContextPath();

        if ("dashboard".equals(returnTo)) {
            response.sendRedirect(
                    contextPath
                    + "/staffDashboard.jsp?page=vlan"
            );

            return;
        }

        response.sendRedirect(
                contextPath
                + "/MainController?action=vlanList"
        );
    }

    private Integer parseInteger(String value) {

        if (value == null || value.trim().isEmpty()) {
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
        return "VLAN CRUD Servlet";
    }
}
