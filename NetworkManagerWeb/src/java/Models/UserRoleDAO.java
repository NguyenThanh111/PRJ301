package Models;

import java.util.ArrayList;
import java.util.List;
import java.util.function.Consumer;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.EntityTransaction;
import javax.persistence.Persistence;
import javax.persistence.TypedQuery;

public class UserRoleDAO {

    private static final String PERSISTENCE_UNIT_NAME = "NetworkManagerWebPU";
    private static final EntityManagerFactory FACTORY
            = Persistence.createEntityManagerFactory(PERSISTENCE_UNIT_NAME);

    public UserRoleDAO() {
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

    public boolean assignRole(UserRoleDTO dto) {
        if (dto == null) {
            return false;
        }
        return executeInTransaction(em -> em.persist(dto));
    }

    public boolean assignRole(int userId, int roleId) {
        return assignRole(new UserRoleDTO(userId, roleId));
    }

    public boolean removeRole(int userId, int roleId) {
        if (userId <= 0 || roleId <= 0) {
            return false;
        }
        return executeInTransaction(em -> {
            UserRoleDTO ur = em.find(UserRoleDTO.class, new UserRoleDTO.UserRoleId(userId, roleId));
            if (ur != null) {
                em.remove(ur);
            }
        });
    }

    public boolean removeAllRoles(int userId) {
        if (userId <= 0) {
            return false;
        }
        EntityManager em = getEntityManager();
        try {
            em.getTransaction().begin();
            em.createQuery("DELETE FROM UserRoleDTO ur WHERE ur.userId = :userId")
                    .setParameter("userId", userId)
                    .executeUpdate();
            em.getTransaction().commit();
            return true;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }

    public ArrayList<UserDTO> findUserByRole(int roleId) {
        EntityManager em = getEntityManager();
        try {
            List<UserDTO> users = em.createQuery(
                    "SELECT u FROM UserDTO u, UserRoleDTO ur "
                    + "WHERE u.userId = ur.userId AND ur.roleId = :roleId "
                    + "ORDER BY u.userId",
                    UserDTO.class)
                    .setParameter("roleId", roleId)
                    .getResultList();
            return new ArrayList<>(users);
        } finally {
            em.close();
        }
    }

    public String findRoleByUser(int userId) {
        EntityManager em = getEntityManager();
        try {
            List<String> roles = em.createQuery(
                    "SELECT r.roleName FROM RoleDTO r, UserRoleDTO ur "
                    + "WHERE r.roleId = ur.roleId AND ur.userId = :userId",
                    String.class)
                    .setParameter("userId", userId)
                    .setMaxResults(1)
                    .getResultList();
            return roles.isEmpty() ? "" : roles.get(0);
        } finally {
            em.close();
        }
    }

    public boolean hasRole(int userId, String roleName) {
        if (userId <= 0 || !hasText(roleName)) {
            return false;
        }
        EntityManager em = getEntityManager();
        try {
            TypedQuery<Long> query = em.createQuery(
                    "SELECT COUNT(ur) FROM UserRoleDTO ur, RoleDTO r "
                    + "WHERE ur.roleId = r.roleId AND ur.userId = :userId AND r.roleName = :roleName",
                    Long.class)
                    .setParameter("userId", userId)
                    .setParameter("roleName", roleName.trim());
            return query.getSingleResult() > 0;
        } finally {
            em.close();
        }
    }

    private boolean hasText(String value) {
        return value != null && !value.trim().isEmpty();
    }
}
