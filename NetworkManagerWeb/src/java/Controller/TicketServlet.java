package Controller;

import Models.NetworkDeviceDTO;
import Models.SupportTicketDTO;
import Models.UserDTO;
import Models_DAO.NetworkDeviceDAO;
import Models_DAO.SupportTicketDAO;
import Models_DAO.UserDAO;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(
        name = "TicketServlet",
        urlPatterns = {"/TicketServlet"}
)
public class TicketServlet extends HttpServlet {

    private final SupportTicketDAO ticketDAO = new SupportTicketDAO();
    private final UserDAO userDAO = new UserDAO();
    private final NetworkDeviceDAO deviceDAO = new NetworkDeviceDAO();

    protected void processRequest(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String action = request.getParameter("action");

        if (action == null || action.trim().isEmpty()) {
            action = "ticketList";
        }

        switch (action) {
            case "ticketList":
                listTickets(request, response);
                break;

            case "ticketAdd":
                showAddForm(request, response);
                break;

            case "ticketEdit":
                showEditForm(request, response);
                break;

            case "ticketInsert":
                insertTicket(request, response);
                break;

            case "ticketUpdate":
                updateTicket(request, response);
                break;

            case "ticketUpdateStatus":
                updateTicketStatus(request, response);
                break;

            case "ticketDelete":
                deleteTicket(request, response);
                break;

            default:
                listTickets(request, response);
                break;
        }
    }

    private void listTickets(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        ArrayList<SupportTicketDTO> tickets = ticketDAO.ListAll();
        request.setAttribute("tickets", tickets);

        RequestDispatcher rd
                = request.getRequestDispatcher("ticket-list.jsp");

        rd.forward(request, response);
    }

    private void showAddForm(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("returnTo", request.getParameter("returnTo"));
        loadTicketFormOptions(request);

        RequestDispatcher rd
                = request.getRequestDispatcher("ticket-form.jsp");

        rd.forward(request, response);
    }

    private void showEditForm(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        Integer ticketId = parseInteger(request.getParameter("id"));

        if (ticketId == null || ticketId <= 0) {
            request.setAttribute("error", "Invalid ticket ID.");
            listTickets(request, response);
            return;
        }

        SupportTicketDTO ticket = ticketDAO.searchById(ticketId);

        if (ticket == null) {
            request.setAttribute("error", "Ticket does not exist.");
            listTickets(request, response);
            return;
        }

        request.setAttribute("ticket", ticket);
        request.setAttribute("returnTo", request.getParameter("returnTo"));
        loadTicketFormOptions(request);

        RequestDispatcher rd
                = request.getRequestDispatcher("ticket-form.jsp");

        rd.forward(request, response);
    }

    private void insertTicket(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String title = cleanText(request.getParameter("title"));
        String description = cleanText(request.getParameter("description"));
        String status = cleanText(request.getParameter("status"));
        Integer createdBy = parseInteger(request.getParameter("createdBy"));
        Integer deviceId = parseInteger(request.getParameter("deviceId"));

        if (status == null) {
            status = "OPEN";
        }

        SupportTicketDTO formTicket = new SupportTicketDTO(
                0,
                title,
                description,
                status,
                new Date(),
                createdBy == null ? 0 : createdBy,
                deviceId
        );

        String error = validateTicket(title, status, createdBy, deviceId);

        if (error != null) {
            forwardToTicketForm(request, response, formTicket, error);
            return;
        }

        boolean success = ticketDAO.insert(formTicket);

        if (!success) {
            forwardToTicketForm(
                    request,
                    response,
                    formTicket,
                    "Cannot insert ticket. Please check User ID and Device ID."
            );
            return;
        }

        redirectAfterAction(request, response);
    }

    private void updateTicket(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        Integer ticketId = parseInteger(request.getParameter("ticketId"));
        String title = cleanText(request.getParameter("title"));
        String description = cleanText(request.getParameter("description"));
        String status = cleanText(request.getParameter("status"));
        Integer createdBy = parseInteger(request.getParameter("createdBy"));
        Integer deviceId = parseInteger(request.getParameter("deviceId"));

        if (ticketId == null || ticketId <= 0) {
            request.setAttribute("error", "Invalid ticket ID.");
            listTickets(request, response);
            return;
        }

        SupportTicketDTO existingTicket = ticketDAO.searchById(ticketId);

        if (existingTicket == null) {
            request.setAttribute("error", "Ticket does not exist.");
            listTickets(request, response);
            return;
        }

        SupportTicketDTO formTicket = new SupportTicketDTO(
                ticketId,
                title,
                description,
                status,
                existingTicket.getCreatedDate(),
                createdBy == null ? 0 : createdBy,
                deviceId
        );

        String error = validateTicket(title, status, createdBy, deviceId);

        if (error != null) {
            forwardToTicketForm(request, response, formTicket, error);
            return;
        }

        boolean success = ticketDAO.update(formTicket);

        if (!success) {
            forwardToTicketForm(
                    request,
                    response,
                    formTicket,
                    "Cannot update ticket. Please check User ID and Device ID."
            );
            return;
        }

        redirectAfterAction(request, response);
    }

