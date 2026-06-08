package Models;

public class NetworkDeviceDTO {
    private int deviceId;
    private String deviceName;
    private String macAddress;
    private String ipAddress;
    private String owner;
    private String deviceType;
    private String status;
    private int roomId;

    public NetworkDeviceDTO() {
    }

    public NetworkDeviceDTO(int deviceId, String deviceName, String macAddress, String ipAddress, String owner, String deviceType, String status) {
        this.deviceId = deviceId;
        this.deviceName = deviceName;
        this.macAddress = macAddress;
        this.ipAddress = ipAddress;
        this.owner = owner;
        this.deviceType = deviceType;
        this.status = status;
    }

    public NetworkDeviceDTO(int deviceId, String deviceName, String macAddress, String ipAddress, String owner, String deviceType, String status, int roomId) {
        this.deviceId = deviceId;
        this.deviceName = deviceName;
        this.macAddress = macAddress;
        this.ipAddress = ipAddress;
        this.owner = owner;
        this.deviceType = deviceType;
        this.status = status;
        this.roomId = roomId;
    }

    public int getDeviceId() {
        return deviceId;
    }

    public void setDeviceId(int deviceId) {
        this.deviceId = deviceId;
    }

    public String getDeviceName() {
        return deviceName;
    }

    public void setDeviceName(String deviceName) {
        this.deviceName = deviceName;
    }

    public String getMacAddress() {
        return macAddress;
    }

    public void setMacAddress(String macAddress) {
        this.macAddress = macAddress;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }

    public String getOwner() {
        return owner;
    }

    public void setOwner(String owner) {
        this.owner = owner;
    }

    public String getDeviceType() {
        return deviceType;
    }

    public void setDeviceType(String deviceType) {
        this.deviceType = deviceType;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getRoomId() {
        return roomId;
    }

    public void setRoomId(int roomId) {
        this.roomId = roomId;
    }
}
