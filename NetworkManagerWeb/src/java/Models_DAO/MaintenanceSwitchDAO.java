/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Models_DAO;

import Utils.DbUtils;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

/**
 *
 * @author nvtv0
 */
public class MaintenanceSwitchDAO {

    public boolean addSwitch(int maintenanceId, int switchId) {
        String sql = "INSERT INTO MaintenanceSwitch (maintenance_id, switch_id) VALUES (?, ?)";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, maintenanceId);
            ps.setInt(2, switchId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean removeSwitch(int maintenanceId, int switchId) {
        String sql = "DELETE FROM MaintenanceSwitch WHERE maintenance_id = ? AND switch_id = ?";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, maintenanceId);
            ps.setInt(2, switchId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }


    public ArrayList<Integer> findSwitchesByMaintenance(int maintenanceId) {
        ArrayList<Integer> list = new ArrayList<>();
        String sql = "SELECT switch_id FROM MaintenanceSwitch WHERE maintenance_id = ?";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, maintenanceId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(rs.getInt("switch_id"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }


    public ArrayList<Integer> findMaintenancesBySwitch(int switchId) {
        ArrayList<Integer> list = new ArrayList<>();
        String sql = "SELECT maintenance_id FROM MaintenanceSwitch WHERE switch_id = ?";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, switchId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(rs.getInt("maintenance_id"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
