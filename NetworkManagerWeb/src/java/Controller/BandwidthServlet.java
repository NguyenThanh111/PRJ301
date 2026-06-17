package Controller;

import Models.BandwidthUsageDAO;
import Models.BandwidthUsageDTO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class BandwidthServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) {
            action = "bandwidthList";
        }

        BandwidthUsageDAO dao = new BandwidthUsageDAO();

        try {
            switch (action) {
                case "bandwidthInsert":
                    int deviceId = Integer.parseInt(request.getParameter("deviceId"));
                    double uploadSpeed = Double.parseDouble(request.getParameter("uploadSpeed"));
                    double downloadSpeed = Double.parseDouble(request.getParameter("downloadSpeed"));

                    BandwidthUsageDTO newUsage = new BandwidthUsageDTO();
                    newUsage.setDeviceId(deviceId);
                    newUsage.setUploadSpeed(uploadSpeed);
                    newUsage.setDownloadSpeed(downloadSpeed);

                    dao.insert(newUsage);
                    response.sendRedirect("staffDashboard.jsp?page=bandwidth");
                    break;

                case "bandwidthDelete":
                    int usageId = Integer.parseInt(request.getParameter("usageId"));
                    BandwidthUsageDTO dto = new BandwidthUsageDTO();
                    dto.setUsageId(usageId);
                    dao.remove(dto);
                    response.sendRedirect("staffDashboard.jsp?page=bandwidth");
                    break;
                    
                case "bandwidthAdd":
                    response.sendRedirect("bandwidth-form.jsp");
                    break;

                default:
                    response.sendRedirect("staffDashboard.jsp?page=bandwidth");
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("staffDashboard.jsp?page=bandwidth&error=true");
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
        return "Bandwidth Servlet";
    }
}
