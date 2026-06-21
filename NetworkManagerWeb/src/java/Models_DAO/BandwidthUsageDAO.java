package Models_DAO;

import Models.BandwidthUsageDTO;
import java.util.ArrayList;
import java.util.List;
import java.util.function.Consumer;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.EntityTransaction;
import javax.persistence.Persistence;
import javax.persistence.Query;

public class BandwidthUsageDAO implements IDAO<BandwidthUsageDTO, Integer> {

    private static final String PERSISTENCE_UNIT_NAME = "NetworkManagerWebPU";
    private static final EntityManagerFactory FACTORY
            = Persistence.createEntityManagerFactory(PERSISTENCE_UNIT_NAME);

    public BandwidthUsageDAO() {
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
    public boolean insert(BandwidthUsageDTO t) {
        if (t == null) return false;
        if (t.getRecordTime() == null) {
            t.setRecordTime(new java.sql.Timestamp(System.currentTimeMillis()));
        }
        return executeInTransaction(em -> em.persist(t));
    }

    @Override
    public boolean remove(BandwidthUsageDTO t) {
        if (t == null) return false;
        return executeInTransaction(em -> {
            BandwidthUsageDTO entity = em.find(BandwidthUsageDTO.class, t.getUsageId());
            if (entity != null) {
                em.remove(entity);
            }
        });
    }

    @Override
    public boolean update(BandwidthUsageDTO t) {
        if (t == null || t.getUsageId() <= 0) return false;
        return executeInTransaction(em -> em.merge(t));
    }

    @Override
    public ArrayList<BandwidthUsageDTO> ListAll() {
        EntityManager em = getEntityManager();
        try {
            return new ArrayList<>(
                em.createQuery("SELECT b FROM BandwidthUsageDTO b ORDER BY b.recordTime DESC", BandwidthUsageDTO.class)
                  .getResultList()
            );
        } finally {
            em.close();
        }
    }

    @Override
    public BandwidthUsageDTO searchById(Integer id) {
        if (id == null || id <= 0) return null;
        EntityManager em = getEntityManager();
        try {
            return em.find(BandwidthUsageDTO.class, id);
        } finally {
            em.close();
        }
    }

    public ArrayList<BandwidthUsageDTO> findByDevice(int deviceId) {
        EntityManager em = getEntityManager();
        try {
            return new ArrayList<>(
                em.createQuery("SELECT b FROM BandwidthUsageDTO b WHERE b.deviceId = :deviceId ORDER BY b.recordTime DESC", BandwidthUsageDTO.class)
                  .setParameter("deviceId", deviceId)
                  .getResultList()
            );
        } finally {
            em.close();
        }
    }

    public ArrayList<BandwidthUsageDTO> findByDate(String date) {
        EntityManager em = getEntityManager();
        try {
            return new ArrayList<>(
                em.createQuery("SELECT b FROM BandwidthUsageDTO b WHERE CAST(b.recordTime AS date) = CAST(:date AS date) ORDER BY b.recordTime DESC", BandwidthUsageDTO.class)
                  .setParameter("date", java.sql.Date.valueOf(date))
                  .getResultList()
            );
        } finally {
            em.close();
        }
    }

    public ArrayList<BandwidthUsageDTO> findTopUsage(int topN) {
        EntityManager em = getEntityManager();
        try {
            String sql = "SELECT TOP (?) device_id AS deviceId, "
                       + "SUM(upload_speed) AS uploadSpeed, "
                       + "SUM(download_speed) AS downloadSpeed, "
                       + "MAX(record_time) AS recordTime "
                       + "FROM BandwidthUsage "
                       + "GROUP BY device_id "
                       + "ORDER BY (SUM(upload_speed) + SUM(download_speed)) DESC";
            Query q = em.createNativeQuery(sql);
            q.setParameter(1, topN);
            
            List<Object[]> results = q.getResultList();
            ArrayList<BandwidthUsageDTO> list = new ArrayList<>();
            for (Object[] row : results) {
                BandwidthUsageDTO dto = new BandwidthUsageDTO();
                dto.setDeviceId(((Number) row[0]).intValue());
                dto.setUploadSpeed(((Number) row[1]).doubleValue());
                dto.setDownloadSpeed(((Number) row[2]).doubleValue());
                
                Object dateObj = row[3];
                if (dateObj instanceof java.sql.Timestamp) {
                    dto.setRecordTime((java.sql.Timestamp) dateObj);
                } else if (dateObj instanceof java.util.Date) {
                    dto.setRecordTime(new java.sql.Timestamp(((java.util.Date) dateObj).getTime()));
                }
                list.add(dto);
            }
            return list;
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        } finally {
            em.close();
        }
    }

    public ArrayList<BandwidthUsageDTO> generateReport(String fromDate, String toDate) {
        EntityManager em = getEntityManager();
        try {
            String sql = "SELECT 0 AS usageId, 0 AS deviceId, "
                       + "SUM(upload_speed) AS uploadSpeed, "
                       + "SUM(download_speed) AS downloadSpeed, "
                       + "CAST(record_time AS DATE) AS recordTime "
                       + "FROM BandwidthUsage "
                       + "WHERE CAST(record_time AS DATE) BETWEEN ? AND ? "
                       + "GROUP BY CAST(record_time AS DATE) "
                       + "ORDER BY CAST(record_time AS DATE)";
            Query q = em.createNativeQuery(sql);
            q.setParameter(1, fromDate);
            q.setParameter(2, toDate);

            List<Object[]> results = q.getResultList();
            ArrayList<BandwidthUsageDTO> list = new ArrayList<>();
            for (Object[] row : results) {
                BandwidthUsageDTO dto = new BandwidthUsageDTO();
                dto.setUploadSpeed(((Number) row[2]).doubleValue());
                dto.setDownloadSpeed(((Number) row[3]).doubleValue());
                
                Object dateObj = row[4];
                if (dateObj instanceof java.sql.Timestamp) {
                    dto.setRecordTime((java.sql.Timestamp) dateObj);
                } else if (dateObj instanceof java.util.Date) {
                    dto.setRecordTime(new java.sql.Timestamp(((java.util.Date) dateObj).getTime()));
                } else if (dateObj instanceof java.sql.Date) {
                    dto.setRecordTime(new java.sql.Timestamp(((java.sql.Date) dateObj).getTime()));
                }
                list.add(dto);
            }
            return list;
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        } finally {
            em.close();
        }
    }
}
