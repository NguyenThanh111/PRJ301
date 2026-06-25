package Models_DAO;

import Models.RoomDTO;
import Utils.JpaUtils;

import Models.VLANDTO;
import Utils.DbUtils;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.TypedQuery;

public class VLANDAO implements IDAO<VLANDTO, Integer> {

    // =========================
    // CREATE
    // =========================
    @Override
    public boolean insert(VLANDTO vlan) {

        if (vlan == null) {
            return false;
        }

        EntityManager em = JpaUtils.getEntityManager();
        EntityTransaction transaction = em.getTransaction();

        try {
            transaction.begin();

            em.persist(vlan);

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

    // =========================
    // UPDATE
    // =========================
    @Override
    public boolean update(VLANDTO vlan) {

        if (vlan == null || vlan.getVlanId() <= 0) {
            return false;
        }

        EntityManager em = JpaUtils.getEntityManager();
        EntityTransaction transaction = em.getTransaction();

        try {
            transaction.begin();

            VLANDTO existingVLAN = em.find(
                    VLANDTO.class,
                    vlan.getVlanId()
            );

            if (existingVLAN == null) {
                transaction.rollback();
                return false;
            }

            existingVLAN.setVlanName(vlan.getVlanName());
            existingVLAN.setSubnet(vlan.getSubnet());
            existingVLAN.setPurpose(vlan.getPurpose());
            existingVLAN.setRoomId(vlan.getRoomId());

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

    // =========================
    // DELETE
    // =========================
    @Override
    public boolean remove(VLANDTO vlan) {

        if (vlan == null || vlan.getVlanId() <= 0) {
            return false;
        }

        return delete(vlan.getVlanId());
    }

    public boolean delete(int vlanId) {

        if (vlanId <= 0) {
            return false;
        }

        EntityManager em = JpaUtils.getEntityManager();
        EntityTransaction transaction = em.getTransaction();

        try {
            transaction.begin();

            VLANDTO vlan = em.find(
                    VLANDTO.class,
                    vlanId
            );

            if (vlan == null) {
                transaction.rollback();
                return false;
            }

            em.remove(vlan);

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

    // =========================
    // READ ALL
    // =========================
    @Override
    public ArrayList<VLANDTO> ListAll() {

        EntityManager em = JpaUtils.getEntityManager();

        try {
            TypedQuery<VLANDTO> query = em.createQuery(
                    "SELECT v FROM VLAN v "
                    + "ORDER BY v.vlanId",
                    VLANDTO.class
            );

            return new ArrayList<>(
                    query.getResultList()
            );

        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();

        } finally {
            em.close();
        }
    }

    // =========================
    // SEARCH BY ID
    // =========================
    @Override
    public VLANDTO searchById(Integer id) {

        if (id == null || id <= 0) {
            return null;
        }

        EntityManager em = JpaUtils.getEntityManager();

        try {
            return em.find(VLANDTO.class, id);

        } catch (Exception e) {
            e.printStackTrace();
            return null;

        } finally {
            em.close();
        }
    }

    // =========================
    // PAGINATION
    // =========================
    public ArrayList<VLANDTO> getVLANsByPage(
            int page,
            int pageSize) {

        return getVLANsByPage(page, pageSize, null);
    }

    public ArrayList<VLANDTO> getVLANsByPage(
            int page,
            int pageSize,
            String keyword) {

        if (page < 1) {
            page = 1;
        }

        if (pageSize < 1) {
            pageSize = 9;
        }

        EntityManager em = JpaUtils.getEntityManager();

        try {
            boolean hasKeyword = hasText(keyword);
            String jpql = "SELECT v FROM VLAN v ";

            if (hasKeyword) {
                jpql += "WHERE LOWER(v.vlanName) LIKE :keyword "
                        + "OR LOWER(v.subnet) LIKE :keyword "
                        + "OR LOWER(v.purpose) LIKE :keyword ";
            }

            jpql += "ORDER BY v.vlanId";

            TypedQuery<VLANDTO> query = em.createQuery(
                    jpql,
                    VLANDTO.class
            );

            if (hasKeyword) {
                query.setParameter(
                        "keyword",
                        "%" + keyword.trim().toLowerCase() + "%"
                );
            }

            int firstResult = (page - 1) * pageSize;

            query.setFirstResult(firstResult);
            query.setMaxResults(pageSize);

            List<VLANDTO> result = query.getResultList();

            return new ArrayList<>(result);

        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();

        } finally {
            em.close();
        }
    }

    public long countAllVLANs() {

        return countVLANs(null);
    }

    public long countVLANs(String keyword) {

        EntityManager em = JpaUtils.getEntityManager();

        try {
            boolean hasKeyword = hasText(keyword);
            String jpql = "SELECT COUNT(v) FROM VLAN v";

            if (hasKeyword) {
                jpql += " WHERE LOWER(v.vlanName) LIKE :keyword "
                        + "OR LOWER(v.subnet) LIKE :keyword "
                        + "OR LOWER(v.purpose) LIKE :keyword";
            }

            TypedQuery<Long> query = em.createQuery(
                    jpql,
                    Long.class
            );

            if (hasKeyword) {
                query.setParameter(
                        "keyword",
                        "%" + keyword.trim().toLowerCase() + "%"
                );
            }

            return query.getSingleResult();

        } catch (Exception e) {
            e.printStackTrace();
            return 0;

        } finally {
            em.close();
        }
    }

    private boolean hasText(String value) {
        return value != null && !value.trim().isEmpty();
    }

    public boolean roomExists(Integer roomId) {

        if (roomId == null) {
            return true;
        }

        EntityManager em = JpaUtils.getEntityManager();

        try {
            RoomDTO room = em.find(
                    RoomDTO.class,
                    roomId
            );

            return room != null;

        } catch (Exception e) {
            e.printStackTrace();
            return false;

        } finally {
            em.close();
        }
    }
}
