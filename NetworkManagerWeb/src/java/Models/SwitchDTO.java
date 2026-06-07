package Models;

public class SwitchDTO {
    private int switchId;
    private String switchName;
    private int totalPorts;
    private int usedPorts;
    private String ipAddress;
    private String status;
    private int roomId;

    public SwitchDTO() {
    }

    public SwitchDTO(int switchId, String switchName, int totalPorts, int usedPorts, String ipAddress, String status, int roomId) {
        this.switchId = switchId;
        this.switchName = switchName;
        this.totalPorts = totalPorts;
        this.usedPorts = usedPorts;
        this.ipAddress = ipAddress;
        this.status = status;
        this.roomId = roomId;
    }

    public int getSwitchId() {
        return switchId;
    }

    public void setSwitchId(int switchId) {
        this.switchId = switchId;
    }

    public String getSwitchName() {
        return switchName;
    }

    public void setSwitchName(String switchName) {
        this.switchName = switchName;
    }

    public int getTotalPorts() {
        return totalPorts;
    }

    public void setTotalPorts(int totalPorts) {
        this.totalPorts = totalPorts;
    }

    public int getUsedPorts() {
        return usedPorts;
    }

    public void setUsedPorts(int usedPorts) {
        this.usedPorts = usedPorts;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
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
