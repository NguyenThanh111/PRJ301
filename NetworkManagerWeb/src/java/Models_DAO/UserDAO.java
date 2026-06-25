package Models_DAO;

import Models.UserDTO;
import Models_DAO.IDAO;
import Utils.PasswordUtils;
import java.util.ArrayList;
import java.util.List;
import java.util.function.Consumer;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.EntityTransaction;
import javax.persistence.Persistence;
import javax.persistence.TypedQuery;

public class UserDAO implements IDAO<UserDTO, Integer> {

    private static final String PERSISTENCE_UNIT_NAME = "NetworkManagerWebPU";
    private static final EntityManagerFactory FACTORY
            = Persistence.createEntityManagerFactory(PERSISTENCE_UNIT_NAME);

    public UserDAO() {
    }

    private EntityManager getEntityManager() {
        return FACTORY.createEntityManager();
    }

    public boolean executeInTransaction(Consumer<EntityManager> action) {
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
    public boolean insert(UserDTO t) {
        if (t == null) {
            return false;
        }
        return executeInTransaction(em -> em.persist(t));
    }

    @Override
    public boolean update(UserDTO t) {
        if (t == null || t.getUserId() <= 0) {
            return false;
        }
        return executeInTransaction(em -> {
            UserDTO user = em.find(UserDTO.class, t.getUserId());
            if (user == null) {
                throw new IllegalArgumentException("User not found");
            }
            copyUserData(user, t);
        });
    }

    @Override
    public boolean remove(UserDTO t) {
        if (t == null) {
            return false;
        }
        return softDelete(t.getUserId());
    }

    @Override
    public ArrayList<UserDTO> ListAll() {
        EntityManager em = getEntityManager();
        try {
            return new ArrayList<>(
                    em.createQuery("SELECT u FROM UserDTO u ORDER BY u.userId", UserDTO.class)
                            .getResultList()
            );
        } finally {
            em.close();
        }
    }

    @Override
    public UserDTO searchById(Integer id) {
        if (id == null || id <= 0) {
            return null;
        }
        EntityManager em = getEntityManager();
        try {
            return em.find(UserDTO.class, id);
        } finally {
            em.close();
        }
    }

    public UserDTO searchByNameOrEmail(String input) {
        if (!hasText(input)) {
            return null;
        }
        EntityManager em = getEntityManager();
        try {
            TypedQuery<UserDTO> query = em.createQuery(
                    "SELECT u FROM UserDTO u WHERE u.username = :input OR u.email = :input",
                    UserDTO.class)
                    .setParameter("input", input.trim())
                    .setMaxResults(1);
            List<UserDTO> users = query.getResultList();
            return users.isEmpty() ? null : users.get(0);
        } finally {
            em.close();
        }
    }

    public boolean checklogin(String username, String password) {
        if (!hasText(username) || !hasText(password)) {
            return false;
        }
        UserDTO user = searchByNameOrEmail(username);
        if (user == null) {
            return false;
        }
        if (!user.isActive()) {
            return false;
        }
        return PasswordUtils.verifyPassword(password, user.getPassword());
    }

    public boolean softDelete(int userId) {
        return updateStatus(userId, "INACTIVE");
    }

    public boolean updateStatus(int userId, String status) {
        if (userId <= 0 || !hasText(status)) {
            return false;
        }
        return executeInTransaction(em -> {
            UserDTO user = em.find(UserDTO.class, userId);
            if (user == null) {
                throw new IllegalArgumentException("User not found");
            }
            user.setStatus(status.trim());
        });
    }

    public ArrayList<UserDTO> searchListByKeyword(String keyword) {
        if (!hasText(keyword)) {
            return new ArrayList<>();
        }
        EntityManager em = getEntityManager();
        try {
            String pattern = "%" + keyword.trim() + "%";
            return new ArrayList<>(
                    em.createQuery(
                            "SELECT u FROM UserDTO u "
                            + "WHERE u.username LIKE :keyword OR u.email LIKE :keyword OR u.fullName LIKE :keyword "
                            + "ORDER BY u.userId",
                            UserDTO.class)
                            .setParameter("keyword", pattern)
                            .getResultList()
            );
        } finally {
            em.close();
        }
    }

    private void copyUserData(UserDTO target, UserDTO source) {
        target.setUsername(source.getUsername());
        target.setPassword(source.getPassword());
        target.setFullName(source.getFullName());
        target.setEmail(source.getEmail());
        target.setStatus(source.getStatus());
        target.setAvatar(source.getAvatar());
    }

    private boolean hasText(String value) {
        return value != null && !value.trim().isEmpty();
    }
}
