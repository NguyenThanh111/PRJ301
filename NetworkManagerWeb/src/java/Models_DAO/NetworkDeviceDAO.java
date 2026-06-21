package Models_DAO;

import Models.NetworkDeviceDTO;
import Utils.DbUtils;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;

public class NetworkDeviceDAO implements IDAO<NetworkDeviceDTO, Integer> {

    private NetworkDeviceDTO mapRow(ResultSet rs) throws SQLException {
        return new NetworkDeviceDTO(
                rs.getInt("device_id"),
                rs.getString("device_name"),
                rs.getString("mac_address"),
                rs.getString("ip_address"),
                rs.getString("owner"),
                rs.getString("device_type"),
                rs.getString("status"),
                rs.getInt("room_id")
        );
    }

    @Override
    public boolean insert(NetworkDeviceDTO t) {
        String sql = "INSERT INTO NetworkDevice "
                + "(device_name, mac_address, ip_address, owner, device_type, status, room_id) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try {
            Connection connect = DbUtils.getConnection();
            PreparedStatement ps = connect.prepareStatement(sql);
            ps.setString(1, t.getDeviceName());
            ps.setString(2, t.getMacAddress());
            ps.setString(3, t.getIpAddress());
            ps.setString(4, t.getOwner());
            ps.setString(5, t.getDeviceType());
            ps.setString(6, t.getStatus());
            ps.setInt(7, t.getRoomId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean update(NetworkDeviceDTO t) {
        String sql = "UPDATE NetworkDevice SET "
                + "device_name = ?, mac_address = ?, ip_address = ?, "
                + "owner = ?, device_type = ?, status = ?, room_id = ? "
                + "WHERE device_id = ?";
        try {
            Connection connect = DbUtils.getConnection();
            PreparedStatement ps = connect.prepareStatement(sql);
            ps.setString(1, t.getDeviceName());
            ps.setString(2, t.getMacAddress());
            ps.setString(3, t.getIpAddress());
            ps.setString(4, t.getOwner());
            ps.setString(5, t.getDeviceType());
            ps.setString(6, t.getStatus());
            ps.setInt(7, t.getRoomId());
            ps.setInt(8, t.getDeviceId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean remove(NetworkDeviceDTO t) {
        return delete(t.getDeviceId());
    }

    public boolean delete(int deviceId) {
        String sql = "UPDATE NetworkDevice SET status = 'INACTIVE' WHERE device_id = ?";
        try (
                Connection conn = DbUtils.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, deviceId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public ArrayList<NetworkDeviceDTO> ListAll() {
        ArrayList<NetworkDeviceDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM NetworkDevice";
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
    public NetworkDeviceDTO searchById(Integer id) {
        String sql = "SELECT * FROM NetworkDevice WHERE device_id = ?";
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

    public NetworkDeviceDTO findByMAC(String macAddress) {
        String sql = "SELECT * FROM NetworkDevice WHERE mac_address = ?";
        try {
            Connection connect = DbUtils.getConnection();
            PreparedStatement ps = connect.prepareStatement(sql);
            ps.setString(1, macAddress);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean blockDevice(int deviceId) {
        String sql = "UPDATE NetworkDevice SET status = 'BLOCKED' WHERE device_id = ?";
        try {
            Connection connect = DbUtils.getConnection();
            PreparedStatement ps = connect.prepareStatement(sql);
            ps.setInt(1, deviceId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean unblockDevice(int deviceId) {
        String sql = "UPDATE NetworkDevice SET status = 'ALLOWED' WHERE device_id = ?";
        try {
            Connection connect = DbUtils.getConnection();
            PreparedStatement ps = connect.prepareStatement(sql);
            ps.setInt(1, deviceId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
