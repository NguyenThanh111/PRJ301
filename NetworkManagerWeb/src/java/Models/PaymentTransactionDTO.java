package Models;

import java.io.Serializable;
import java.sql.Timestamp;

public class PaymentTransactionDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    private long paymentId;
    private String txnRef;
    private int userId;
    private String planCode;
    private String planName;
    private int durationDays;
    private long amount;
    private String currency;
    private String orderInfo;
    private String status;
    private String clientIp;
    private String bankCode;
    private String cardType;
    private String gatewayTransactionNo;
    private String responseCode;
    private String transactionStatus;
    private Timestamp payDate;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private Timestamp confirmedAt;

    public long getPaymentId() { return paymentId; }
    public void setPaymentId(long paymentId) { this.paymentId = paymentId; }
    public String getTxnRef() { return txnRef; }
    public void setTxnRef(String txnRef) { this.txnRef = txnRef; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public String getPlanCode() { return planCode; }
    public void setPlanCode(String planCode) { this.planCode = planCode; }
    public String getPlanName() { return planName; }
    public void setPlanName(String planName) { this.planName = planName; }
    public int getDurationDays() { return durationDays; }
    public void setDurationDays(int durationDays) { this.durationDays = durationDays; }
    public long getAmount() { return amount; }
    public void setAmount(long amount) { this.amount = amount; }
    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }
    public String getOrderInfo() { return orderInfo; }
    public void setOrderInfo(String orderInfo) { this.orderInfo = orderInfo; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getClientIp() { return clientIp; }
    public void setClientIp(String clientIp) { this.clientIp = clientIp; }
    public String getBankCode() { return bankCode; }
    public void setBankCode(String bankCode) { this.bankCode = bankCode; }
    public String getCardType() { return cardType; }
    public void setCardType(String cardType) { this.cardType = cardType; }
    public String getGatewayTransactionNo() { return gatewayTransactionNo; }
    public void setGatewayTransactionNo(String gatewayTransactionNo) { this.gatewayTransactionNo = gatewayTransactionNo; }
    public String getResponseCode() { return responseCode; }
    public void setResponseCode(String responseCode) { this.responseCode = responseCode; }
    public String getTransactionStatus() { return transactionStatus; }
    public void setTransactionStatus(String transactionStatus) { this.transactionStatus = transactionStatus; }
    public Timestamp getPayDate() { return payDate; }
    public void setPayDate(Timestamp payDate) { this.payDate = payDate; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
    public Timestamp getConfirmedAt() { return confirmedAt; }
    public void setConfirmedAt(Timestamp confirmedAt) { this.confirmedAt = confirmedAt; }
}
