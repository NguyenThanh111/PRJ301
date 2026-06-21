package Models_DAO;

import Models.RoomDTO;
import Utils.DbUtils;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;

public class RoomDAO implements IDAO<RoomDTO, Integer> {

    private RoomDTO mapRow(ResultSet rs) throws SQLException {
        return new RoomDTO(
                rs.getInt("room_id"),
                rs.getString("room_name"),
                rs.getString("building"),
                rs.getInt("floor"),
                rs.getInt("capacity")
        );
    }

    @Override
    public boolean insert(RoomDTO room) {
        String sql = "INSERT INTO Room (room_name, building, floor, capacity) VALUES (?, ?, ?, ?)";

        try {
            Connection conn = DbUtils.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setString(1, room.getRoomName());
            ps.setString(2, room.getBuilding());
            ps.setInt(3, room.getFloor());
            ps.setInt(4, room.getCapacity());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public boolean update(RoomDTO room) {
        String sql = "UPDATE Room SET room_name = ?, building = ?, floor = ?, capacity = ? WHERE room_id = ?";

        try {
            Connection conn = DbUtils.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setString(1, room.getRoomName());
            ps.setString(2, room.getBuilding());
            ps.setInt(3, room.getFloor());
            ps.setInt(4, room.getCapacity());
            ps.setInt(5, room.getRoomId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public boolean remove(RoomDTO room) {
        return delete(room.getRoomId());
    }

    public boolean delete(int roomId) {
        String sql = "DELETE FROM Room WHERE room_id = ?";

        try {
            Connection conn = DbUtils.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setInt(1, roomId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public ArrayList<RoomDTO> ListAll() {
        ArrayList<RoomDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM Room";

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
    public RoomDTO searchById(Integer id) {
        String sql = "SELECT * FROM Room WHERE room_id = ?";

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
}