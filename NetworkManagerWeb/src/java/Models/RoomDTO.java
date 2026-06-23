
package Models;

import java.io.Serializable;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity(name = "Room")
@Table(name = "Room")
public class RoomDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "room_id")
    private int roomId;

    @Column(name = "room_name", nullable = false, length = 100)
    private String roomName;

    @Column(name = "building", length = 100)
    private String building;

    @Column(name = "floor")
    private int floor;

    @Column(name = "capacity")
    private int capacity;

    // JPA bắt buộc cần constructor rỗng
    public RoomDTO() {
    }

    public RoomDTO(int roomId, String roomName,
            String building, int floor, int capacity) {

        this.roomId = roomId;
        this.roomName = roomName;
        this.building = building;
        this.floor = floor;
        this.capacity = capacity;
    }

    public int getRoomId() {
        return roomId;
    }

    public void setRoomId(int roomId) {
        this.roomId = roomId;
    }

    public String getRoomName() {
        return roomName;
    }

    public void setRoomName(String roomName) {
        this.roomName = roomName;
    }

    public String getBuilding() {
        return building;
    }

    public void setBuilding(String building) {
        this.building = building;
    }

    public int getFloor() {
        return floor;
    }

    public void setFloor(int floor) {
        this.floor = floor;
    }

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    @Override
    public String toString() {
        return "RoomDTO{"
                + "roomId=" + roomId
                + ", roomName=" + roomName
                + ", building=" + building
                + ", floor=" + floor
                + ", capacity=" + capacity
                + '}';
    }
}

