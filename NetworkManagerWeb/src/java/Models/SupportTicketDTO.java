package Models;

import java.io.Serializable;
import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;
@Entity(name = "SupportTicket")
@Table(name = "SupportTicket")

public class SupportTicketDTO implements Serializable{
    private static final long SerializableUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    
    private int ticketId;
    private String title;
    private String description;
    private String status;
    private Date createdDate;
    private int createdBy;
    private Integer deviceId;

    public SupportTicketDTO() {
    }

    public SupportTicketDTO(int ticketId, String title, String description,
                            String status, Date createdDate,
                            int createdBy, Integer deviceId) {
        this.ticketId = ticketId;
        this.title = title;
        this.description = description;
        this.status = status;
        this.createdDate = createdDate;
        this.createdBy = createdBy;
        this.deviceId = deviceId;
    }

    public int getTicketId() {
        return ticketId;
    }

    public void setTicketId(int ticketId) {
        this.ticketId = ticketId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Date getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(Date createdDate) {
        this.createdDate = createdDate;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public Integer getDeviceId() {
        return deviceId;
    }

    public void setDeviceId(Integer deviceId) {
        this.deviceId = deviceId;
    }

    @Override
    public String toString() {
        return "SupportTicketDTO{" +
                "ticketId=" + ticketId +
                ", title='" + title + '\'' +
                ", description='" + description + '\'' +
                ", status='" + status + '\'' +
                ", createdDate=" + createdDate +
                ", createdBy=" + createdBy +
                ", deviceId=" + deviceId +
                '}';
    }
}