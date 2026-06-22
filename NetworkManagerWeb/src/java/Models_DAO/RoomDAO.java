

package Models_DAO;

import Utils.JpaUtils;

import Models.RoomDTO;
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

public class RoomDAO implements IDAO<RoomDTO, Integer> {
    @Override
    public boolean insert(RoomDTO room) {

        if (room == null) {
            return false;
        }

        EntityManager em = JpaUtils.getEntityManager();
        EntityTransaction transaction = em.getTransaction();

        try {
            transaction.begin();

            em.persist(room);

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
    public boolean update(RoomDTO room) {

        if (room == null || room.getRoomId() <= 0) {
            return false;
        }

        EntityManager em = JpaUtils.getEntityManager();
        EntityTransaction transaction = em.getTransaction();

        try {
            transaction.begin();

            RoomDTO existingRoom = em.find(
                    RoomDTO.class,
                    room.getRoomId()
            );

            if (existingRoom == null) {
                transaction.rollback();
                return false;
            }

            existingRoom.setRoomName(room.getRoomName());
            existingRoom.setBuilding(room.getBuilding());
            existingRoom.setFloor(room.getFloor());
            existingRoom.setCapacity(room.getCapacity());

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
    public boolean remove(RoomDTO room) {

        if (room == null || room.getRoomId() <= 0) {
            return false;
        }

        return delete(room.getRoomId());
    }

    public boolean delete(int roomId) {

        if (roomId <= 0) {
            return false;
        }

        EntityManager em = JpaUtils.getEntityManager();
        EntityTransaction transaction = em.getTransaction();

        try {
            transaction.begin();

            RoomDTO room = em.find(RoomDTO.class, roomId);

            if (room == null) {
                transaction.rollback();
                return false;
            }

            em.remove(room);

            transaction.commit();
            return true;

        } catch (Exception e) {

            if (transaction.isActive()) {
                transaction.rollback();
            }

            /*
             * Trường hợp Room đang được Router, VLAN,
             * AccessPoint... tham chiếu thì database
             * sẽ chặn xóa và method trả về false.
             */
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
    public ArrayList<RoomDTO> ListAll() {

        EntityManager em = JpaUtils.getEntityManager();

        try {
            TypedQuery<RoomDTO> query = em.createQuery(
                    "SELECT r FROM Room r "
                    + "ORDER BY r.roomId",
                    RoomDTO.class
            );

            return new ArrayList<>(query.getResultList());

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
    public RoomDTO searchById(Integer id) {

        if (id == null || id <= 0) {
            return null;
        }

        EntityManager em = JpaUtils.getEntityManager();

        try {
            return em.find(RoomDTO.class, id);

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
    public ArrayList<RoomDTO> getRoomsByPage(
            int page,
            int pageSize) {

        if (page < 1) {
            page = 1;
        }

        if (pageSize < 1) {
            pageSize = 5;
        }

        EntityManager em = JpaUtils.getEntityManager();

        try {
            TypedQuery<RoomDTO> query = em.createQuery(
                    "SELECT r FROM Room r "
                    + "ORDER BY r.roomId",
                    RoomDTO.class
            );

            int firstResult = (page - 1) * pageSize;

            query.setFirstResult(firstResult);
            query.setMaxResults(pageSize);

            List<RoomDTO> result = query.getResultList();

            return new ArrayList<>(result);

        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();

        } finally {
            em.close();
        }
    }

    // =========================
    // COUNT FOR PAGINATION
    // =========================
    public long countAllRooms() {

        EntityManager em = JpaUtils.getEntityManager();

        try {
            TypedQuery<Long> query = em.createQuery(
                    "SELECT COUNT(r) FROM Room r",
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
}
