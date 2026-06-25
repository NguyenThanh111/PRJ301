package Controller;

import Models.UserDTO;
import Models_DAO.UserDAO;
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@WebServlet(name = "UpdateProfileController", urlPatterns = {"/UpdateProfileController"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 1, // 1 MB
        maxFileSize = 1024 * 1024 * 5, // 5 MB
        maxRequestSize = 1024 * 1024 * 10 // 10 MB
)
public class UpdateProfileController extends HttpServlet {

    private static final String UPLOAD_DIR = "uploads/avatars";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        UserDTO currentUser = (UserDTO) session.getAttribute("user");

        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            String fullName = request.getParameter("fullName");
            Part filePart = request.getPart("avatar");

            boolean updated = false;

            if (fullName != null && !fullName.trim().isEmpty()) {
                currentUser.setFullName(fullName.trim());
                updated = true;
            }

            if (filePart != null && filePart.getSize() > 0) {
                // Ensure upload directory exists
                String applicationPath = request.getServletContext().getRealPath("");
                String uploadFilePath = applicationPath + File.separator + UPLOAD_DIR;
                File uploadDir = new File(uploadFilePath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }

                // Generate a unique file name
                String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                String fileExtension = "";
                if (fileName != null && fileName.contains(".")) {
                    fileExtension = fileName.substring(fileName.lastIndexOf("."));
                }
                String uniqueFileName = "avatar_" + currentUser.getUserId() + "_" + UUID.randomUUID().toString() + fileExtension;

                // Save the file
                filePart.write(uploadFilePath + File.separator + uniqueFileName);

                // Update DTO with relative path
                currentUser.setAvatar(UPLOAD_DIR + "/" + uniqueFileName);
                updated = true;
            }

            if (updated) {
                UserDAO dao = new UserDAO();
                boolean success = dao.update(currentUser);
                if (success) {
                    session.setAttribute("user", currentUser);
                    session.setAttribute("profileSuccessMessage", "Profile updated successfully!");
                } else {
                    session.setAttribute("profileErrorMessage", "Failed to update profile in database.");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("profileErrorMessage", "An error occurred while updating profile.");
        }

        response.sendRedirect("userDashboard.jsp");
    }
}
