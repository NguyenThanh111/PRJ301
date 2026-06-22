
package Models;

public class RoomDTO {
    private int roomId;
    private String roomName;
    private String building;
    private int floor;
    private int capacity;

    public RoomDTO() {
    }

    public RoomDTO(int roomId, String roomName, String building, int floor, int capacity) {
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
}
