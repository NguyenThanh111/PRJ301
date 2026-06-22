package Utils;

import Models.PaymentPlan;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public final class PaymentPlanCatalog {

    private static final Map<String, PaymentPlan> PLANS;

    static {
        Map<String, PaymentPlan> plans = new LinkedHashMap<String, PaymentPlan>();
        plans.put("BASIC", new PaymentPlan("BASIC", "Basic 30 ngày",
                "Giám sát mạng và quản lý thiết bị cơ bản", 99000L, 30));
        plans.put("PRO", new PaymentPlan("PRO", "Pro 90 ngày",
                "Phân tích băng thông, cảnh báo và hỗ trợ ưu tiên", 249000L, 90));
        plans.put("BUSINESS", new PaymentPlan("BUSINESS", "Business 365 ngày",
                "Đầy đủ tính năng quản trị và báo cáo nâng cao", 799000L, 365));
        PLANS = Collections.unmodifiableMap(plans);
    }

    private PaymentPlanCatalog() {
    }

    public static PaymentPlan find(String code) {
        return code == null ? null : PLANS.get(code.trim().toUpperCase());
    }

    public static List<PaymentPlan> getAll() {
        return Collections.unmodifiableList(new ArrayList<PaymentPlan>(PLANS.values()));
    }
}
