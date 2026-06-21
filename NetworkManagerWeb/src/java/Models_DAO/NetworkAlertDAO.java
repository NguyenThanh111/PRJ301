/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Models_DAO;

import Models.NetworkAlertDTO;
import Utils.DbUtils;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.ArrayList;

/**
 *
 * @author nvtv0
 */
public class NetworkAlertDAO implements IDAO<NetworkAlertDTO, Integer>{
    private NetworkAlertDTO mapRow(ResultSet rs) throws SQLException {
        int alertId       = rs.getInt("alert_id");
        String alertType  = rs.getString("alert_type");
        String message    = rs.getString("message");
        String severity   = rs.getString("severity");
        Timestamp created = rs.getTimestamp("created_at");

        Integer routerId = (Integer) rs.getObject("router_id");
        Integer apId     = (Integer) rs.getObject("ap_id");
        Integer switchId = (Integer) rs.getObject("switch_id");

        return new NetworkAlertDTO(alertId, alertType, message, severity, created, routerId, apId, switchId);
    }

    @Override
    public boolean insert(NetworkAlertDTO t) {
        String sql = "INSERT INTO NetworkAlert (alert_type, message, severity, created_at, router_id, ap_id, switch_id) "
                   + "VALUES (?, ?, ?, GETDATE(), ?, ?, ?)";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, t.getAlertType());
            ps.setString(2, t.getMessage());
            ps.setString(3, t.getSeverity() != null ? t.getSeverity() : "INFO");
            if (t.getRouterId() != null) ps.setInt(4, t.getRouterId()); else ps.setNull(4, Types.INTEGER);
            if (t.getApId()     != null) ps.setInt(5, t.getApId());     else ps.setNull(5, Types.INTEGER);
            if (t.getSwitchId() != null) ps.setInt(6, t.getSwitchId()); else ps.setNull(6, Types.INTEGER);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean remove(NetworkAlertDTO t) {
        String sql = "DELETE FROM NetworkAlert WHERE alert_id = ?";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, t.getAlertId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean update(NetworkAlertDTO t) {
        String sql = "UPDATE NetworkAlert SET alert_type=?, message=?, severity=?, router_id=?, ap_id=?, switch_id=? "
                   + "WHERE alert_id=?";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, t.getAlertType());
            ps.setString(2, t.getMessage());
            ps.setString(3, t.getSeverity());
            if (t.getRouterId() != null) ps.setInt(4, t.getRouterId()); else ps.setNull(4, Types.INTEGER);
            if (t.getApId()     != null) ps.setInt(5, t.getApId());     else ps.setNull(5, Types.INTEGER);
            if (t.getSwitchId() != null) ps.setInt(6, t.getSwitchId()); else ps.setNull(6, Types.INTEGER);
            ps.setInt(7, t.getAlertId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public ArrayList<NetworkAlertDTO> ListAll() {
        ArrayList<NetworkAlertDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM NetworkAlert ORDER BY created_at DESC";
        try (Connection conn = DbUtils.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public NetworkAlertDTO searchById(Integer id) {
        String sql = "SELECT * FROM NetworkAlert WHERE alert_id = ?";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
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

    public ArrayList<NetworkAlertDTO> findByDevice(Integer routerId, Integer apId, Integer switchId) {
        ArrayList<NetworkAlertDTO> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM NetworkAlert WHERE 1=1");
        if (routerId != null) sql.append(" AND router_id = ?");
        if (apId     != null) sql.append(" AND ap_id = ?");
        if (switchId != null) sql.append(" AND switch_id = ?");
        sql.append(" ORDER BY created_at DESC");

        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (routerId != null) ps.setInt(idx++, routerId);
            if (apId     != null) ps.setInt(idx++, apId);
            if (switchId != null) ps.setInt(idx++, switchId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public ArrayList<NetworkAlertDTO> findBySeverity(String severity) {
        ArrayList<NetworkAlertDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM NetworkAlert WHERE severity = ? ORDER BY created_at DESC";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, severity);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean resolveAlert(int alertId) {
        String sql = "DELETE FROM NetworkAlert WHERE alert_id = ?";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, alertId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    
    public int countAll() {
    String sql = "SELECT COUNT(*) AS total FROM NetworkAlert";
    try (Connection conn = DbUtils.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
            return rs.getInt("total");
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return 0;
}

}
