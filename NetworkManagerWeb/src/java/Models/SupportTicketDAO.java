package Models;

import Utils.DbUtils;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;

public class SupportTicketDAO implements IDAO<SupportTicketDTO, Integer> {

    private SupportTicketDTO mapRow(ResultSet rs) throws SQLException {
        Integer deviceId = (Integer) rs.getObject("device_id");

        return new SupportTicketDTO(
                rs.getInt("ticket_id"),
                rs.getString("title"),
                rs.getString("description"),
                rs.getString("status"),
                rs.getTimestamp("created_date"),
                rs.getInt("created_by"),
                deviceId
        );
    }

    @Override
    public boolean insert(SupportTicketDTO ticket) {
        String sql = "INSERT INTO SupportTicket "
                + "(title, description, status, created_by, device_id) "
                + "VALUES (?, ?, ?, ?, ?)";

        try {
            Connection conn = DbUtils.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setString(1, ticket.getTitle());
            ps.setString(2, ticket.getDescription());
            ps.setString(3, ticket.getStatus());
            ps.setInt(4, ticket.getCreatedBy());

            if (ticket.getDeviceId() == null) {
                ps.setNull(5, Types.INTEGER);
            } else {
                ps.setInt(5, ticket.getDeviceId());
            }

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public boolean update(SupportTicketDTO ticket) {
        String sql = "UPDATE SupportTicket SET "
                + "title = ?, description = ?, status = ?, created_by = ?, device_id = ? "
                + "WHERE ticket_id = ?";

        try {
            Connection conn = DbUtils.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setString(1, ticket.getTitle());
            ps.setString(2, ticket.getDescription());
            ps.setString(3, ticket.getStatus());
            ps.setInt(4, ticket.getCreatedBy());

            if (ticket.getDeviceId() == null) {
                ps.setNull(5, Types.INTEGER);
            } else {
                ps.setInt(5, ticket.getDeviceId());
            }

            ps.setInt(6, ticket.getTicketId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public boolean remove(SupportTicketDTO ticket) {
        return delete(ticket.getTicketId());
    }

    public boolean delete(int ticketId) {
        String sql = "DELETE FROM SupportTicket WHERE ticket_id = ?";

        try {
            Connection conn = DbUtils.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setInt(1, ticketId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public ArrayList<SupportTicketDTO> ListAll() {
        ArrayList<SupportTicketDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM SupportTicket";

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
    public SupportTicketDTO searchById(Integer id) {
        String sql = "SELECT * FROM SupportTicket WHERE ticket_id = ?";

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

    public boolean updateStatus(int ticketId, String status) {
        String sql = "UPDATE SupportTicket SET status = ? WHERE ticket_id = ?";

        try {
            Connection conn = DbUtils.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setString(1, status);
            ps.setInt(2, ticketId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public ArrayList<SupportTicketDTO> findByUser(int userId) {
        ArrayList<SupportTicketDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM SupportTicket WHERE created_by = ?";

        try {
            Connection conn = DbUtils.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setInt(1, userId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapRow(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public ArrayList<SupportTicketDTO> findByDevice(int deviceId) {
        ArrayList<SupportTicketDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM SupportTicket WHERE device_id = ?";

        try {
            Connection conn = DbUtils.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

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
}