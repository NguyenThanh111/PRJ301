package Models_DAO;

import Models.SystemLogDTO;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;
import java.util.function.Consumer;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.EntityTransaction;
import javax.persistence.Persistence;

public class SystemLogDAO {

    private static final String PERSISTENCE_UNIT_NAME = "NetworkManagerWebPU";
    private static final EntityManagerFactory FACTORY
            = Persistence.createEntityManagerFactory(PERSISTENCE_UNIT_NAME);

    public SystemLogDAO() {
    }

    private EntityManager getEntityManager() {
        return FACTORY.createEntityManager();
    }

    private boolean executeInTransaction(Consumer<EntityManager> action) {
        EntityManager em = getEntityManager();
        EntityTransaction tx = em.getTransaction();

        try {
            tx.begin();
            action.accept(em);
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx.isActive()) {
                tx.rollback();
            }
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }

    public boolean insert(SystemLogDTO log) {
        if (log == null) {
            return false;
        }
        return executeInTransaction(em -> em.persist(log));
    }

    public ArrayList<SystemLogDTO> findAll() {
        EntityManager em = getEntityManager();
        try {
            return new ArrayList<>(
                    em.createQuery(
                            "SELECT s FROM SystemLogDTO s ORDER BY s.createdAt DESC",
                            SystemLogDTO.class)
                            .getResultList()
            );
        } finally {
            em.close();
        }
    }

    public ArrayList<SystemLogDTO> findByUser(int userId) {
        EntityManager em = getEntityManager();
        try {
            List<SystemLogDTO> logs = em.createQuery(
                    "SELECT s FROM SystemLogDTO s WHERE s.performedBy = :userId ORDER BY s.createdAt DESC",
                    SystemLogDTO.class)
                    .setParameter("userId", userId)
                    .getResultList();
            return new ArrayList<>(logs);
        } finally {
            em.close();
        }
    }

    public ArrayList<SystemLogDTO> findByDate(Date date) {
        if (date == null) {
            return new ArrayList<>();
        }
        EntityManager em = getEntityManager();
        try {
            java.sql.Timestamp start = new java.sql.Timestamp(date.getTime());
            java.sql.Timestamp end = new java.sql.Timestamp(date.getTime() + 86_400_000L);
            List<SystemLogDTO> logs = em.createQuery(
                    "SELECT s FROM SystemLogDTO s "
                    + "WHERE s.createdAt >= :start AND s.createdAt < :end "
                    + "ORDER BY s.createdAt DESC",
                    SystemLogDTO.class)
                    .setParameter("start", start)
                    .setParameter("end", end)
                    .getResultList();
            return new ArrayList<>(logs);
        } finally {
            em.close();
        }
    }
}
