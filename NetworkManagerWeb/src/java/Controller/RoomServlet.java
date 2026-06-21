
package Controller;

import Models.RoomDAO;
import Models.RoomDTO;
import java.io.IOException;
import java.util.ArrayList;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class RoomServlet extends HttpServlet {

    private final RoomDAO roomDAO = new RoomDAO();

    protected void processRequest(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String action = request.getParameter("action");

        if (action == null || action.trim().isEmpty()) {
            action = "roomList";
        }

        switch (action) {
            case "roomList":
                listRooms(request, response);
                break;

            case "roomAdd":
                showAddForm(request, response);
                break;

            case "roomEdit":
                showEditForm(request, response);
                break;

            case "roomInsert":
                insertRoom(request, response);
                break;

            case "roomUpdate":
                updateRoom(request, response);
                break;

            case "roomDelete":
                deleteRoom(request, response);
                break;

            default:
                listRooms(request, response);
                break;
        }
    }

    // =========================
    // READ - Hiển thị danh sách
    // =========================
    private void listRooms(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        ArrayList<RoomDTO> rooms = roomDAO.ListAll();

        request.setAttribute("rooms", rooms);

        RequestDispatcher rd
                = request.getRequestDispatcher("room-list.jsp");

        rd.forward(request, response);
    }

    // =========================
    // Hiển thị form thêm
    // =========================
    private void showAddForm(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute(
                "returnTo",
                request.getParameter("returnTo")
        );

        RequestDispatcher rd
                = request.getRequestDispatcher("room-form.jsp");

        rd.forward(request, response);
    }

    
    
    private void showEditForm(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        Integer roomId = parseInteger(
                request.getParameter("id")
        );

        if (roomId == null || roomId <= 0) {
            request.setAttribute(
                    "error",
                    "Invalid room ID."
            );

            listRooms(request, response);
            return;
        }

        RoomDTO room = roomDAO.searchById(roomId);

        if (room == null) {
            request.setAttribute(
                    "error",
                    "Room does not exist."
            );

            listRooms(request, response);
            return;
        }

        request.setAttribute("room", room);

        request.setAttribute(
                "returnTo",
                request.getParameter("returnTo")
        );

        RequestDispatcher rd
                = request.getRequestDispatcher("room-form.jsp");

        rd.forward(request, response);
    }

    
    private void insertRoom(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String roomName = cleanText(
                request.getParameter("roomName")
        );

        String building = cleanText(
                request.getParameter("building")
        );

        Integer floor = parseInteger(
                request.getParameter("floor")
        );

        Integer capacity = parseInteger(
                request.getParameter("capacity")
        );

        RoomDTO formRoom = new RoomDTO(
                0,
                roomName,
                building,
                floor == null ? 0 : floor,
                capacity == null ? 0 : capacity
        );

        String error = validateRoom(
                roomName,
                building,
                floor,
                capacity
        );

        if (error != null) {
            forwardToRoomForm(
                    request,
                    response,
                    formRoom,
                    error
            );

            return;
        }

        boolean success = roomDAO.insert(formRoom);

        if (!success) {
            forwardToRoomForm(
                    request,
                    response,
                    formRoom,
                    "Cannot insert room. Please try again."
            );

            return;
        }

        redirectAfterAction(request, response);
    }

    // =========================
    // UPDATE - Cập nhật phòng
    // =========================
    private void updateRoom(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        Integer roomId = parseInteger(
                request.getParameter("roomId")
        );

        String roomName = cleanText(
                request.getParameter("roomName")
        );

        String building = cleanText(
                request.getParameter("building")
        );

        Integer floor = parseInteger(
                request.getParameter("floor")
        );

        Integer capacity = parseInteger(
                request.getParameter("capacity")
        );

        if (roomId == null || roomId <= 0) {
            request.setAttribute(
                    "error",
                    "Invalid room ID."
            );

            listRooms(request, response);
            return;
        }

        RoomDTO existingRoom
                = roomDAO.searchById(roomId);

        if (existingRoom == null) {
            request.setAttribute(
                    "error",
                    "Room does not exist."
            );

            listRooms(request, response);
            return;
        }

        RoomDTO formRoom = new RoomDTO(
                roomId,
                roomName,
                building,
                floor == null ? 0 : floor,
                capacity == null ? 0 : capacity
        );

        String error = validateRoom(
                roomName,
                building,
                floor,
                capacity
        );

        if (error != null) {
            forwardToRoomForm(
                    request,
                    response,
                    formRoom,
                    error
            );

            return;
        }

        boolean success = roomDAO.update(formRoom);

        if (!success) {
            forwardToRoomForm(
                    request,
                    response,
                    formRoom,
                    "Cannot update room. Please try again."
            );

            return;
        }

        redirectAfterAction(request, response);
    }

    // =========================
    // DELETE - Xóa phòng
    // =========================
    private void deleteRoom(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        Integer roomId = parseInteger(
                request.getParameter("roomId")
        );

        if (roomId == null || roomId <= 0) {
            request.setAttribute(
                    "error",
                    "Invalid room ID."
            );

            listRooms(request, response);
            return;
        }

        RoomDTO room = roomDAO.searchById(roomId);

        if (room == null) {
            request.setAttribute(
                    "error",
                    "Room does not exist."
            );

            listRooms(request, response);
            return;
        }

        boolean success = roomDAO.remove(room);

        if (!success) {
            request.setAttribute(
                    "error",
                    "Cannot delete this room because it may be used "
                    + "by a router, VLAN, access point, switch, "
                    + "or another network device."
            );

            listRooms(request, response);
            return;
        }

        redirectAfterAction(request, response);
    }

    // =========================
    // Validation riêng của Room
    // =========================
    private String validateRoom(String roomName,
            String building,
            Integer floor,
            Integer capacity) {

        if (roomName == null) {
            return "Room name is required.";
        }

        if (roomName.length() > 100) {
            return "Room name must not exceed 100 characters.";
        }

        if (building != null && building.length() > 100) {
            return "Building must not exceed 100 characters.";
        }

        if (floor == null) {
            return "Floor must be a valid number.";
        }

        if (floor < 1) {
            return "Floor must be at least 1.";
        }

        if (capacity == null) {
            return "Capacity must be a valid number.";
        }

        if (capacity < 0) {
            return "Capacity cannot be negative.";
        }

        return null;
    }

    // =========================
    // Quay lại form khi có lỗi
    // =========================
    private void forwardToRoomForm(
            HttpServletRequest request,
            HttpServletResponse response,
            RoomDTO formRoom,
            String error)
            throws ServletException, IOException {

        request.setAttribute("error", error);
        request.setAttribute("formRoom", formRoom);

        request.setAttribute(
                "returnTo",
                request.getParameter("returnTo")
        );

        RequestDispatcher rd
                = request.getRequestDispatcher("room-form.jsp");

        rd.forward(request, response);
    }

    // =========================
    // Chuyển trang sau CRUD
    // =========================
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
                    + "/staffDashboard.jsp?page=rooms"
            );

            return;
        }

        response.sendRedirect(
                contextPath
                + "/MainController?action=roomList"
        );
    }

    // =========================
    // Chuyển String thành Integer
    // =========================
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

    // =========================
    // Xóa khoảng trắng đầu/cuối
    // Chuỗi trống chuyển thành null
    // =========================
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
        return "Room CRUD Servlet";
    }
}
