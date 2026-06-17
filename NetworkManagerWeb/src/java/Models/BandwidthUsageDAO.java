
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
public class BandwidthUsageDAO implements IDAO<BandwidthUsageDTO, Integer> {

    private BandwidthUsageDTO mapRow(ResultSet rs) throws SQLException {
        return new BandwidthUsageDTO(
                rs.getInt("usage_id"),
                rs.getDouble("upload_speed"),
                rs.getDouble("download_speed"),
                rs.getTimestamp("record_time"),
                rs.getInt("device_id")
        );
    }
    
    @Override
    public boolean insert(BandwidthUsageDTO t) {
        String sql = "INSERT INTO BandwidthUsage (upload_speed, download_speed, record_time, device_id) "
                   + "VALUES (?, ?, GETDATE(), ?)";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDouble(1, t.getUploadSpeed());
            ps.setDouble(2, t.getDownloadSpeed());
            ps.setInt(3, t.getDeviceId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean remove(BandwidthUsageDTO t) {
        String sql = "DELETE FROM BandwidthUsage WHERE usage_id = ?";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, t.getUsageId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean update(BandwidthUsageDTO t) {
        String sql = "UPDATE BandwidthUsage SET upload_speed=?, download_speed=?, device_id=? "
                   + "WHERE usage_id=?";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDouble(1, t.getUploadSpeed());
            ps.setDouble(2, t.getDownloadSpeed());
            ps.setInt(3, t.getDeviceId());
            ps.setInt(4, t.getUsageId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    
    @Override
    public ArrayList<BandwidthUsageDTO> ListAll() {
        ArrayList<BandwidthUsageDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM BandwidthUsage ORDER BY record_time DESC";
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
    public BandwidthUsageDTO searchById(Integer id) {
        String sql = "SELECT * FROM BandwidthUsage WHERE usage_id = ?";
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

    public ArrayList<BandwidthUsageDTO> findByDevice(int deviceId) {
        ArrayList<BandwidthUsageDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM BandwidthUsage WHERE device_id = ? ORDER BY record_time DESC";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, deviceId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }


    public ArrayList<BandwidthUsageDTO> findByDate(String date) {
        ArrayList<BandwidthUsageDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM BandwidthUsage WHERE CAST(record_time AS DATE) = ? ORDER BY record_time DESC";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, date);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public ArrayList<BandwidthUsageDTO> findTopUsage(int topN) {
        ArrayList<BandwidthUsageDTO> list = new ArrayList<>();
        String sql = "SELECT TOP (?) device_id AS deviceId, "
                   + "SUM(upload_speed) AS uploadSpeed, "
                   + "SUM(download_speed) AS downloadSpeed, "
                   + "MAX(record_time) AS recordTime "
                   + "FROM BandwidthUsage "
                   + "GROUP BY device_id "
                   + "ORDER BY (SUM(upload_speed) + SUM(download_speed)) DESC";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, topN);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                BandwidthUsageDTO dto = new BandwidthUsageDTO();
                dto.setDeviceId(rs.getInt("device_id"));
                dto.setUploadSpeed(rs.getDouble("upload_speed"));
                dto.setDownloadSpeed(rs.getDouble("download_speed"));
                dto.setRecordTime(rs.getTimestamp("record_time"));
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public ArrayList<BandwidthUsageDTO> generateReport(String fromDate, String toDate) {
        ArrayList<BandwidthUsageDTO> list = new ArrayList<>();
        String sql = "SELECT 0 AS usageId, 0 AS deviceId, "
                   + "SUM(upload_speed) AS uploadSpeed, "
                   + "SUM(download_speed) AS downloadSpeed, "
                   + "CAST(record_time AS DATE) AS recordTime "
                   + "FROM BandwidthUsage "
                   + "WHERE CAST(record_time AS DATE) BETWEEN ? AND ? "
                   + "GROUP BY CAST(record_time AS DATE) "
                   + "ORDER BY CAST(record_time AS DATE)";
        try (Connection conn = DbUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fromDate);
            ps.setString(2, toDate);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                BandwidthUsageDTO dto = new BandwidthUsageDTO();
                dto.setUploadSpeed(rs.getDouble("upload_speed"));
                dto.setDownloadSpeed(rs.getDouble("download_speed"));
                dto.setRecordTime(rs.getTimestamp("record_time"));
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}

