package Controller;

import Models.MaintenanceScheduleDAO;
import Models.MaintenanceScheduleDTO;
import java.io.IOException;
import java.sql.Timestamp;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class MaintenanceServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) {
            action = "maintenanceList";
        }

        MaintenanceScheduleDAO dao = new MaintenanceScheduleDAO();

        try {
            switch (action) {
                case "maintenanceInsert":
                    String title = request.getParameter("title");
                    String description = request.getParameter("description");
                    String startTimeStr = request.getParameter("startTime");
                    String endTimeStr = request.getParameter("endTime");
                    String status = request.getParameter("status");

                    MaintenanceScheduleDTO newSchedule = new MaintenanceScheduleDTO();
                    newSchedule.setTitle(title);
                    newSchedule.setDescription(description);
                    if (startTimeStr != null && !startTimeStr.isEmpty()) {
                        // html datetime-local format is yyyy-MM-ddTHH:mm
                        newSchedule.setStartTime(Timestamp.valueOf(startTimeStr.replace("T", " ") + ":00"));
                    }
                    if (endTimeStr != null && !endTimeStr.isEmpty()) {
                        newSchedule.setEndTime(Timestamp.valueOf(endTimeStr.replace("T", " ") + ":00"));
                    }
                    newSchedule.setStatus(status != null ? status : "PLANNED");

                    dao.insert(newSchedule);
                    response.sendRedirect("staffDashboard.jsp?page=maintenance");
                    break;

                case "maintenanceDelete":
                    int deleteId = Integer.parseInt(request.getParameter("maintenanceId"));
                    MaintenanceScheduleDTO dto = new MaintenanceScheduleDTO();
                    dto.setMaintenanceId(deleteId);
                    dao.remove(dto);
                    response.sendRedirect("staffDashboard.jsp?page=maintenance");
                    break;
                    
                case "maintenanceComplete":
                    int completeId = Integer.parseInt(request.getParameter("maintenanceId"));
                    dao.updateStatus(completeId, "COMPLETED");
                    response.sendRedirect("staffDashboard.jsp?page=maintenance");
                    break;
                    
                case "maintenanceEdit":
                    int editId = Integer.parseInt(request.getParameter("maintenanceId"));
                    MaintenanceScheduleDTO scheduleToEdit = dao.searchById(editId);
                    request.setAttribute("schedule", scheduleToEdit);
                    request.getRequestDispatcher("maintenance-edit.jsp").forward(request, response);
                    break;
                    
                case "maintenanceUpdate":
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
