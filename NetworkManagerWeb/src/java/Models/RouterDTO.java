package Models;

import java.io.Serializable;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "Router")
public class RouterDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "router_id")
    private int routerId;

    @Column(name = "router_name", nullable = false, length = 100)
    private String routerName;

    @Column(name = "ip_address", length = 45, unique = true)
    private String ipAddress;

    @Column(name = "mac_address", length = 50, unique = true)
    private String macAddress;

    @Column(name = "model", length = 100)
    private String model;

    @Column(name = "firmware", length = 100)
    private String firmware;

    @Column(name = "status", length = 20)
    private String status;

    @Column(name = "location", length = 100)
    private String location;

    @Column(name = "room_id")
    private Integer roomId;

    public RouterDTO() {
    }

    public RouterDTO(int routerId, String routerName, String ipAddress, String macAddress, String model, String firmware, String status, String location, int roomId) {
        this.routerId = routerId;
        this.routerName = routerName;
        this.ipAddress = ipAddress;
        this.macAddress = macAddress;
        this.model = model;
        this.firmware = firmware;
        this.status = status;
        this.location = location;
        setRoomId(roomId);
    }

    public int getRouterId() {
        return routerId;
    }

    public void setRouterId(int routerId) {
        this.routerId = routerId;
    }

    public String getRouterName() {
        return routerName;
    }

    public void setRouterName(String routerName) {
        this.routerName = routerName;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }

    public String getMacAddress() {
        return macAddress;
    }

    public void setMacAddress(String macAddress) {
        this.macAddress = macAddress;
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }

    public String getFirmware() {
        return firmware;
    }

    public void setFirmware(String firmware) {
        this.firmware = firmware;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public int getRoomId() {
        return roomId == null ? 0 : roomId;
    }

    public Integer getRoomIdValue() {
        return roomId;
    }

    public void setRoomId(int roomId) {
        this.roomId = roomId > 0 ? roomId : null;
    }

    public void setRoomId(Integer roomId) {
        this.roomId = roomId != null && roomId > 0 ? roomId : null;
    }
}
