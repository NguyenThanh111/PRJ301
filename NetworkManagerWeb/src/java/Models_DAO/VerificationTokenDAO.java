package Models_DAO;

import Models.VerificationToken;
import java.time.LocalDateTime;
import java.util.List;
import java.util.function.Consumer;
import java.util.function.Function;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.EntityTransaction;
import javax.persistence.NoResultException;
import javax.persistence.Persistence;
import javax.persistence.TypedQuery;

public class VerificationTokenDAO {

    private static final String PERSISTENCE_UNIT_NAME = "NetworkManagerWebPU";
    private static final EntityManagerFactory FACTORY
            = Persistence.createEntityManagerFactory(PERSISTENCE_UNIT_NAME);

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

    private <R> R executeInTransaction(Function<EntityManager, R> action, R defaultValue) {
        EntityManager em = getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            R result = action.apply(em);
            tx.commit();
            return result;
        } catch (Exception e) {
            if (tx.isActive()) {
                tx.rollback();
            }
            e.printStackTrace();
            return defaultValue;
        } finally {
            em.close();
        }
    }

    public VerificationToken findByToken(String token) {
        EntityManager em = getEntityManager();
        try {
            TypedQuery<VerificationToken> query = em.createQuery(
                "SELECT t FROM VerificationToken t WHERE t.token = :token", VerificationToken.class);
            query.setParameter("token", token);
            return query.getSingleResult();
        } catch (NoResultException e) {
            return null;
        } finally {
            em.close();
        }
    }

    public List<VerificationToken> findByUserAndType(int userId, String type) {
        EntityManager em = getEntityManager();
        try {
            TypedQuery<VerificationToken> query = em.createQuery(
                "SELECT t FROM VerificationToken t WHERE t.userId = :userId AND t.type = :type ORDER BY t.createdAt DESC",
                VerificationToken.class);
            query.setParameter("userId", userId);
            query.setParameter("type", type);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    public void save(VerificationToken token) {
        executeInTransaction(em -> em.persist(token));
    }

    public void markUsed(int id) {
        executeInTransaction(em -> {
            VerificationToken t = em.find(VerificationToken.class, id);
            if (t != null) {
                t.setUsed(true);
            }
        });
    }

    public void markAllUsed(int userId, String type) {
        executeInTransaction(em -> {
            em.createQuery(
                "UPDATE VerificationToken t SET t.used = true WHERE t.userId = :userId AND t.type = :type AND t.used = false")
                .setParameter("userId", userId)
                .setParameter("type", type)
                .executeUpdate();
        });
    }

    public long countRecentByUser(int userId, String type, int minutes) {
        EntityManager em = getEntityManager();
        try {
            TypedQuery<Long> query = em.createQuery(
                "SELECT COUNT(t) FROM VerificationToken t "
                + "WHERE t.userId = :userId AND t.type = :type AND t.createdAt > :cutoff",
                Long.class);
            query.setParameter("userId", userId);
            query.setParameter("type", type);
            query.setParameter("cutoff", LocalDateTime.now().minusMinutes(minutes));
            return query.getSingleResult();
        } finally {
            em.close();
        }
    }

    public int deleteExpired(int olderThanDays) {
        return executeInTransaction(em -> {
            LocalDateTime cutoff = LocalDateTime.now().minusDays(olderThanDays);
            return em.createQuery(
                "DELETE FROM VerificationToken t WHERE (t.used = true OR t.expiryDate < :now) AND t.createdAt < :cutoff")
                .setParameter("now", LocalDateTime.now())
                .setParameter("cutoff", cutoff)
                .executeUpdate();
        }, 0);
    }
}
