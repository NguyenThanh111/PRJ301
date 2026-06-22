package Models;

import java.io.Serializable;

public class PaymentPlan implements Serializable {

    private static final long serialVersionUID = 1L;

    private final String code;
    private final String name;
    private final String description;
    private final long amount;
    private final int durationDays;

    public PaymentPlan(String code, String name, String description, long amount, int durationDays) {
        this.code = code;
        this.name = name;
        this.description = description;
        this.amount = amount;
        this.durationDays = durationDays;
    }

    public String getCode() {
        return code;
    }

    public String getName() {
        return name;
    }

    public String getDescription() {
        return description;
    }

    public long getAmount() {
        return amount;
    }

    public int getDurationDays() {
        return durationDays;
    }
}
