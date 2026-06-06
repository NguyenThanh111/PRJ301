package Models;

import Utils.DbUtils;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;

public class VLANDAO implements IDAO<VLANDTO, Integer> {

    private VLANDTO mapRow(ResultSet rs) throws SQLException {
        Integer roomId = (Integer) rs.getObject("room_id");

        return new VLANDTO(
                rs.getInt("vlan_id"),
                rs.getString("vlan_name"),
                rs.getString("subnet"),
                rs.getString("purpose"),
                roomId
        );
    }

    @Override
    public boolean insert(VLANDTO vlan) {
        String sql = "INSERT INTO VLAN (vlan_name, subnet, purpose, room_id) VALUES (?, ?, ?, ?)";

        try {
            Connection conn = DbUtils.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setString(1, vlan.getVlanName());
            ps.setString(2, vlan.getSubnet());
            ps.setString(3, vlan.getPurpose());

            if (vlan.getRoomId() == null) {
                ps.setNull(4, java.sql.Types.INTEGER);
            } else {
                ps.setInt(4, vlan.getRoomId());
            }

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public boolean update(VLANDTO vlan) {
        String sql = "UPDATE VLAN SET vlan_name = ?, subnet = ?, purpose = ?, room_id = ? WHERE vlan_id = ?";

        try {
            Connection conn = DbUtils.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setString(1, vlan.getVlanName());
            ps.setString(2, vlan.getSubnet());
            ps.setString(3, vlan.getPurpose());

            if (vlan.getRoomId() == null) {
                ps.setNull(4, java.sql.Types.INTEGER);
            } else {
                ps.setInt(4, vlan.getRoomId());
            }

            ps.setInt(5, vlan.getVlanId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public boolean remove(VLANDTO vlan) {
        return delete(vlan.getVlanId());
    }

    public boolean delete(int vlanId) {
        String sql = "DELETE FROM VLAN WHERE vlan_id = ?";

        try {
            Connection conn = DbUtils.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setInt(1, vlanId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public ArrayList<VLANDTO> ListAll() {
        ArrayList<VLANDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM VLAN";

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
    public VLANDTO searchById(Integer id) {
        String sql = "SELECT * FROM VLAN WHERE vlan_id = ?";

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

    public ArrayList<VLANDTO> findByRoom(Integer roomId) {
        ArrayList<VLANDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM VLAN WHERE room_id = ?";

        try {
            Connection conn = DbUtils.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setInt(1, roomId);

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