package Controller;

import Models_DAO.MaintenanceScheduleDAO;
import Models.MaintenanceScheduleDTO;
import java.io.IOException;
import java.sql.Timestamp;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class MaintenanceServlet extends HttpServlet {

    private MaintenanceScheduleDAO dao = new MaintenanceScheduleDAO();

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) {
            action = "maintenanceList";
        }

        try {
            switch (action) {
                case "maintenanceInsert":
                    insertMaintenance(request, response);
                    break;
                case "maintenanceDelete":
                    deleteMaintenance(request, response);
                    break;
                case "maintenanceComplete":
                    completeMaintenance(request, response);
                    break;
                case "maintenanceEdit":
                    showEditForm(request, response);
                    break;
                case "maintenanceUpdate":
                    updateMaintenance(request, response);
                    break;
                case "maintenanceAdd":
                    response.sendRedirect("maintenance-form.jsp");
                    break;
                default:
                    response.sendRedirect("staffDashboard.jsp?page=maintenance");
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("staffDashboard.jsp?page=maintenance&error=true");
        }
    }

    private void insertMaintenance(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String startTimeStr = request.getParameter("startTime");
        String endTimeStr = request.getParameter("endTime");
        String status = request.getParameter("status");

        MaintenanceScheduleDTO newSchedule = new MaintenanceScheduleDTO();
        newSchedule.setTitle(title);
        newSchedule.setDescription(description);
        if (startTimeStr != null && !startTimeStr.isEmpty()) {
            newSchedule.setStartTime(Timestamp.valueOf(startTimeStr.replace("T", " ") + ":00"));
        }
        if (endTimeStr != null && !endTimeStr.isEmpty()) {
            newSchedule.setEndTime(Timestamp.valueOf(endTimeStr.replace("T", " ") + ":00"));
        }
        newSchedule.setStatus(status != null ? status : "PLANNED");

        dao.insert(newSchedule);
        response.sendRedirect("staffDashboard.jsp?page=maintenance");
    }

    private void deleteMaintenance(HttpServletRequest request, HttpServletResponse response) throws Exception {
        int deleteId = Integer.parseInt(request.getParameter("maintenanceId"));
        MaintenanceScheduleDTO dto = new MaintenanceScheduleDTO();
        dto.setMaintenanceId(deleteId);
        dao.remove(dto);
        response.sendRedirect("staffDashboard.jsp?page=maintenance");
    }

    private void completeMaintenance(HttpServletRequest request, HttpServletResponse response) throws Exception {
        int completeId = Integer.parseInt(request.getParameter("maintenanceId"));
        dao.updateStatus(completeId, "COMPLETED");
        response.sendRedirect("staffDashboard.jsp?page=maintenance");
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws Exception {
        int editId = Integer.parseInt(request.getParameter("maintenanceId"));
        MaintenanceScheduleDTO scheduleToEdit = dao.searchById(editId);
        request.setAttribute("schedule", scheduleToEdit);
        request.getRequestDispatcher("maintenance-edit.jsp").forward(request, response);
    }

    private void updateMaintenance(HttpServletRequest request, HttpServletResponse response) throws Exception {
        int updateId = Integer.parseInt(request.getParameter("maintenanceId"));
        String updateTitle = request.getParameter("title");
        String updateDesc = request.getParameter("description");
        String updateStart = request.getParameter("startTime");
        String updateEnd = request.getParameter("endTime");
        String updateStatus = request.getParameter("status");

        MaintenanceScheduleDTO updatedSchedule = new MaintenanceScheduleDTO();
        updatedSchedule.setMaintenanceId(updateId);
        updatedSchedule.setTitle(updateTitle);
        updatedSchedule.setDescription(updateDesc);
        if (updateStart != null && !updateStart.isEmpty()) {
            updatedSchedule.setStartTime(Timestamp.valueOf(updateStart.replace("T", " ") + ":00"));
        }
        if (updateEnd != null && !updateEnd.isEmpty()) {
            updatedSchedule.setEndTime(Timestamp.valueOf(updateEnd.replace("T", " ") + ":00"));
        }
        updatedSchedule.setStatus(updateStatus);

        dao.update(updatedSchedule);
        response.sendRedirect("staffDashboard.jsp?page=maintenance");
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
        return "Maintenance Servlet";
    }
}
