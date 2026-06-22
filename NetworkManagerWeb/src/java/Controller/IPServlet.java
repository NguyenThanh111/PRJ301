
package Controller;

import Models_DAO.IPAddressManagementDAO;
import Models.IPAddressManagementDTO;
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

    private final IPAddressManagementDAO ipDAO
            = new IPAddressManagementDAO();

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

            default:
                listIPs(request, response);
                break;
        }
    }

    private void listIPs(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        final int pageSize = 8;

        Integer pageValue = parseInteger(
                request.getParameter("page")
        );

        int currentPage = 1;

        if (pageValue != null && pageValue > 0) {
            currentPage = pageValue;
        }

        long totalRecords = ipDAO.countAllIPs();

        int totalPages = (int) Math.ceil(
                (double) totalRecords / pageSize
        );

        if (totalPages > 0
                && currentPage > totalPages) {

            currentPage = totalPages;
        }

        ArrayList<IPAddressManagementDTO> ipList
                = ipDAO.getIPsByPage(
                        currentPage,
                        pageSize
                );

        long availableCount
                = ipDAO.countByStatus("AVAILABLE");

        long assignedCount
                = ipDAO.countByStatus("ASSIGNED");

        request.setAttribute("ipList", ipList);
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
