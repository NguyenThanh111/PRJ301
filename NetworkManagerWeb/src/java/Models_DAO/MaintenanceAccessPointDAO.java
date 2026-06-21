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
public class MaintenanceAccessPointDAO {
    

    public boolean addAP(int maintenanceId, int apId) {
        String sql = "INSERT INTO MaintenanceAccessPoint (maintenanceId, apId) VALUES (?, ?)";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, maintenanceId);
            ps.setInt(2, apId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean removeAP(int maintenanceId, int apId) {
        String sql = "DELETE FROM MaintenanceAccessPoint WHERE maintenanceId = ? AND apId = ?";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, maintenanceId);
            ps.setInt(2, apId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public ArrayList<Integer> findAPsByMaintenance(int maintenanceId) {
        ArrayList<Integer> list = new ArrayList<>();
        String sql = "SELECT apId FROM MaintenanceAccessPoint WHERE maintenanceId = ?";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, maintenanceId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(rs.getInt("apId"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }


    public ArrayList<Integer> findMaintenancesByAP(int apId) {
        ArrayList<Integer> list = new ArrayList<>();
        String sql = "SELECT maintenanceId FROM MaintenanceAccessPoint WHERE apId = ?";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, apId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(rs.getInt("maintenanceId"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}

