/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Models;

import Utils.DbUtils;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;

/**
 *
 * @author nvtv0
 */
public class WiFiAnalyticsDAO implements IDAO<WiFiAnalyticsDTO, Integer> {

    private WiFiAnalyticsDTO mapRow(ResultSet rs) throws SQLException {
        return new WiFiAnalyticsDTO(
                rs.getInt("analytics_id"),
                rs.getInt("total_users"),
                rs.getInt("peak_users"),
                rs.getDouble("avg_speed"),
                rs.getDate("analytics_date"),
                rs.getInt("ap_id")
        );
    }

    @Override
    public boolean insert(WiFiAnalyticsDTO t) {
        String sql = "INSERT INTO WiFiAnalytics (total_users, peak_users, avg_speed, analytics_date, ap_id) "
                   + "VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, t.getTotalUsers());
            ps.setInt(2, t.getPeakUsers());
            ps.setDouble(3, t.getAvgSpeed());
            ps.setDate(4, t.getAnalyticsDate());
            ps.setInt(5, t.getApId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean remove(WiFiAnalyticsDTO t) {
        String sql = "DELETE FROM WiFiAnalytics WHERE analytics_id = ?";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, t.getAnalyticsId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean update(WiFiAnalyticsDTO t) {
        String sql = "UPDATE WiFiAnalytics SET total_users=?, peak_users=?, avg_speed=?, analytics_date=?, ap_id=? "
                   + "WHERE analytics_id=?";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, t.getTotalUsers());
            ps.setInt(2, t.getPeakUsers());
            ps.setDouble(3, t.getAvgSpeed());
            ps.setDate(4, t.getAnalyticsDate());
            ps.setInt(5, t.getApId());
            ps.setInt(6, t.getAnalyticsId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public ArrayList<WiFiAnalyticsDTO> ListAll() {
        ArrayList<WiFiAnalyticsDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM WiFiAnalytics ORDER BY analytics_date DESC";
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
    public WiFiAnalyticsDTO searchById(Integer id) {
        String sql = "SELECT * FROM WiFiAnalytics WHERE analytics_id = ?";
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


    public ArrayList<WiFiAnalyticsDTO> findByAP(int apId) {
        ArrayList<WiFiAnalyticsDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM WiFiAnalytics WHERE ap_id = ? ORDER BY analytics_date DESC";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, apId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean generateDailyAnalytics(int apId, int totalUsers, int peakUsers, double avgSpeed) {
        String checkSql = "SELECT analytics_id FROM WiFiAnalytics WHERE ap_id = ? AND analytics_date = CAST(GETDATE() AS DATE)";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
            checkPs.setInt(1, apId);
            ResultSet rs = checkPs.executeQuery();
            if (rs.next()) {
                int existingId = rs.getInt("analytics_id");
                String updateSql = "UPDATE WiFiAnalytics SET total_users=?, peak_users=?, avg_speed=? "
                                 + "WHERE analytics_id=?";
                try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                    updatePs.setInt(1, totalUsers);
                    updatePs.setInt(2, peakUsers);
                    updatePs.setDouble(3, avgSpeed);
                    updatePs.setInt(4, existingId);
                    return updatePs.executeUpdate() > 0;
                }
            } else {
                String insertSql = "INSERT INTO WiFiAnalytics (total_users, peak_users, avg_speed, analytics_date, ap_id) "
                                 + "VALUES (?, ?, ?, CAST(GETDATE() AS DATE), ?)";
                try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                    insertPs.setInt(1, totalUsers);
                    insertPs.setInt(2, peakUsers);
                    insertPs.setDouble(3, avgSpeed);
                    insertPs.setInt(4, apId);
                    return insertPs.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }


    public ArrayList<WiFiAnalyticsDTO> generateMonthlyAnalytics(int apId, int year, int month) {
        ArrayList<WiFiAnalyticsDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM WiFiAnalytics "
                   + "WHERE ap_id = ? AND YEAR(analytics_date) = ? AND MONTH(analytics_date) = ? "
                   + "ORDER BY analytics_date";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, apId);
            ps.setInt(2, year);
            ps.setInt(3, month);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

}

