/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Models;

import java.sql.Date;
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
@Table(name = "WiFiAnalytics")
public class WiFiAnalyticsDTO {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "analytics_id")
    private int analyticsId;

    @Column(name = "total_users")
    private int totalUsers;

    @Column(name = "peak_users")
    private int peakUsers;

    @Column(name = "avg_speed")
    private double avgSpeed;

    @Column(name = "analytics_date")
    private Date analyticsDate;

    @Column(name = "ap_id")
    private int apId; 

    public WiFiAnalyticsDTO() {
    }

    public WiFiAnalyticsDTO(int analyticsId, int totalUsers, int peakUsers,
            double avgSpeed, Date analyticsDate, int apId) {
        this.analyticsId = analyticsId;
        this.totalUsers = totalUsers;
        this.peakUsers = peakUsers;
        this.avgSpeed = avgSpeed;
        this.analyticsDate = analyticsDate;
        this.apId = apId;
    }

    public int getAnalyticsId() {
        return analyticsId;
    }

    public void setAnalyticsId(int analyticsId) {
        this.analyticsId = analyticsId;
    }

    public int getTotalUsers() {
        return totalUsers;
    }

    public void setTotalUsers(int totalUsers) {
        this.totalUsers = totalUsers;
    }

    public int getPeakUsers() {
        return peakUsers;
    }

    public void setPeakUsers(int peakUsers) {
        this.peakUsers = peakUsers;
    }

    public double getAvgSpeed() {
        return avgSpeed;
    }

    public void setAvgSpeed(double avgSpeed) {
        this.avgSpeed = avgSpeed;
    }

    public Date getAnalyticsDate() {
        return analyticsDate;
    }

    public void setAnalyticsDate(Date analyticsDate) {
        this.analyticsDate = analyticsDate;
    }

    public int getApId() {
        return apId;
    }

    public void setApId(int apId) {
        this.apId = apId;
    }


}
