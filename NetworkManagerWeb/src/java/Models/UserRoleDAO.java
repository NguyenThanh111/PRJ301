
package Models;

import Utils.DbUtils;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class UserRoleDAO {

    // HELPER: maprow -> UserDTO
    private UserDTO mapRowUser(ResultSet rs) throws SQLException {
        UserDTO user = new UserDTO();
        user.setUserId(rs.getInt("user_id"));
        user.setUserName(rs.getString("username"));
        user.setPassword(rs.getString("password"));
        user.setFullName(rs.getString("full_name"));
        user.setEmail(rs.getString("email"));
        user.setStatus(user.takeStatus(rs.getString("status")));

        return user;
    }

    // HELPER: maprow -> UserRoleDTO
    private UserRoleDTO mapRowUserRole(ResultSet rs) throws SQLException {
        UserRoleDTO userRole = new UserRoleDTO();
        userRole.setUserId(rs.getInt("user_id"));
        userRole.setRoleId(rs.getInt("role_id"));
        userRole.setAssigedAt(rs.getTimestamp("assigned_at"));

        return userRole;
    }

    // ===================== Them UserRole =======================
    public boolean assignRole(UserRoleDTO dto) {
        String sql = "INSERT INTO UserRole (user_id, role_id) VALUES (?, ?)";

        try {
            Connection connect = DbUtils.getConnection();
            PreparedStatement ps = connect.prepareStatement(sql);

            ps.setInt(1, dto.getUserId());
            ps.setInt(2, dto.getRoleId());
            // assigned_at để DB tự set DEFAULT GETDATE()

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.err.println("[assignRole] Error: " + e.getMessage());
            return false;
        }
    }

    // OverLoad assignRole
    public boolean assignRole(int userId, int roleId) {
        return assignRole(new UserRoleDTO(userId, roleId));
    }

    // ==================== Xoa Role cua User bang Id ===================
    public boolean removeRole(int userId, int roleId) {
        String sql = "DELETE FROM UserRole WHERE user_id = ? AND role_id = ?";
        try {
            Connection connect = DbUtils.getConnection();
            PreparedStatement ps = connect.prepareStatement(sql);

            ps.setInt(1, userId);
            ps.setInt(2, roleId);
            // assigned_at để DB tự set DEFAULT GETDATE()

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.err.println("[assignRole] Error: " + e.getMessage());
            return false;
        }
    }

    // ==================== Xoa tat ca Role cua User ===================
    public boolean removeAllRoles(int userId) {
        String sql = "DELETE FROM UserRole WHERE user_id = ?";
        try {
            Connection connect = DbUtils.getConnection();
            PreparedStatement ps = connect.prepareStatement(sql);
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("[removeAllRoles] Error: " + e.getMessage());
            return false;
        }
    }

    // ================ Tim kiem List User co cung Role ===============
    public ArrayList<UserDTO> findUserByRole(int roleId) {
        ArrayList<UserDTO> list = new ArrayList<>();

        String sql = "SELECT u.user_id, u.username, u.password, "
                + "       u.full_name, u.email, u.status "
                + "FROM [User] u "
                + "JOIN UserRole ur ON u.user_id = ur.user_id "
                + "WHERE ur.role_id = ?";

        try {
            Connection connect = DbUtils.getConnection();
            PreparedStatement ps = connect.prepareStatement(sql);

            ps.setInt(1, roleId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRowUser(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // ================ Tim role cua User bang user_id ==================
    public String findRoleByUser(int userId) {
        String sql = "SELECT R.role_name "
                + "FROM UserRole UR "
                + "JOIN Role R ON UR.role_id = R.role_id "
                + "WHERE UR.user_id = ?";
        try {
            Connection connect = DbUtils.getConnection();
            PreparedStatement ps = connect.prepareStatement(sql);

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getString("role_name");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return "";
    }

    //
    public boolean hasRole(int userId, String roleName) {
        String sql = "SELECT *"
                + "FROM UserRole ur"
                + "JOIN Role r ON ur.role_id = r.role_id"
                + "WHERE ur.user_id = ? AND r.role_name = ?";
        try {
            Connection connect = DbUtils.getConnection();
            PreparedStatement ps = connect.prepareStatement(sql);

            ps.setInt(1, userId);
            ps.setString(2, roleName);

            ResultSet rs = ps.executeQuery();
            return rs.next();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
