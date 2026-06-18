package Models;

import java.util.ArrayList;
import java.util.List;
import java.util.function.Consumer;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.EntityTransaction;
import javax.persistence.Persistence;
import javax.persistence.TypedQuery;

public class RouterDAO implements IDAO<RouterDTO, Integer> {

    private static final String INACTIVE_STATUS = "INACTIVE";
    private static final String PERSISTENCE_UNIT_NAME = "NetworkManagerWebPU";
    private static final EntityManagerFactory FACTORY
            = Persistence.createEntityManagerFactory(PERSISTENCE_UNIT_NAME);

    public RouterDAO() {
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
    public boolean insert(RouterDTO t) {
        if (t == null) {
            return false;
        }

        return executeInTransaction(em -> {
            RouterDTO inactiveRouter = findInactiveRouter(em, t);
            if (inactiveRouter != null) {
                copyRouterData(inactiveRouter, t);
                t.setRouterId(inactiveRouter.getRouterId());
                return;
            }

            em.persist(t);
        });
    }

    public boolean add(RouterDTO t) {
        return insert(t);
    }

    @Override
    public boolean update(RouterDTO t) {
        if (t == null || t.getRouterId() <= 0) {
            return false;
        }

        return executeInTransaction(em -> {
            RouterDTO router = em.find(RouterDTO.class, t.getRouterId());
            if (router == null) {
                throw new IllegalArgumentException("Router not found");
            }

            copyRouterData(router, t);
        });
    }

    @Override
    public boolean remove(RouterDTO t) {
        if (t == null) {
            return false;
        }
        return softDelete(t.getRouterId());
    }

    @Override
    public ArrayList<RouterDTO> ListAll() {
        EntityManager em = getEntityManager();
        try {
            return new ArrayList<>(
                    em.createQuery(
                            "SELECT r FROM RouterDTO r WHERE r.status <> :status ORDER BY r.routerId",
                            RouterDTO.class)
                            .setParameter("status", INACTIVE_STATUS)
                            .getResultList()
            );
        } finally {
            em.close();
        }
    }

    public ArrayList<RouterDTO> listAll() {
        return ListAll();
    }

    @Override
    public RouterDTO searchById(Integer id) {
        if (id == null || id <= 0) {
            return null;
        }

        EntityManager em = getEntityManager();
        try {
            return em.find(RouterDTO.class, id);
        } finally {
            em.close();
        }
    }

    public RouterDTO searchByID(String id) {
        if (!hasText(id)) {
            return null;
        }

        try {
            return searchById(Integer.parseInt(id.trim()));
        } catch (NumberFormatException e) {
            return null;
        }
    }

    public ArrayList<RouterDTO> searchByName(String name) {
        EntityManager em = getEntityManager();
        try {
            return new ArrayList<>(
                    em.createQuery(
                            "SELECT r FROM RouterDTO r "
                            + "WHERE r.routerName LIKE :name AND r.status <> :status "
                            + "ORDER BY r.routerId",
                            RouterDTO.class)
                            .setParameter("name", "%" + (name == null ? "" : name.trim()) + "%")
                            .setParameter("status", INACTIVE_STATUS)
                            .getResultList()
            );
        } finally {
            em.close();
        }
    }

    public boolean softDelete(int routerID) {
        return updateStatus(routerID, INACTIVE_STATUS);
    }

    public boolean hardDelete(int routerID) {
        if (routerID <= 0) {
            return false;
        }

        return executeInTransaction(em -> {
            RouterDTO router = em.find(RouterDTO.class, routerID);
            if (router == null) {
                throw new IllegalArgumentException("Router not found");
            }

            em.remove(router);
        });
    }

    public boolean updateStatus(int routerId, String status) {
        if (routerId <= 0 || !hasText(status)) {
            return false;
        }

        return executeInTransaction(em -> {
            RouterDTO router = em.find(RouterDTO.class, routerId);
            if (router == null) {
                throw new IllegalArgumentException("Router not found");
            }

            router.setStatus(status.trim());
        });
    }

    public boolean restartRouter(int routerId) {
        return updateStatus(routerId, "MAINTENANCE");
    }

    private RouterDTO findInactiveRouter(EntityManager em, RouterDTO router) {
        boolean hasIpAddress = hasText(router.getIpAddress());
        boolean hasMacAddress = hasText(router.getMacAddress());
        if (!hasIpAddress && !hasMacAddress) {
            return null;
        }

        StringBuilder jpql = new StringBuilder(
                "SELECT r FROM RouterDTO r WHERE r.status = :status AND (");
        if (hasIpAddress) {
            jpql.append("r.ipAddress = :ipAddress");
        }
        if (hasMacAddress) {
            if (hasIpAddress) {
                jpql.append(" OR ");
            }
            jpql.append("r.macAddress = :macAddress");
        }
        jpql.append(") ORDER BY r.routerId");

        TypedQuery<RouterDTO> query = em.createQuery(jpql.toString(), RouterDTO.class)
                .setParameter("status", INACTIVE_STATUS)
                .setMaxResults(1);

        if (hasIpAddress) {
            query.setParameter("ipAddress", router.getIpAddress().trim());
        }
        if (hasMacAddress) {
            query.setParameter("macAddress", router.getMacAddress().trim());
        }

        List<RouterDTO> routers = query.getResultList();
        return routers.isEmpty() ? null : routers.get(0);
    }

    private void copyRouterData(RouterDTO target, RouterDTO source) {
        target.setRouterName(source.getRouterName());
        target.setIpAddress(source.getIpAddress());
        target.setMacAddress(source.getMacAddress());
        target.setModel(source.getModel());
        target.setFirmware(source.getFirmware());
        target.setStatus(source.getStatus());
        target.setLocation(source.getLocation());
        target.setRoomId(source.getRoomIdValue());
    }

    private boolean hasText(String value) {
        return value != null && !value.trim().isEmpty();
    }
}
