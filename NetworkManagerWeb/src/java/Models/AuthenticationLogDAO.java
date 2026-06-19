package Models;

import java.util.ArrayList;
import java.util.List;
import java.util.function.Consumer;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.EntityTransaction;
import javax.persistence.Persistence;

public class AuthenticationLogDAO {

    private static final String PERSISTENCE_UNIT_NAME = "NetworkManagerWebPU";
    private static final EntityManagerFactory FACTORY
            = Persistence.createEntityManagerFactory(PERSISTENCE_UNIT_NAME);

    public AuthenticationLogDAO() {
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

    public boolean insert(AuthenticationLogDTO log) {
        if (log == null) {
            return false;
        }
        return executeInTransaction(em -> em.persist(log));
    }

    public ArrayList<AuthenticationLogDTO> findAll() {
        EntityManager em = getEntityManager();
        try {
            return new ArrayList<>(
                    em.createQuery(
                            "SELECT a FROM AuthenticationLogDTO a ORDER BY a.loginTime DESC",
                            AuthenticationLogDTO.class)
                            .getResultList()
            );
        } finally {
            em.close();
        }
    }

    public ArrayList<AuthenticationLogDTO> findByUser(int userId) {
        EntityManager em = getEntityManager();
        try {
            List<AuthenticationLogDTO> logs = em.createQuery(
                    "SELECT a FROM AuthenticationLogDTO a WHERE a.userId = :userId ORDER BY a.loginTime DESC",
                    AuthenticationLogDTO.class)
                    .setParameter("userId", userId)
                    .getResultList();
            return new ArrayList<>(logs);
        } finally {
            em.close();
        }
    }

    public ArrayList<AuthenticationLogDTO> findFailedAttempts() {
        EntityManager em = getEntityManager();
        try {
            return new ArrayList<>(
                    em.createQuery(
                            "SELECT a FROM AuthenticationLogDTO a WHERE a.loginStatus = 'FAILED' ORDER BY a.loginTime DESC",
                            AuthenticationLogDTO.class)
                            .getResultList()
            );
        } finally {
            em.close();
        }
    }
}
