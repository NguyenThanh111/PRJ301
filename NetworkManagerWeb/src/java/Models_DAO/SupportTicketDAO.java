package Models_DAO;

import Models.SupportTicketDTO;
import Utils.JpaUtils;
import java.util.ArrayList;
import java.util.List;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.CriteriaQuery;
import javax.persistence.criteria.Root;

public class SupportTicketDAO implements IDAO<SupportTicketDTO, Integer> {

    @Override
    public boolean insert(SupportTicketDTO ticket) {
        if (ticket == null) {
            return false;
        }

        EntityManager em = JpaUtils.getEntityManager();
        EntityTransaction transaction = em.getTransaction();

        try {
            transaction.begin();
            em.persist(ticket);
            transaction.commit();
            return true;
        } catch (Exception e) {
            if (transaction.isActive()) {
                transaction.rollback();
            }

            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }

    @Override
    public boolean update(SupportTicketDTO ticket) {
        if (ticket == null || ticket.getTicketId() <= 0) {
            return false;
        }

        EntityManager em = JpaUtils.getEntityManager();
        EntityTransaction transaction = em.getTransaction();

        try {
            transaction.begin();

            SupportTicketDTO existingTicket
                    = em.find(SupportTicketDTO.class, ticket.getTicketId());

            if (existingTicket == null) {
                transaction.rollback();
                return false;
            }

            existingTicket.setTitle(ticket.getTitle());
            existingTicket.setDescription(ticket.getDescription());
            existingTicket.setStatus(ticket.getStatus());
            existingTicket.setCreatedDate(ticket.getCreatedDate());
            existingTicket.setCreatedBy(ticket.getCreatedBy());
            existingTicket.setDeviceId(ticket.getDeviceId());

            transaction.commit();
            return true;
        } catch (Exception e) {
            if (transaction.isActive()) {
                transaction.rollback();
            }

            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }

    @Override
    public boolean remove(SupportTicketDTO ticket) {
        if (ticket == null || ticket.getTicketId() <= 0) {
            return false;
        }

        return delete(ticket.getTicketId());
    }

    public boolean delete(int ticketId) {
        if (ticketId <= 0) {
            return false;
        }

        EntityManager em = JpaUtils.getEntityManager();
        EntityTransaction transaction = em.getTransaction();

        try {
            transaction.begin();

            SupportTicketDTO ticket
                    = em.find(SupportTicketDTO.class, ticketId);

            if (ticket == null) {
                transaction.rollback();
                return false;
            }

            em.remove(ticket);
            transaction.commit();
            return true;
        } catch (Exception e) {
            if (transaction.isActive()) {
                transaction.rollback();
            }

            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }

    @Override
    public ArrayList<SupportTicketDTO> ListAll() {
        EntityManager em = JpaUtils.getEntityManager();

        try {
            CriteriaBuilder builder = em.getCriteriaBuilder();
            CriteriaQuery<SupportTicketDTO> query
                    = builder.createQuery(SupportTicketDTO.class);
            Root<SupportTicketDTO> root
                    = query.from(SupportTicketDTO.class);

            query.select(root);
            query.orderBy(builder.desc(root.get("ticketId")));

            List<SupportTicketDTO> result
                    = em.createQuery(query).getResultList();

            return new ArrayList<>(result);
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        } finally {
            em.close();
        }
    }

    @Override
    public SupportTicketDTO searchById(Integer id) {
        if (id == null || id <= 0) {
            return null;
        }

        EntityManager em = JpaUtils.getEntityManager();

        try {
            return em.find(SupportTicketDTO.class, id);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        } finally {
            em.close();
        }
    }

    public boolean updateStatus(int ticketId, String status) {
        if (ticketId <= 0 || status == null) {
            return false;
        }

        EntityManager em = JpaUtils.getEntityManager();
        EntityTransaction transaction = em.getTransaction();

        try {
            transaction.begin();

            SupportTicketDTO ticket
                    = em.find(SupportTicketDTO.class, ticketId);

            if (ticket == null) {
                transaction.rollback();
                return false;
            }

            ticket.setStatus(status);
            transaction.commit();
            return true;
        } catch (Exception e) {
            if (transaction.isActive()) {
                transaction.rollback();
            }

            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }

    public boolean assignTechnician(int ticketId, int technicianId) {
        return ticketId > 0 && technicianId > 0;
    }

    public ArrayList<SupportTicketDTO> findByUser(int userId) {
        if (userId <= 0) {
            return new ArrayList<>();
        }

        EntityManager em = JpaUtils.getEntityManager();

        try {
            CriteriaBuilder builder = em.getCriteriaBuilder();
            CriteriaQuery<SupportTicketDTO> query
                    = builder.createQuery(SupportTicketDTO.class);
            Root<SupportTicketDTO> root
                    = query.from(SupportTicketDTO.class);

            query.select(root);
            query.where(builder.equal(root.get("createdBy"), userId));
            query.orderBy(builder.desc(root.get("ticketId")));

            List<SupportTicketDTO> result
                    = em.createQuery(query).getResultList();

            return new ArrayList<>(result);
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        } finally {
            em.close();
        }
    }

    public ArrayList<SupportTicketDTO> findByDevice(int deviceId) {
        if (deviceId <= 0) {
            return new ArrayList<>();
        }

        EntityManager em = JpaUtils.getEntityManager();

        try {
            CriteriaBuilder builder = em.getCriteriaBuilder();
            CriteriaQuery<SupportTicketDTO> query
                    = builder.createQuery(SupportTicketDTO.class);
            Root<SupportTicketDTO> root
                    = query.from(SupportTicketDTO.class);

            query.select(root);
            query.where(builder.equal(root.get("deviceId"), deviceId));
            query.orderBy(builder.desc(root.get("ticketId")));

            List<SupportTicketDTO> result
                    = em.createQuery(query).getResultList();

            return new ArrayList<>(result);
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        } finally {
            em.close();
        }
    }

    public ArrayList<SupportTicketDTO> findByStatus(String status) {
        if (status == null) {
            return new ArrayList<>();
        }

        EntityManager em = JpaUtils.getEntityManager();

        try {
            CriteriaBuilder builder = em.getCriteriaBuilder();
            CriteriaQuery<SupportTicketDTO> query
                    = builder.createQuery(SupportTicketDTO.class);
            Root<SupportTicketDTO> root
                    = query.from(SupportTicketDTO.class);

            query.select(root);
            query.where(builder.equal(root.get("status"), status));
            query.orderBy(builder.desc(root.get("ticketId")));

            List<SupportTicketDTO> result
                    = em.createQuery(query).getResultList();

            return new ArrayList<>(result);
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        } finally {
            em.close();
        }
    }
}
