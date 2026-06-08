package Models;

import Utils.DbUtils;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;

public class AccessPointDAO implements IDAO<AccessPointDTO, Integer> {

    private AccessPointDTO mapRow(ResultSet rs) throws SQLException {
        return new AccessPointDTO(
                rs.getInt("ap_id"),
                rs.getString("ap_name"),
                rs.getString("ssid"),
                rs.getString("ip_address"),
                rs.getInt("connected_users"),
                rs.getString("status"),
                rs.getString("location"),
                rs.getInt("room_id")
        );
    }

    @Override
    public boolean insert(AccessPointDTO t) {
        if (t.getConnectedUsers() < 0) {
            return false;
        }

        String sql = "INSERT INTO AccessPoint "
                + "(ap_name, ssid, ip_address, connected_users, status, location, room_id) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try {
            Connection connect = DbUtils.getConnection();
            PreparedStatement ps = connect.prepareStatement(sql);
            ps.setString(1, t.getApName());
            ps.setString(2, t.getSsid());
            ps.setString(3, t.getIpAddress());
            ps.setInt(4, t.getConnectedUsers());
            ps.setString(5, t.getStatus());
            ps.setString(6, t.getLocation());
            ps.setInt(7, t.getRoomId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean update(AccessPointDTO t) {
        if (t.getConnectedUsers() < 0) {
            return false;
        }

        String sql = "UPDATE AccessPoint SET "
                + "ap_name = ?, ssid = ?, ip_address = ?, "
                + "connected_users = ?, status = ?, location = ?, room_id = ? "
                + "WHERE ap_id = ?";
        try {
            Connection connect = DbUtils.getConnection();
            PreparedStatement ps = connect.prepareStatement(sql);
            ps.setString(1, t.getApName());
            ps.setString(2, t.getSsid());
            ps.setString(3, t.getIpAddress());
            ps.setInt(4, t.getConnectedUsers());
            ps.setString(5, t.getStatus());
            ps.setString(6, t.getLocation());
            ps.setInt(7, t.getRoomId());
            ps.setInt(8, t.getApId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean remove(AccessPointDTO t) {
        return delete(t.getApId());
    }

    public boolean delete(int apId) {
        String sql = "UPDATE AccessPoint SET status = 'INACTIVE' WHERE ap_id = ?";
        try (
                Connection conn = DbUtils.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, apId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public ArrayList<AccessPointDTO> ListAll() {
        return findAll();
    }

    public ArrayList<AccessPointDTO> findAll() {
        ArrayList<AccessPointDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM AccessPoint";
        try {
            Connection connect = DbUtils.getConnection();
            Statement st = connect.createStatement();
            ResultSet rs = st.executeQuery(sql);
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public AccessPointDTO searchById(Integer id) {
        String sql = "SELECT * FROM AccessPoint WHERE ap_id = ?";
        try {
            Connection connect = DbUtils.getConnection();
            PreparedStatement ps = connect.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public int countConnectedUsers() {
        String sql = "SELECT SUM(connected_users) AS total_connected_users FROM AccessPoint";
        try {
            Connection connect = DbUtils.getConnection();
            Statement st = connect.createStatement();
            ResultSet rs = st.executeQuery(sql);
            if (rs.next()) {
                return rs.getInt("total_connected_users");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean updateSSID(int apId, String ssid) {
        String sql = "UPDATE AccessPoint SET ssid = ? WHERE ap_id = ?";
        try {
            Connection connect = DbUtils.getConnection();
            PreparedStatement ps = connect.prepareStatement(sql);
            ps.setString(1, ssid);
            ps.setInt(2, apId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
