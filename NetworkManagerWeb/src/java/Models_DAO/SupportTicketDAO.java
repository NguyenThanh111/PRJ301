//package Models_DAO;
//
//import Models.SupportTicketDTO;
//import Utils.DbUtils;
//import Utils.JpaUtils;
//import java.sql.Connection;
//import java.sql.PreparedStatement;
//import java.sql.ResultSet;
//import java.sql.SQLException;
//import java.sql.Statement;
//import java.sql.Types;
//import java.util.ArrayList;
//import javax.persistence.EntityManager;
//import javax.persistence.EntityTransaction;
//
//public class SupportTicketDAO implements IDAO<SupportTicketDTO, Integer> {
//
//    private SupportTicketDTO mapRow(ResultSet rs) throws SQLException {
//        
//
//    @Override
//    public boolean insert(SupportTicketDTO ticket) {
//        if (vlan == null) {
//            return false;
//            
//        }
//        EntityManager em = JpaUtils.getEntityManager();
//        EntityTransaction transaction = em.getTransaction();
//        
//        try {
//            transaction.begin();
//            em.persist(ticket);
//            
//            transaction.commit();
//            return true;
//            
//        } catch (Exception e) {
//            
//            if(transaction.isActive()){
//                transaction.rollback();
//            }
//            e.printStackTrace();
//            return false;
//        
//        } finally {
//            em.close();
//        }
//            
//            
//        
//    
//    }
//
//    @Override
//    public boolean update(SupportTicketDTO ticket) {
//        if (ticket == null || ticket.getTicketId() <= 0) {
//                return false;
//            }
//
//            EntityManager em = JpaUtils.getEntityManager();
//            EntityTransaction transaction = em.getTransaction();
//
//            try {
//                transaction.begin();
//
//                SupportTicketDTO existingSupportTicket = em.find(
//                        SupportTicketDTO.class,
//                        ticket.getTicketId()
//                );
//
//                if (existingSupportTicket== null) {
//                    transaction.rollback();
//                    return false;
//                }
//
//                existingSupportTicket.setTitle(ticket.getTitle());
//                existingSupportTicket.setDescription(ticket.getDescription());
//                existingSupportTicket.setStatus(ticket.getStatus());
//                existingSupportTicket.setCreatedDate(ticket.getCreatedDate());
//                existingSupportTicket.setCreatedBy(ticket.getCreatedBy());
//                existingSupportTicket.setDeviceId(ticket.getDeviceId());
//
//                transaction.commit();
//                return true;
//
//            } catch (Exception e) {
//
//                if (transaction.isActive()) {
//                    transaction.rollback();
//                }
//
//                e.printStackTrace();
//                return false;
//
//            } finally {
//                em.close();
//            }    
//    }
//
//    @Override
//    public boolean remove(SupportTicketDTO ticket) {
//                if (ticket == null || ticket.getTicketId() <= 0) {
//                return false;
//            }
//    }
//        return delete(ticket.getTicketId());
//    }
//
//    public boolean delete(int ticketId) {
//        if (ticket == null ) {
//                return false;
//            }
//
//            EntityManager em = JpaUtils.getEntityManager();
//            EntityTransaction transaction = em.getTransaction();
//
//            try {
//                transaction.begin();
//
//                SupportTicketDTO SupportTicket = em.find(
//                        SupportTicketDTO.class,
//                        ticketId
//                );
//
//                if (SupportTicket== null) {
//                    transaction.rollback();
//                    return false;
//                }
//                em.remove(SupportTicket);
//
//                
//
//                transaction.commit();
//                return true;
//
//            } catch (Exception e) {
//
//                if (transaction.isActive()) {
//                    transaction.rollback();
//                }
//
//                e.printStackTrace();
//                return false;
//
//            } finally {
//                em.close();
//            }  
//    }
//
//    @Override
//    public ArrayList<SupportTicketDTO> ListAll() {
//        ArrayList<SupportTicketDTO> list = new ArrayList<>();
//        String sql = "SELECT * FROM SupportTicket";
//
//        try {
//            Connection conn = DbUtils.getConnection();
//            Statement st = conn.createStatement();
//            ResultSet rs = st.executeQuery(sql);
//
//            while (rs.next()) {
//                list.add(mapRow(rs));
//            }
//
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//
//        return list;
//    }
//
//    @Override
//    public SupportTicketDTO searchById(Integer id) {
//        String sql = "SELECT * FROM SupportTicket WHERE ticket_id = ?";
//
//        try {
//            Connection conn = DbUtils.getConnection();
//            PreparedStatement ps = conn.prepareStatement(sql);
//
//            ps.setInt(1, id);
//
//            ResultSet rs = ps.executeQuery();
//
//            if (rs.next()) {
//                return mapRow(rs);
//            }
//
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//
//        return null;
//    }
//
//    public boolean updateStatus(int ticketId, String status) {
//        String sql = "UPDATE SupportTicket SET status = ? WHERE ticket_id = ?";
//
//        try {
//            Connection conn = DbUtils.getConnection();
//            PreparedStatement ps = conn.prepareStatement(sql);
//
//            ps.setString(1, status);
//            ps.setInt(2, ticketId);
//
//            return ps.executeUpdate() > 0;
//
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//
//        return false;
//    }
//
//    public ArrayList<SupportTicketDTO> findByUser(int userId) {
//        ArrayList<SupportTicketDTO> list = new ArrayList<>();
//        String sql = "SELECT * FROM SupportTicket WHERE created_by = ?";
//
//        try {
//            Connection conn = DbUtils.getConnection();
//            PreparedStatement ps = conn.prepareStatement(sql);
//
//            ps.setInt(1, userId);
//
//            ResultSet rs = ps.executeQuery();
//
//            while (rs.next()) {
//                list.add(mapRow(rs));
//            }
//
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//
//        return list;
//    }
//
//    public ArrayList<SupportTicketDTO> findByDevice(int deviceId) {
//        ArrayList<SupportTicketDTO> list = new ArrayList<>();
//        String sql = "SELECT * FROM SupportTicket WHERE device_id = ?";
//
//        try {
//            Connection conn = DbUtils.getConnection();
//            PreparedStatement ps = conn.prepareStatement(sql);
//
//            ps.setInt(1, deviceId);
//
//            ResultSet rs = ps.executeQuery();
//
//            while (rs.next()) {
//                list.add(mapRow(rs));
//            }
//
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//
//        return list;
//    }
//}