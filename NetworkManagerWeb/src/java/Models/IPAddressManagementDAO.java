
package Models;

import Utils.JPAUtil;
import java.util.ArrayList;
import javax.persistence.EntityManager;
import javax.persistence.TypedQuery;

public class IPAddressManagementDAO {

    public ArrayList<IPAddressManagementDTO> ListAll() {

        EntityManager em = JPAUtil.getEntityManager();

        try {
            TypedQuery<IPAddressManagementDTO> query
                    = em.createQuery(
                            "SELECT ip "
                            + "FROM IPAddressManagementDTO ip "
                            + "ORDER BY ip.ipId",
                            IPAddressManagementDTO.class
                    );

            return new ArrayList<>(query.getResultList());

        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();

        } finally {
            em.close();
        }
    }
    public IPAddressManagementDTO searchById(Integer ipId) {

        if (ipId == null || ipId <= 0) {
            return null;
        }

        EntityManager em = JPAUtil.getEntityManager();

        try {
            return em.find(
                    IPAddressManagementDTO.class,
                    ipId
            );

        } catch (Exception e) {
            e.printStackTrace();
            return null;

        } finally {
            em.close();
        }
    }

    
    public ArrayList<IPAddressManagementDTO> getIPsByPage(
            int page,
            int pageSize) {

        if (page < 1) {
            page = 1;
        }

        if (pageSize < 1) {
            pageSize = 8;
        }

        EntityManager em = JPAUtil.getEntityManager();

        try {
            TypedQuery<IPAddressManagementDTO> query
                    = em.createQuery(
                            "SELECT ip "
                            + "FROM IPAddressManagementDTO ip "
                            + "ORDER BY ip.ipId",
                            IPAddressManagementDTO.class
                    );

            int firstResult = (page - 1) * pageSize;

            query.setFirstResult(firstResult);
            query.setMaxResults(pageSize);

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

    public long countAllIPs() {

        EntityManager em = JPAUtil.getEntityManager();

        try {
            TypedQuery<Long> query = em.createQuery(
                    "SELECT COUNT(ip) "
                    + "FROM IPAddressManagementDTO ip",
                    Long.class
            );

            return query.getSingleResult();

        } catch (Exception e) {
            e.printStackTrace();
            return 0;

        } finally {
            em.close();
        }
    }

    
    public ArrayList<IPAddressManagementDTO> findAvailableIPs() {

        EntityManager em = JPAUtil.getEntityManager();

        try {
            TypedQuery<IPAddressManagementDTO> query
                    = em.createQuery(
                            "SELECT ip "
                            + "FROM IPAddressManagementDTO ip "
                            + "WHERE UPPER(ip.status) = :status "
                            + "AND ip.deviceId IS NULL "
                            + "ORDER BY ip.ipAddress",
                            IPAddressManagementDTO.class
                    );

            query.setParameter("status", "AVAILABLE");

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

    
    public IPAddressManagementDTO findByDevice(
            Integer deviceId) {

        if (deviceId == null || deviceId <= 0) {
            return null;
        }

        EntityManager em = JPAUtil.getEntityManager();

        try {
            TypedQuery<IPAddressManagementDTO> query
                    = em.createQuery(
                            "SELECT ip "
                            + "FROM IPAddressManagementDTO ip "
                            + "WHERE ip.deviceId = :deviceId",
                            IPAddressManagementDTO.class
                    );

            query.setParameter("deviceId", deviceId);

            return query.getResultStream()
                    .findFirst()
                    .orElse(null);

        } catch (Exception e) {
            e.printStackTrace();
            return null;

        } finally {
            em.close();
        }
    }

    
    public long countByStatus(String status) {

        if (status == null || status.trim().isEmpty()) {
            return 0;
        }

        EntityManager em = JPAUtil.getEntityManager();

        try {
            TypedQuery<Long> query = em.createQuery(
                    "SELECT COUNT(ip) "
                    + "FROM IPAddressManagementDTO ip "
                    + "WHERE UPPER(ip.status) = :status",
                    Long.class
            );

            query.setParameter(
                    "status",
                    status.trim().toUpperCase()
            );

            return query.getSingleResult();

        } catch (Exception e) {
            e.printStackTrace();
            return 0;

        } finally {
            em.close();
        }
    }
}
