package Models;

import Utils.DbUtils;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;

public class IPAddressManagementDAO implements IDAO<IPAddressManagementDTO, Integer> {

    private IPAddressManagementDTO mapRow(ResultSet rs) throws SQLException {
        Integer deviceId = (Integer) rs.getObject("device_id");

        return new IPAddressManagementDTO(
                rs.getInt("ip_id"),
                rs.getString("ip_address"),
                rs.getString("status"),
                deviceId
        );
    }

    @Override
    public boolean insert(IPAddressManagementDTO ip) {
        String sql = "INSERT INTO IPAddressManagement (ip_address, status, device_id) VALUES (?, ?, ?)";

        try {
            Connection conn = DbUtils.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setString(1, ip.getIpAddress());
            ps.setString(2, ip.getStatus());

            if (ip.getDeviceId() == null) {
                ps.setNull(3, java.sql.Types.INTEGER);
            } else {
                ps.setInt(3, ip.getDeviceId());
            }

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public boolean update(IPAddressManagementDTO ip) {
        String sql = "UPDATE IPAddressManagement SET ip_address = ?, status = ?, device_id = ? WHERE ip_id = ?";

        try {
            Connection conn = DbUtils.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setString(1, ip.getIpAddress());
            ps.setString(2, ip.getStatus());

            if (ip.getDeviceId() == null) {
                ps.setNull(3, java.sql.Types.INTEGER);
            } else {
                ps.setInt(3, ip.getDeviceId());
            }

            ps.setInt(4, ip.getIpId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public boolean remove(IPAddressManagementDTO ip) {
        return delete(ip.getIpId());
    }

    public boolean delete(int ipId) {
        String sql = "DELETE FROM IPAddressManagement WHERE ip_id = ?";

        try {
            Connection conn = DbUtils.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setInt(1, ipId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public ArrayList<IPAddressManagementDTO> ListAll() {
        ArrayList<IPAddressManagementDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM IPAddressManagement";

        try {
            Connection conn = DbUtils.getConnection();
            Statement st = conn.createStatement();
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
    public IPAddressManagementDTO searchById(Integer id) {
        String sql = "SELECT * FROM IPAddressManagement WHERE ip_id = ?";

        try {
            Connection conn = DbUtils.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

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

    public ArrayList<IPAddressManagementDTO> findAvailableIP() {
        ArrayList<IPAddressManagementDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM IPAddressManagement WHERE status = 'AVAILABLE'";

        try {
            Connection conn = DbUtils.getConnection();
            Statement st = conn.createStatement();
            ResultSet rs = st.executeQuery(sql);

            while (rs.next()) {
                list.add(mapRow(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public boolean assignIP(int ipId, int deviceId) {
        String sql = "UPDATE IPAddressManagement SET status = 'ASSIGNED', device_id = ? WHERE ip_id = ?";

        try {
            Connection conn = DbUtils.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setInt(1, deviceId);
            ps.setInt(2, ipId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean releaseIP(int ipId) {
        String sql = "UPDATE IPAddressManagement SET status = 'AVAILABLE', device_id = NULL WHERE ip_id = ?";

        try {
            Connection conn = DbUtils.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setInt(1, ipId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public IPAddressManagementDTO findByDevice(int deviceId) {
        String sql = "SELECT * FROM IPAddressManagement WHERE device_id = ?";

        try {
            Connection conn = DbUtils.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setInt(1, deviceId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return mapRow(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }
}