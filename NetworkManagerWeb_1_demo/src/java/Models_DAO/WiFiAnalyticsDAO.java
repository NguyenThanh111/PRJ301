/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Models_DAO;

import Models.WiFiAnalyticsDTO;
import Utils.JpaUtils;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;
import javax.persistence.EntityManager;
import javax.persistence.TypedQuery;

/**
 *
 * @author nvtv0
 */
public class WiFiAnalyticsDAO implements IDAO<WiFiAnalyticsDTO, Integer> {

    @Override
    public boolean insert(WiFiAnalyticsDTO t) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
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
    public boolean remove(WiFiAnalyticsDTO t) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            WiFiAnalyticsDTO entity = em.find(WiFiAnalyticsDTO.class, t.getAnalyticsId());
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
    public boolean update(WiFiAnalyticsDTO t) {
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
    public ArrayList<WiFiAnalyticsDTO> ListAll() {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            TypedQuery<WiFiAnalyticsDTO> query = em.createQuery("SELECT w FROM WiFiAnalyticsDTO w ORDER BY w.analyticsDate DESC", WiFiAnalyticsDTO.class);
            return new ArrayList<>(query.getResultList());
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return new ArrayList<>();
    }

    @Override
    public WiFiAnalyticsDTO searchById(Integer id) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            return em.find(WiFiAnalyticsDTO.class, id);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return null;
    }


    public ArrayList<WiFiAnalyticsDTO> findByAP(int apId) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            TypedQuery<WiFiAnalyticsDTO> query = em.createQuery("SELECT w FROM WiFiAnalyticsDTO w WHERE w.apId = :apId ORDER BY w.analyticsDate DESC", WiFiAnalyticsDTO.class);
            query.setParameter("apId", apId);
            return new ArrayList<>(query.getResultList());
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return new ArrayList<>();
    }

    public boolean generateDailyAnalytics(int apId, int totalUsers, int peakUsers, double avgSpeed) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            em.getTransaction().begin();
            // Check if exists for today
            TypedQuery<WiFiAnalyticsDTO> query = em.createQuery(
                "SELECT w FROM WiFiAnalyticsDTO w WHERE w.apId = :apId AND w.analyticsDate = CURRENT_DATE", 
                WiFiAnalyticsDTO.class);
            query.setParameter("apId", apId);
            
            List<WiFiAnalyticsDTO> results = query.getResultList();
            if (!results.isEmpty()) {
                WiFiAnalyticsDTO existing = results.get(0);
                existing.setTotalUsers(totalUsers);
                existing.setPeakUsers(peakUsers);
                existing.setAvgSpeed(avgSpeed);
                em.merge(existing);
            } else {
                WiFiAnalyticsDTO newAnalytics = new WiFiAnalyticsDTO();
                newAnalytics.setApId(apId);
                newAnalytics.setTotalUsers(totalUsers);
                newAnalytics.setPeakUsers(peakUsers);
                newAnalytics.setAvgSpeed(avgSpeed);
                newAnalytics.setAnalyticsDate(new Date(System.currentTimeMillis()));
                em.persist(newAnalytics);
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


    public ArrayList<WiFiAnalyticsDTO> generateMonthlyAnalytics(int apId, int year, int month) {
        EntityManager em = JpaUtils.getEntityManager();
        try {
            // JPQL doesn't universally support YEAR/MONTH functions without provider specific extensions or EXTRACT
            // A portable way is to use between with dates
            String dateStringStart = String.format("%04d-%02d-01", year, month);
            Date startDate = Date.valueOf(dateStringStart);
            
            // Calculate end date (next month 1st day minus 1 ms, or just strictly less than next month start)
            int nextMonth = month == 12 ? 1 : month + 1;
            int nextYear = month == 12 ? year + 1 : year;
            String dateStringEnd = String.format("%04d-%02d-01", nextYear, nextMonth);
            Date endDate = Date.valueOf(dateStringEnd);

            TypedQuery<WiFiAnalyticsDTO> query = em.createQuery(
                "SELECT w FROM WiFiAnalyticsDTO w WHERE w.apId = :apId AND w.analyticsDate >= :startDate AND w.analyticsDate < :endDate ORDER BY w.analyticsDate", 
                WiFiAnalyticsDTO.class);
            query.setParameter("apId", apId);
            query.setParameter("startDate", startDate);
            query.setParameter("endDate", endDate);
            
            return new ArrayList<>(query.getResultList());
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return new ArrayList<>();
    }

}