    private void updateTicketStatus(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        Integer ticketId = parseInteger(request.getParameter("ticketId"));
        String status = cleanText(request.getParameter("status"));

        if (ticketId == null || ticketId <= 0) {
            request.setAttribute("error", "Invalid ticket ID.");
            listTickets(request, response);
            return;
        }

        String error = validateStatus(status);

        if (error != null) {
            request.setAttribute("error", error);
            listTickets(request, response);
            return;
        }

        boolean success = ticketDAO.updateStatus(ticketId, status);

        if (!success) {
            request.setAttribute("error", "Cannot update ticket status.");
            listTickets(request, response);
            return;
        }

        redirectAfterAction(request, response);
    }

    private void deleteTicket(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        Integer ticketId = parseInteger(request.getParameter("ticketId"));

        if (ticketId == null || ticketId <= 0) {
            request.setAttribute("error", "Invalid ticket ID.");
            listTickets(request, response);
            return;
        }

        SupportTicketDTO ticket = ticketDAO.searchById(ticketId);

        if (ticket == null) {
            request.setAttribute("error", "Ticket does not exist.");
            listTickets(request, response);
            return;
        }

        boolean success = ticketDAO.delete(ticketId);

        if (!success) {
            request.setAttribute("error", "Cannot delete ticket.");
            listTickets(request, response);
            return;
        }

        redirectAfterAction(request, response);
    }

    private String validateTicket(String title,
            String status,
            Integer createdBy,
            Integer deviceId) {

        if (title == null) {
            return "Title is required.";
        }

        if (title.length() > 150) {
            return "Title must not exceed 150 characters.";
        }

        String statusError = validateStatus(status);

        if (statusError != null) {
            return statusError;
        }

        if (createdBy == null || createdBy <= 0) {
            return "Please choose a valid user.";
        }

        if (deviceId != null && deviceId <= 0) {
            return "Please choose a valid device.";
        }

        UserDTO user = userDAO.searchById(createdBy);

        if (user == null) {
            return "Selected user does not exist.";
        }

        if (deviceId != null) {
            NetworkDeviceDTO device = deviceDAO.searchById(deviceId);

            if (device == null) {
                return "Selected device does not exist.";
            }
        }

        return null;
    }

    private String validateStatus(String status) {
        if (status == null) {
            return "Status is required.";
        }

        if (!"OPEN".equals(status)
                && !"IN_PROGRESS".equals(status)
                && !"RESOLVED".equals(status)
                && !"CLOSED".equals(status)) {

            return "Status must be OPEN, IN_PROGRESS, RESOLVED, or CLOSED.";
        }

        return null;
    }

    private void forwardToTicketForm(
            HttpServletRequest request,
            HttpServletResponse response,
            SupportTicketDTO formTicket,
            String error)
            throws ServletException, IOException {

        request.setAttribute("error", error);
        request.setAttribute("formTicket", formTicket);
        request.setAttribute("returnTo", request.getParameter("returnTo"));
        loadTicketFormOptions(request);

        RequestDispatcher rd
                = request.getRequestDispatcher("ticket-form.jsp");

        rd.forward(request, response);
    }

    private void redirectAfterAction(HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        String returnTo = request.getParameter("returnTo");
        String contextPath = request.getContextPath();

        if ("dashboard".equals(returnTo)) {
            response.sendRedirect(
                    contextPath + "/staffDashboard.jsp?page=tickets"
            );
            return;
        }

        response.sendRedirect(
                contextPath + "/MainController?action=ticketList"
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

    private void loadTicketFormOptions(HttpServletRequest request) {
        request.setAttribute("users", userDAO.ListAll());
        request.setAttribute("devices", deviceDAO.ListAll());
    }

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Support Ticket Servlet";
    }
}
