/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Models_DAO;

import Models.MaintenanceScheduleDTO;
import Utils.DbUtils;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;

/**
 *
 * @author nvtv0
 */
public class MaintenanceScheduleDAO implements IDAO<MaintenanceScheduleDTO, Integer> {

    private MaintenanceScheduleDTO mapRow(ResultSet rs) throws SQLException {
        return new MaintenanceScheduleDTO(
                rs.getInt("maintenance_id"),
                rs.getString("title"),
                rs.getString("description"),
                rs.getTimestamp("start_time"),
                rs.getTimestamp("end_time"),
                rs.getString("status")
        );
    }
    
    @Override
    public boolean insert(MaintenanceScheduleDTO t) {
        String sql = "INSERT INTO MaintenanceSchedule (title, description, start_time, end_time, status) "
                   + "VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, t.getTitle());
            ps.setString(2, t.getDescription());
            ps.setTimestamp(3, t.getStartTime());
            if (t.getEndTime() != null) ps.setTimestamp(4, t.getEndTime());
            else ps.setNull(4, Types.TIMESTAMP);
            ps.setString(5, t.getStatus() != null ? t.getStatus() : "PLANNED");
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean remove(MaintenanceScheduleDTO t) {
        String sql = "DELETE FROM MaintenanceSchedule WHERE maintenance_id = ?";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, t.getMaintenanceId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean update(MaintenanceScheduleDTO t) {
        String sql = "UPDATE MaintenanceSchedule SET title=?, description=?, start_time=?, end_time=?, status=? "
                   + "WHERE maintenance_id=?";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, t.getTitle());
            ps.setString(2, t.getDescription());
            ps.setTimestamp(3, t.getStartTime());
            if (t.getEndTime() != null) ps.setTimestamp(4, t.getEndTime());
            else ps.setNull(4, Types.TIMESTAMP);
            ps.setString(5, t.getStatus());
            ps.setInt(6, t.getMaintenanceId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public ArrayList<MaintenanceScheduleDTO> ListAll() {
        ArrayList<MaintenanceScheduleDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM MaintenanceSchedule ORDER BY start_time DESC";
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
    public MaintenanceScheduleDTO searchById(Integer id) {
        String sql = "SELECT * FROM MaintenanceSchedule WHERE maintenance_id = ?";
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

    public ArrayList<MaintenanceScheduleDTO> findUpcoming() {
        ArrayList<MaintenanceScheduleDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM MaintenanceSchedule "
                   + "WHERE start_time >= GETDATE() AND status IN ('PLANNED','IN_PROGRESS') "
                   + "ORDER BY start_time ASC";
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

    public boolean updateStatus(int maintenanceId, String newStatus) {
        String sql = "UPDATE MaintenanceSchedule SET status=? WHERE maintenance_id=?";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, maintenanceId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

}

