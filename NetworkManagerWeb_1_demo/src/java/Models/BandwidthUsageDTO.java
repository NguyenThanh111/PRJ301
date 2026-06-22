
package Models;

import java.io.Serializable;
import java.sql.Timestamp;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 *
 * @author nvtv0
 */
@Entity
@Table(name = "BandwidthUsage")
public class BandwidthUsageDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "usage_id")
    private int usageId;

    @Column(name = "upload_speed")
    private double uploadSpeed;

    @Column(name = "download_speed")
    private double downloadSpeed;

    @Column(name = "record_time")
    private Timestamp recordTime;

    @Column(name = "device_id")
    private int deviceId; 

    public BandwidthUsageDTO() {
    }

    public BandwidthUsageDTO(int usageId, double uploadSpeed, double downloadSpeed,
            Timestamp recordTime, int deviceId) {
        this.usageId = usageId;
        this.uploadSpeed = uploadSpeed;
        this.downloadSpeed = downloadSpeed;
        this.recordTime = recordTime;
        this.deviceId = deviceId;
    }

    public int getUsageId() {
        return usageId;
    }

    public void setUsageId(int usageId) {
        this.usageId = usageId;
    }

    public double getUploadSpeed() {
        return uploadSpeed;
    }

    public void setUploadSpeed(double uploadSpeed) {
        this.uploadSpeed = uploadSpeed;
    }

    public double getDownloadSpeed() {
        return downloadSpeed;
    }

    public void setDownloadSpeed(double downloadSpeed) {
        this.downloadSpeed = downloadSpeed;
    }

    public Timestamp getRecordTime() {
        return recordTime;
    }

    public void setRecordTime(Timestamp recordTime) {
        this.recordTime = recordTime;
    }

    public int getDeviceId() {
        return deviceId;
    }

    public void setDeviceId(int deviceId) {
        this.deviceId = deviceId;
    }


}

