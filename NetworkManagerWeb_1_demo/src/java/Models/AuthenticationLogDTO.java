package Models;

import java.io.Serializable;
import java.sql.Timestamp;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "AuthenticationLog")
public class AuthenticationLogDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    public static final String STATUS_SUCCESS = "SUCCESS";
    public static final String STATUS_FAILED = "FAILED";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "log_id")
    private int logId;

    @Column(name = "username", nullable = false, length = 50)
    private String username;

    @Column(name = "login_status", nullable = false, length = 20)
    private String loginStatus;

    @Column(name = "ip_address", length = 45)
    private String ipAddress;

    @Column(name = "login_time")
    private Timestamp loginTime;

    @Column(name = "user_id")
    private Integer userId;

    public AuthenticationLogDTO() {
    }

    public AuthenticationLogDTO(String username, String loginStatus, String ipAddress, Integer userId) {
        this.username = username;
        this.loginStatus = loginStatus;
        this.ipAddress = ipAddress;
        this.userId = userId;
    }

    public int getLogId() {
        return logId;
    }

    public void setLogId(int logId) {
        this.logId = logId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    // backward compatibility for JSP using ${log.userName}
    public String getUserName() {
        return username;
    }

    public void setUserName(String userName) {
        this.username = userName;
    }

    public String getLoginStatus() {
        return loginStatus;
    }

    public void setLoginStatus(String loginStatus) {
        this.loginStatus = loginStatus;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }

    public Timestamp getLoginTime() {
        return loginTime;
    }

    public void setLoginTime(Timestamp loginTime) {
        this.loginTime = loginTime;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public boolean isSuccess() {
        return STATUS_SUCCESS.equalsIgnoreCase(loginStatus);
    }
}
