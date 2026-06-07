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
 * @author User
 */
public class SwitchDAO implements IDAO<SwitchDTO, Integer>{
    private SwitchDTO mapRow(ResultSet rs) throws SQLException{
        return new SwitchDTO(
                rs.getInt("switch_id"),
                rs.getString("switch_name"),
                rs.getInt("total_ports"),
                rs.getInt("used_ports"),
                rs.getString("ip_address"),
                rs.getString("status"),
                rs.getInt("room_id")
                
        );
    }
    @Override
    public boolean insert(SwitchDTO t) {
        if (t.getUsedPorts() < 0 || t.getUsedPorts() > t.getTotalPorts()) {
            return false;
        }

        String sql = "INSERT INTO [Switch] "
                + "(switch_name, total_ports, used_ports, ip_address, status, room_id) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        try {
            Connection connect = DbUtils.getConnection();
            PreparedStatement ps = connect.prepareStatement(sql);
            ps.setString(1, t.getSwitchName());
            ps.setInt(2, t.getTotalPorts());
            ps.setInt(3, t.getUsedPorts());
            ps.setString(4, t.getIpAddress());
            ps.setString(5, t.getStatus());
            ps.setInt(6, t.getRoomId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean update(SwitchDTO t) {
        String sql = "UPDATE [Switch] SET "
                + "switch_name = ?, total_ports = ?, used_ports = ?, "
                + "ip_address = ?, status = ?, room_id = ? "
                + "WHERE switch_id = ?";
        try {
            Connection connect = DbUtils.getConnection();
            PreparedStatement ps = connect.prepareStatement(sql);
            ps.setString(1, t.getSwitchName());
            ps.setInt(2, t.getTotalPorts());
            ps.setInt(3, t.getUsedPorts());
            ps.setString(4, t.getIpAddress());
            ps.setString(5, t.getStatus());
            ps.setInt(6, t.getRoomId());
            ps.setInt(7, t.getSwitchId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean remove(SwitchDTO t) {
      return softDelete(t.getSwitchId());
    }

    @Override
    public ArrayList<SwitchDTO> ListAll() {
        return findAll();
    }

    public ArrayList<SwitchDTO> findAll() {
        ArrayList<SwitchDTO> list = new  ArrayList<>();
        String sql="SELECT * FROM [Switch]";
        try {
            Connection connect = DbUtils.getConnection();
            Statement st = connect.createStatement();
            ResultSet rs = st.executeQuery(sql);
            while(rs.next()){
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public SwitchDTO searchById(Integer id) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }
    public boolean softDelete(int switchId) {
        String sql = "UPDATE [Switch] SET status = 'INACTIVE' WHERE switch_id = ?";
        try ( 
                Connection conn = DbUtils.getConnection();  
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, switchId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updatePortUsage(int switchId, int usedPorts) {
        if (usedPorts < 0) {
            return false;
        }

        String sql = "UPDATE [Switch] SET used_ports = ? "
                + "WHERE switch_id = ? AND ? <= total_ports";
        try {
            Connection connect = DbUtils.getConnection();
            PreparedStatement ps = connect.prepareStatement(sql);
            ps.setInt(1, usedPorts);
            ps.setInt(2, switchId);
            ps.setInt(3, usedPorts);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    
}
