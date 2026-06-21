package Models_DAO;

import Models.MaintenanceScheduleDTO;
import java.util.ArrayList;
import java.util.function.Consumer;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.EntityTransaction;
import javax.persistence.Persistence;

public class MaintenanceScheduleDAO implements IDAO<MaintenanceScheduleDTO, Integer> {

    private static final String PERSISTENCE_UNIT_NAME = "NetworkManagerWebPU";
    private static final EntityManagerFactory FACTORY
            = Persistence.createEntityManagerFactory(PERSISTENCE_UNIT_NAME);

    public MaintenanceScheduleDAO() {
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

    @Override
    public boolean insert(MaintenanceScheduleDTO t) {
        if (t == null) return false;
        if (t.getStatus() == null || t.getStatus().trim().isEmpty()) {
            t.setStatus("PLANNED");
        }
        return executeInTransaction(em -> em.persist(t));
    }

    @Override
    public boolean remove(MaintenanceScheduleDTO t) {
        if (t == null) return false;
        return executeInTransaction(em -> {
            MaintenanceScheduleDTO entity = em.find(MaintenanceScheduleDTO.class, t.getMaintenanceId());
            if (entity != null) {
                em.remove(entity);
            }
        });
    }

    @Override
    public boolean update(MaintenanceScheduleDTO t) {
        if (t == null || t.getMaintenanceId() <= 0) return false;
        return executeInTransaction(em -> em.merge(t));
    }

    @Override
    public ArrayList<MaintenanceScheduleDTO> ListAll() {
        EntityManager em = getEntityManager();
        try {
            return new ArrayList<>(
                em.createQuery("SELECT m FROM MaintenanceScheduleDTO m ORDER BY m.startTime DESC", MaintenanceScheduleDTO.class)
                  .getResultList()
            );
        } finally {
            em.close();
        }
    }

    @Override
    public MaintenanceScheduleDTO searchById(Integer id) {
        if (id == null || id <= 0) return null;
        EntityManager em = getEntityManager();
        try {
            return em.find(MaintenanceScheduleDTO.class, id);
        } finally {
            em.close();
        }
    }

    public ArrayList<MaintenanceScheduleDTO> findUpcoming() {
        EntityManager em = getEntityManager();
        try {
            return new ArrayList<>(
                em.createQuery("SELECT m FROM MaintenanceScheduleDTO m WHERE m.startTime >= CURRENT_TIMESTAMP AND m.status IN ('PLANNED','IN_PROGRESS') ORDER BY m.startTime ASC", MaintenanceScheduleDTO.class)
                  .getResultList()
            );
        } finally {
            em.close();
        }
    }

    public boolean updateStatus(int maintenanceId, String newStatus) {
        if (maintenanceId <= 0 || newStatus == null || newStatus.trim().isEmpty()) {
            return false;
        }
        return executeInTransaction(em -> {
            MaintenanceScheduleDTO entity = em.find(MaintenanceScheduleDTO.class, maintenanceId);
            if (entity != null) {
                entity.setStatus(newStatus.trim());
            }
        });
    }
}
