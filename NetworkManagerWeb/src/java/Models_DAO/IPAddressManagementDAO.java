

package Models_DAO;

import Utils.JpaUtils;

import Models.IPAddressManagementDTO;
import Utils.DbUtils;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.TypedQuery;

public class IPAddressManagementDAO {

    public ArrayList<IPAddressManagementDTO> ListAll() {

        EntityManager em = JpaUtils.getEntityManager();

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

        EntityManager em = JpaUtils.getEntityManager();

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

        return getIPsByPage(page, pageSize, null);
    }

    public ArrayList<IPAddressManagementDTO> getIPsByPage(
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
            Integer numericKeyword = parseInteger(keyword);
            String jpql = "SELECT ip "
                    + "FROM IPAddressManagementDTO ip ";

            if (hasKeyword) {
                jpql += "WHERE LOWER(ip.ipAddress) LIKE :keyword "
                        + "OR LOWER(ip.status) LIKE :keyword ";

                if (numericKeyword != null) {
                    jpql += "OR ip.ipId = :numberKeyword "
                            + "OR ip.deviceId = :numberKeyword ";
                }
            }

            jpql += "ORDER BY ip.ipId";

            TypedQuery<IPAddressManagementDTO> query
                    = em.createQuery(
                            jpql,
                            IPAddressManagementDTO.class
                    );

            if (hasKeyword) {
                query.setParameter(
                        "keyword",
                        "%" + keyword.trim().toLowerCase() + "%"
                );

                if (numericKeyword != null) {
                    query.setParameter(
                            "numberKeyword",
                            numericKeyword
                    );
                }
            }

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

        return countIPs(null);
    }

    public long countIPs(String keyword) {

        EntityManager em = JpaUtils.getEntityManager();

        try {
            boolean hasKeyword = hasText(keyword);
            Integer numericKeyword = parseInteger(keyword);
            String jpql = "SELECT COUNT(ip) "
                    + "FROM IPAddressManagementDTO ip";

            if (hasKeyword) {
                jpql += " WHERE LOWER(ip.ipAddress) LIKE :keyword "
                        + "OR LOWER(ip.status) LIKE :keyword";

                if (numericKeyword != null) {
                    jpql += " OR ip.ipId = :numberKeyword "
                            + "OR ip.deviceId = :numberKeyword";
                }
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

                if (numericKeyword != null) {
                    query.setParameter(
                            "numberKeyword",
                            numericKeyword
                    );
                }
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

    private Integer parseInteger(String value) {
        if (!hasText(value)) {
            return null;
        }

        try {
            return Integer.valueOf(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    
    public ArrayList<IPAddressManagementDTO> findAvailableIPs() {

        EntityManager em = JpaUtils.getEntityManager();

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

    public IPAddressManagementDTO findAvailableIP() {
        ArrayList<IPAddressManagementDTO> availableIPs = findAvailableIPs();

        if (availableIPs.isEmpty()) {
            return null;
        }

        return availableIPs.get(0);
    }

    public boolean assignIP(int ipId, int deviceId) {
        if (ipId <= 0 || deviceId <= 0) {
            return false;
        }

        EntityManager em = JpaUtils.getEntityManager();
        EntityTransaction transaction = em.getTransaction();

        try {
            transaction.begin();

            IPAddressManagementDTO ip
                    = em.find(IPAddressManagementDTO.class, ipId);

            if (ip == null || ip.getDeviceId() != null) {
                transaction.rollback();
                return false;
            }

            ip.setDeviceId(deviceId);
            ip.setStatus("ASSIGNED");

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

    public boolean releaseIP(int ipId) {
        if (ipId <= 0) {
            return false;
        }

        EntityManager em = JpaUtils.getEntityManager();
        EntityTransaction transaction = em.getTransaction();

        try {
            transaction.begin();

            IPAddressManagementDTO ip
                    = em.find(IPAddressManagementDTO.class, ipId);

            if (ip == null) {
                transaction.rollback();
                return false;
            }

            ip.setDeviceId(null);
            ip.setStatus("AVAILABLE");

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

    
    public IPAddressManagementDTO findByDevice(
            Integer deviceId) {

        if (deviceId == null || deviceId <= 0) {
            return null;
        }

        EntityManager em = JpaUtils.getEntityManager();

        try {
            TypedQuery<IPAddressManagementDTO> query
                    = em.createQuery(
                            "SELECT ip "
                            + "FROM IPAddressManagementDTO ip "
                            + "WHERE ip.deviceId = :deviceId",
                            IPAddressManagementDTO.class
                    );

            query.setParameter("deviceId", deviceId);

            ArrayList<IPAddressManagementDTO> result
                    = new ArrayList<>(query.getResultList());

            if (result.isEmpty()) {
                return null;
            }

            return result.get(0);

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

        EntityManager em = JpaUtils.getEntityManager();

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
