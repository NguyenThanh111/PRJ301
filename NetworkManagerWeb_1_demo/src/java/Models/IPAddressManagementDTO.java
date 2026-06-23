package Models;

public class IPAddressManagementDTO {

    private int ipId;
    private String ipAddress;
    private String status;
    private Integer deviceId;

    public IPAddressManagementDTO() {
    }

    public IPAddressManagementDTO(int ipId,
                                  String ipAddress,
                                  String status,
                                  Integer deviceId) {
        this.ipId = ipId;
        this.ipAddress = ipAddress;
        this.status = status;
        this.deviceId = deviceId;
    }

    public int getIpId() {
        return ipId;
    }

    public void setIpId(int ipId) {
        this.ipId = ipId;
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

    public Integer getDeviceId() {
        return deviceId;
    }

    public void setDeviceId(Integer deviceId) {
        this.deviceId = deviceId;
    }

    @Override
    public String toString() {
        return "IPAddressManagementDTO{" +
                "ipId=" + ipId +
                ", ipAddress='" + ipAddress + '\'' +
                ", status='" + status + '\'' +
                ", deviceId=" + deviceId +
                '}';
    }
}