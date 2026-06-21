/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Models_DAO;

import Models.NetworkAlertDTO;
import Utils.JpaUtils;
import java.util.ArrayList;
import javax.persistence.EntityManager;
import javax.persistence.TypedQuery;

/**
 *
 * @author nvtv0
 */
public class NetworkAlertDAO implements IDAO<NetworkAlertDTO, Integer>{

    @Override
    public boolean insert(NetworkAlertDTO t) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            if (t.getSeverity() == null) t.setSeverity("INFO");
            if (t.getCreatedAt() == null) t.setCreatedAt(new java.sql.Timestamp(System.currentTimeMillis()));
            em.persist(t);
            em.getTransaction().commit();
            return true;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
        return false;
    }

    @Override
    public boolean remove(NetworkAlertDTO t) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            NetworkAlertDTO entity = em.find(NetworkAlertDTO.class, t.getAlertId());
            if (entity != null) {
                em.remove(entity);
            }
            em.getTransaction().commit();
            return true;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
        return false;
    }

    @Override
    public boolean update(NetworkAlertDTO t) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            em.merge(t);
            em.getTransaction().commit();
            return true;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
        return false;
    }

    @Override
    public ArrayList<NetworkAlertDTO> ListAll() {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            TypedQuery<NetworkAlertDTO> query = em.createQuery("SELECT n FROM NetworkAlertDTO n ORDER BY n.createdAt DESC", NetworkAlertDTO.class);
            return new ArrayList<>(query.getResultList());
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return new ArrayList<>();
    }

    @Override
    public NetworkAlertDTO searchById(Integer id) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            return em.find(NetworkAlertDTO.class, id);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return null;
    }

    public ArrayList<NetworkAlertDTO> findByDevice(Integer routerId, Integer apId, Integer switchId) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            StringBuilder jpql = new StringBuilder("SELECT n FROM NetworkAlertDTO n WHERE 1=1 ");
            if (routerId != null) jpql.append("AND n.routerId = :routerId ");
            if (apId != null) jpql.append("AND n.apId = :apId ");
            if (switchId != null) jpql.append("AND n.switchId = :switchId ");
            jpql.append("ORDER BY n.createdAt DESC");
            
            TypedQuery<NetworkAlertDTO> query = em.createQuery(jpql.toString(), NetworkAlertDTO.class);
            if (routerId != null) query.setParameter("routerId", routerId);
            if (apId != null) query.setParameter("apId", apId);
            if (switchId != null) query.setParameter("switchId", switchId);
            
            return new ArrayList<>(query.getResultList());
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return new ArrayList<>();
    }

    public ArrayList<NetworkAlertDTO> findBySeverity(String severity) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            TypedQuery<NetworkAlertDTO> query = em.createQuery("SELECT n FROM NetworkAlertDTO n WHERE n.severity = :severity ORDER BY n.createdAt DESC", NetworkAlertDTO.class);
            query.setParameter("severity", severity);
            return new ArrayList<>(query.getResultList());
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return new ArrayList<>();
    }

    public boolean resolveAlert(int alertId) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            NetworkAlertDTO entity = em.find(NetworkAlertDTO.class, alertId);
            if (entity != null) {
                em.remove(entity);
            }
            em.getTransaction().commit();
            return true;
        } catch (Exception e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
        return false;
    }
    
    public int countAll() {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            TypedQuery<Long> query = em.createQuery("SELECT COUNT(n) FROM NetworkAlertDTO n", Long.class);
            return query.getSingleResult().intValue();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return 0;
    }

}
