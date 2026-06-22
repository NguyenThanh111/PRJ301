
package Models;

import java.io.Serializable;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "IPAddressManagement")
public class IPAddressManagementDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ip_id")
    private int ipId;

    @Column(
            name = "ip_address",
            nullable = false,
            unique = true,
            length = 45
    )
    private String ipAddress;

    @Column(
            name = "status",
            nullable = false,
            length = 30
    )
    private String status;

    @Column(name = "device_id", unique = true)
    private Integer deviceId;

    public IPAddressManagementDTO() {
    }

    public IPAddressManagementDTO(
            int ipId,
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
        return "IPAddressManagementDTO{"
                + "ipId=" + ipId
                + ", ipAddress='" + ipAddress + '\''
                + ", status='" + status + '\''
                + ", deviceId=" + deviceId
                + '}';
    }
}
