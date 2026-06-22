# [USER SIDE] Upgrade Bandwidth Payment — Implementation Plan (FIXED)

> **For agentic workers:** Use subagent-driven-development or executing-plans to implement task-by-task.

**Goal:** Allow User (Viewer) to upgrade bandwidth from 100 Mbps to 300 Mbps via MoMo/Banking payment.

**Architecture:** SPA inside `userDashboard.jsp` — add 3 new inline sections (Plan Overview, Upgrade Plan, Transactions). PaymentController handles transaction creation, payment gateway redirect, and callback processing. Data stored in SQL Server via DAO pattern (JDBC-based).

**Tech Stack:** Java Servlet/JSP, SQL Server, JDBC (DAO pattern), Bootstrap 5.3.3, MoMo API.

## Global Constraints

- Package: `Models`, `Controller`, `Utils`
- DAO implement `IDAO<T, K>` interface
- DB connection via `Utils.DbUtils.getConnection()`
- UI follows existing dark neon theme (CSS variables)
- JSP uses JSTL + Bootstrap 5.3.3 + Bootstrap Icons
- **All existing controllers use `processRequest()` pattern + `web.xml` mapping (no `@WebServlet`)**
- **userDashboard.jsp uses SPA `showPage(pageId, triggerEl)` pattern — ALL new sections must be inline**
- **SystemLogDAO uses JPA** (use `new SystemLogDAO().insert(log)` as-is)

## Fixes Applied (vs. original plan)

| # | Category | Issue | Fix |
|---|----------|-------|-----|
| I.1 | Security | MoMo return accepts GET from browser, no HMAC → free upgrade | Separate Return URL (GET, display-only) vs IPN (POST, HMAC-verified) |
| I.2 | Security | No IDOR check in `findByRef` | Verify `tx.getUserId() == sessionUser.getUserId()` |
| I.3 | Security | `transaction_ref` uses timestamp → guessable | Use `UUID.randomUUID()` |
| II.1 | Logic | `txDAO.insert()` return value not checked | Check and redirect with error on failure |
| II.2 | Logic | Missing `momo-pay`/`banking-pay` action cases in doGet | Add to processRequest |
| III.1 | Schema | `UserBandwidth.user_id` lacks UNIQUE → duplicate rows | Add `UNIQUE(user_id)` constraint |
| III.2 | Race | `upgradeBandwidth()` find-then-insert/update without transaction | Use single SQL MERGE (atomic upsert) |
| IV.1 | Architecture | `upgrade-plan.jsp` as separate page breaks SPA pattern | Inline sections in userDashboard.jsp with `showPage()` |
| IV.2 | Architecture | `window.location.href` navigation breaks sidebar active-tab | Use `showPage()` consistently |
| V.1 | Business | Banking auto-confirms without webhook | Set PENDING_CONFIRMATION, note manual Admin step |
| V.2 | Business | No idempotency check before upgradeBandwidth | Check payment_status already SUCCESS before processing |
| V.3 | Business | Task 8 hard-codes 100 Mbps | Read from `ubDAO.findByUserId(sessionUser.getUserId())` |

---

### Task 1: DB Script — User-related tables

**Files:**
- Create: `PRJ301/payment-upgrade.sql`

- [ ] **Step 1: Write SQL script**

```sql
USE network_simulation_db3;
GO

-- Service plans
CREATE TABLE ServicePlan (
    plan_id INT IDENTITY(1,1) PRIMARY KEY,
    plan_name NVARCHAR(100) NOT NULL,
    from_bandwidth FLOAT NOT NULL,
    to_bandwidth FLOAT NOT NULL,
    price DECIMAL(10,0) NOT NULL,
    duration_days INT NOT NULL DEFAULT 30,
    description NVARCHAR(500),
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE()
);
GO

-- User bandwidth (one row per user, UNIQUE on user_id)
CREATE TABLE UserBandwidth (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL UNIQUE REFERENCES [User](user_id),
    bandwidth_limit FLOAT NOT NULL DEFAULT 100,
    upgraded_at DATETIME,
    expires_at DATETIME,
    is_active BIT DEFAULT 0
);
GO

-- Payment transactions
CREATE TABLE PaymentTransaction (
    transaction_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL REFERENCES [User](user_id),
    plan_id INT NOT NULL REFERENCES ServicePlan(plan_id),
    amount DECIMAL(10,0) NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    payment_status VARCHAR(20) DEFAULT 'PENDING',
    transaction_ref VARCHAR(100) UNIQUE,
    order_info NVARCHAR(500),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME
);
GO

-- Seed: Premium 300 Mbps plan
INSERT INTO ServicePlan (plan_name, from_bandwidth, to_bandwidth, price, duration_days, description)
VALUES (N'Premium 300 Mbps', 100, 300, 50000, 30, N'Upgrade bandwidth from 100 Mbps to 300 Mbps. Max download ~37 MB/s.');
GO

-- Seed: Default 100 Mbps row for every existing user (idempotent via NOT EXISTS)
INSERT INTO UserBandwidth (user_id, bandwidth_limit, is_active)
SELECT user_id, 100, 1 FROM [User] u
WHERE NOT EXISTS (SELECT 1 FROM UserBandwidth ub WHERE ub.user_id = u.user_id);
GO
```

- [ ] **Step 2: Execute on SQL Server**

---

### Task 2: DTOs — ServicePlanDTO, UserBandwidthDTO, PaymentTransactionDTO

**Files:**
- Create: `NetworkManagerWeb/src/java/Models/ServicePlanDTO.java`
- Create: `NetworkManagerWeb/src/java/Models/UserBandwidthDTO.java`
- Create: `NetworkManagerWeb/src/java/Models/PaymentTransactionDTO.java`

**Pattern:** Plain POJO (no JPA annotations) matching JDBC-based DAO pattern (like RoomDTO).

*(DTO code unchanged from original — they are correct.)*

---

### Task 3: DAOs — ServicePlanDAO, UserBandwidthDAO, PaymentTransactionDAO

**Files:**
- Create: `NetworkManagerWeb/src/java/Models/ServicePlanDAO.java`
- Create: `NetworkManagerWeb/src/java/Models/UserBandwidthDAO.java`
- Create: `NetworkManagerWeb/src/java/Models/PaymentTransactionDAO.java`

**Pattern:** JDBC-based, implement `IDAO<T, Integer>`, use `DbUtils.getConnection()`, private `mapRow()` helper.

- [ ] **Step 1: ServicePlanDAO** — unchanged from original (correct)
- [ ] **Step 2: UserBandwidthDAO** — ADD atomic `upgradeBandwidth()` method using SQL MERGE:

```java
// Atomic upsert: update if exists, insert if not — single SQL batch
public boolean upgradeBandwidth(int userId, double bandwidthLimit, Timestamp upgradedAt, Timestamp expiresAt) {
    String sql = "UPDATE UserBandwidth SET bandwidth_limit=?, upgraded_at=?, expires_at=?, is_active=? WHERE user_id=?;\n"
               + "IF @@ROWCOUNT=0\n"
               + "INSERT INTO UserBandwidth (user_id, bandwidth_limit, upgraded_at, expires_at, is_active) VALUES (?, ?, ?, ?, ?);";
    try (Connection conn = DbUtils.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setDouble(1, bandwidthLimit);
        ps.setTimestamp(2, upgradedAt);
        ps.setTimestamp(3, expiresAt);
        ps.setBoolean(4, true);
        ps.setInt(5, userId);
        ps.setInt(6, userId);
        ps.setDouble(7, bandwidthLimit);
        ps.setTimestamp(8, upgradedAt);
        ps.setTimestamp(9, expiresAt);
        ps.setBoolean(10, true);
        ps.executeUpdate();
        return true;
    } catch (Exception e) { e.printStackTrace(); }
    return false;
}
```

- [ ] **Step 3: PaymentTransactionDAO** — ADD `updateStatusByRef()` method with idempotency:

```java
// Update status ONLY if currently PENDING (idempotent: skip if already processed)
public boolean updateStatusByRef(String ref, String newStatus) {
    String sql = "UPDATE PaymentTransaction SET payment_status=?, updated_at=GETDATE() WHERE transaction_ref=? AND payment_status='PENDING'";
    try (Connection conn = DbUtils.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, newStatus);
        ps.setString(2, ref);
        return ps.executeUpdate() > 0;
    } catch (Exception e) { e.printStackTrace(); }
    return false;
}
```

---

### Task 4: PaymentController — Create tx, redirect, handle callback

**Files:**
- Create: `NetworkManagerWeb/src/java/Controller/PaymentController.java`
- Modify: `NetworkManagerWeb/web/WEB-INF/web.xml`

**Key fixes vs. original:**
- Uses `processRequest()` pattern (like all existing controllers)
- No `@WebServlet` annotation — uses `web.xml` mapping
- UUID for transaction_ref (not timestamp)
- IDOR check on all `findByRef` calls
- Checks `txDAO.insert()` return value
- **`momo-ipn` tách khỏi session check** (xử lý trước switch, vì IPN là server-to-server không có session)
- MoMo return (GET) = display-only, no status update
- MoMo IPN (POST) = HMAC verification before status update
- **Mock dev: `buildMoMoPaymentUrl` tự gọi IPN simulation nội bộ** (xóa khi gắn MoMo SDK thật)
- Banking return = sets PENDING_CONFIRMATION (manual Admin confirmation — **xem Known Gap ở cuối Task 4**)
- Idempotent: `updateStatusByRef` only updates if current status is PENDING
- **Validate paymentMethod whitelist trước khi insert** (tránh rác PENDING)

- [ ] **Step 1: Write PaymentController.java**

```java
package Controller;

import Models.*;
import Utils.*;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Timestamp;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.http.*;

public class PaymentController extends HttpServlet {

    private final ServicePlanDAO planDAO = new ServicePlanDAO();
    private final PaymentTransactionDAO txDAO = new PaymentTransactionDAO();
    private final UserBandwidthDAO ubDAO = new UserBandwidthDAO();
    private final SystemLogDAO logDAO = new SystemLogDAO();

    protected void processRequest(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html;charset=UTF-8");

        String action = req.getParameter("action");
        if (action == null) action = "plans";

        // ── IPN: server-to-server từ MoMo, KHÔNG có session user ──
        // Xác thực bằng HMAC signature, không phải session. Xử lý trước để
        // không bị redirect login.jsp.
        if ("momo-ipn".equals(action)) {
            handleMoMoIPN(req, resp);
            return;
        }

        // ── Mọi action còn lại đều cần session user ──
        HttpSession session = req.getSession();
        UserDTO user = (UserDTO) session.getAttribute("user");
        String role = (String) session.getAttribute("role");
        if (user == null || role == null || !role.equalsIgnoreCase("Viewer")) {
            resp.sendRedirect("login.jsp");
            return;
        }

        switch (action) {
            case "plans":
                handlePlans(req, resp, user);
                break;
            case "create":
                handleCreate(req, resp, user);
                break;
            case "momo-return":
                handleMoMoReturn(req, resp, user);
                break;
            case "banking-return":
                handleBankingReturn(req, resp, user);
                break;
            case "payment-result":
                handlePaymentResult(req, resp, user);
                break;
            default:
                resp.sendRedirect("userDashboard.jsp?tab=upgradeplan");
        }
    }

    // ---- DISPLAY: plan overview + upgrade form + transactions ----
    private void handlePlans(HttpServletRequest req, HttpServletResponse resp, UserDTO user)
            throws ServletException, IOException {
        ArrayList<ServicePlanDTO> plans = planDAO.ListAll();
        UserBandwidthDTO ub = ubDAO.findByUserId(user.getUserId());
        ArrayList<PaymentTransactionDTO> txs = txDAO.findByUser(user.getUserId());

        // Build plan name map
        Map<Integer, String> planNames = new HashMap<>();
        for (PaymentTransactionDTO tx : txs) {
            if (!planNames.containsKey(tx.getPlanId())) {
                ServicePlanDTO sp = planDAO.searchById(tx.getPlanId());
                planNames.put(tx.getPlanId(), sp != null ? sp.getPlanName() : "Unknown");
            }
        }

        req.setAttribute("plans", plans);
        req.setAttribute("userBandwidth", ub);
        req.setAttribute("transactions", txs);
        req.setAttribute("planNames", planNames);
        req.getRequestDispatcher("userDashboard.jsp").forward(req, resp);
    }

    // ---- CREATE transaction ----
    private void handleCreate(HttpServletRequest req, HttpServletResponse resp, UserDTO user)
            throws IOException {
        int planId;
        String method;
        try {
            planId = Integer.parseInt(req.getParameter("planId"));
            method = req.getParameter("paymentMethod");
        } catch (Exception e) {
            resp.sendRedirect("userDashboard.jsp?tab=upgradeplan&error=invalid_input");
            return;
        }

        // Validate payment method whitelist TRƯỚC khi insert (tránh rác PENDING)
        if (method == null || (!"MOMO".equalsIgnoreCase(method) && !"BANKING".equalsIgnoreCase(method))) {
            resp.sendRedirect("userDashboard.jsp?tab=upgradeplan&error=invalid_method");
            return;
        }

        ServicePlanDTO plan = planDAO.searchById(planId);
        if (plan == null) {
            resp.sendRedirect("userDashboard.jsp?tab=upgradeplan&error=invalid_plan");
            return;
        }

        // Use UUID for unguessable ref
        String txRef = UUID.randomUUID().toString().replace("-", "").substring(0, 20).toUpperCase();

        PaymentTransactionDTO tx = new PaymentTransactionDTO();
        tx.setUserId(user.getUserId());
        tx.setPlanId(planId);
        tx.setAmount(plan.getPrice());
        tx.setPaymentMethod(method);
        tx.setPaymentStatus("PENDING");
        tx.setTransactionRef(txRef);
        tx.setOrderInfo("NetworkManager - " + plan.getPlanName());

        boolean inserted = txDAO.insert(tx);
        if (!inserted) {
            resp.sendRedirect("userDashboard.jsp?tab=upgradeplan&error=create_failed");
            return;
        }

        // Redirect to payment gateway
        if ("MOMO".equalsIgnoreCase(method)) {
            String redirectUrl = buildMoMoPaymentUrl(txRef, plan.getPrice(), plan.getPlanName());
            resp.sendRedirect(redirectUrl);
        } else {
            // Banking: redirect to dashboard with pending info
            resp.sendRedirect("userDashboard.jsp?tab=upgradeplan&ref=" + txRef);
        }
    }

    // ---- MOMO: Build payment URL (mock — replace with real API) ----
    // DEV ONLY — REMOVE khi tích hợp MoMo SDK thật
    private String buildMoMoPaymentUrl(String ref, long amount, String planName) {
        // Trong dev: gọi thẳng logic xác nhận bằng Java method call (không qua HTTP redirect),
        // mô phỏng MoMo server gọi IPN ngầm. User không thấy trang "OK" trắng.
        // Khi có MoMo thật: xoá dòng simulate, gọi MoMo API → nhận payUrl → redirect.
        simulateMoMoIpnSuccess(ref, amount);
        return "PaymentController?action=momo-return&ref=" + ref;
    }

    // DEV ONLY — mô phỏng IPN callback nội bộ
    private void simulateMoMoIpnSuccess(String ref, long amount) {
        PaymentTransactionDTO tx = txDAO.findByRef(ref);
        if (tx == null || tx.getAmount() != amount) return;
        if (txDAO.updateStatusByRef(ref, "SUCCESS")) {
            upgradeBandwidth(tx.getUserId(), tx.getPlanId());
        }
    }

    // ---- MOMO RETURN (GET from browser): display-only, NO status update ----
    private void handleMoMoReturn(HttpServletRequest req, HttpServletResponse resp, UserDTO user)
            throws IOException {
        String ref = req.getParameter("ref");
        if (ref == null || ref.isEmpty()) {
            resp.sendRedirect("userDashboard.jsp?tab=upgradeplan");
            return;
        }

        // IDOR check: verify tx belongs to this user
        PaymentTransactionDTO tx = txDAO.findByRef(ref);
        if (tx == null || tx.getUserId() != user.getUserId()) {
            resp.sendRedirect("userDashboard.jsp?tab=upgradeplan&error=invalid_tx");
            return;
        }

        // Display only: show whatever status the tx has (updated by IPN)
        resp.sendRedirect("userDashboard.jsp?tab=paymentresult&ref=" + ref);
    }

    // ---- MOMO IPN (server-to-server): HMAC verification, then update ----
    private void handleMoMoIPN(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        // TODO: replace rawSignature format with real MoMo spec (field order/names may differ)
        String ref = req.getParameter("ref");
        String amountStr = req.getParameter("amount");
        String signature = req.getParameter("signature");

        if (ref == null || amountStr == null) {
            resp.getWriter().write("INVALID_PARAMS");
            return;
        }

        // Verify HMAC
        String expectedSig = PaymentConfig.hmacSHA512(PaymentConfig.MOMO_SECRET_KEY,
                "ref=" + ref + "&amount=" + amountStr);
        if (signature == null || !signature.equals(expectedSig)) {
            resp.getWriter().write("INVALID_SIGNATURE");
            return;
        }

        // Verify amount khớp với DB (chống gian lận)
        PaymentTransactionDTO tx = txDAO.findByRef(ref);
        if (tx == null) {
            resp.getWriter().write("TX_NOT_FOUND");
            return;
        }
        long receivedAmount;
        try {
            receivedAmount = Long.parseLong(amountStr);
        } catch (NumberFormatException e) {
            resp.getWriter().write("INVALID_AMOUNT");
            return;
        }
        if (tx.getAmount() != receivedAmount) {
            resp.getWriter().write("AMOUNT_MISMATCH");
            return;
        }

        // Idempotent: only update if PENDING
        boolean updated = txDAO.updateStatusByRef(ref, "SUCCESS");
        if (!updated) {
            resp.getWriter().write("ALREADY_PROCESSED");
            return;
        }

        // Perform bandwidth upgrade (dùng chung method với phần còn lại)
        upgradeBandwidth(tx.getUserId(), tx.getPlanId());

        resp.getWriter().write("OK");
    }

    // ---- BANKING RETURN: redirect user back, set PENDING_CONFIRMATION ----
    private void handleBankingReturn(HttpServletRequest req, HttpServletResponse resp, UserDTO user)
            throws IOException {
        String ref = req.getParameter("ref");
        if (ref == null || ref.isEmpty()) {
            resp.sendRedirect("userDashboard.jsp?tab=upgradeplan");
            return;
        }

        // IDOR check
        PaymentTransactionDTO tx = txDAO.findByRef(ref);
        if (tx == null || tx.getUserId() != user.getUserId()) {
            resp.sendRedirect("userDashboard.jsp?tab=upgradeplan&error=invalid_tx");
            return;
        }

        // Banking: set PENDING_CONFIRMATION (requires Admin to manually confirm)
        txDAO.updateStatusByRef(ref, "PENDING_CONFIRMATION");

        resp.sendRedirect("userDashboard.jsp?tab=paymentresult&ref=" + ref);
    }

    // ---- PAYMENT RESULT: display transaction details ----
    private void handlePaymentResult(HttpServletRequest req, HttpServletResponse resp, UserDTO user)
            throws ServletException, IOException {
        String ref = req.getParameter("ref");
        if (ref != null) {
            PaymentTransactionDTO tx = txDAO.findByRef(ref);
            // IDOR check
            if (tx != null && tx.getUserId() == user.getUserId()) {
                req.setAttribute("paymentTx", tx);
            }
        }
        // Load plans data for the inline sections
        handlePlans(req, resp, user);
    }

    // ---- BANDWIDTH UPGRADE (atomic upsert) ----
    // Access level: package-private (default) để AdminPaymentController
    // cùng package Controller có thể gọi (Task 9 — confirm-banking).
    // Returns true nếu upgrade thành công, false nếu thất bại.
    boolean upgradeBandwidth(int userId, int planId) {
        ServicePlanDTO plan = planDAO.searchById(planId);
        if (plan == null) return false;

        Calendar cal = Calendar.getInstance();
        Timestamp now = new Timestamp(cal.getTimeInMillis());
        cal.add(Calendar.DAY_OF_MONTH, plan.getDurationDays());
        Timestamp expires = new Timestamp(cal.getTimeInMillis());

        boolean ok = ubDAO.upgradeBandwidth(userId, plan.getToBandwidth(), now, expires);
        if (!ok) return false;

        SystemLogDTO log = new SystemLogDTO();
        log.setAction("BANDWIDTH_UPGRADE");
        log.setDetails("User ID " + userId + " upgraded bandwidth to " + (int)plan.getToBandwidth() + " Mbps");
        log.setPerformedBy(userId);
        logDAO.insert(log);
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        processRequest(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        processRequest(req, resp);
    }
}
```

#### ⚠️ Known Gaps (cần xử lý ở phase tiếp theo)

| Gap | Mô tả | Ai xử lý |
|-----|-------|----------|
| **Banking dead-end** | `handleBankingReturn` set `PENDING_CONFIRMATION` nhưng chưa có action nào chuyển sang `SUCCESS` + gọi `upgradeBandwidth()`. Giao dịch Banking kẹt vĩnh viễn. | Admin module — cần action `confirm-banking` (xem Task 9) |
| **MoMo mock IPN** | `buildMoMoPaymentUrl` gọi `simulateMoMoIpnSuccess()` nội bộ (Java method call), không qua HTTP. Chỉ dùng cho dev, **phải xóa** khi tích hợp MoMo SDK thật. Khi đó `buildMoMoPaymentUrl` sẽ gọi MoMo API → nhận `payUrl` → redirect. | Tích hợp MoMo SDK |
| **VNPay chưa support** | Hiện chỉ có MoMo + Banking. VNPay có thể thêm sau. | Future |
| **MOMO_SECRET_KEY trong source** | `MOMO_SECRET_KEY` hardcode thẳng trong `PaymentConfig.java`. Nếu repo public, ai cũng đọc được secret → tự tính HMAC hợp lệ, vô hiệu hoá xác thực IPN. Cần đưa vào `.properties` outside git hoặc biến môi trường trước khi public. | Security |
| **localhost hardcode** | `PaymentConfig.MOMO_RETURN_URL` và `MOMO_IPN_URL` hardcode `http://localhost:8080/...` — cần đưa vào file config khi deploy. | Deployment |

- [ ] **Step 2: Add to web.xml**

```xml
<servlet>
    <servlet-name>PaymentController</servlet-name>
    <servlet-class>Controller.PaymentController</servlet-class>
</servlet>
<servlet-mapping>
    <servlet-name>PaymentController</servlet-name>
    <url-pattern>/PaymentController</url-pattern>
</servlet-mapping>
```

---

### Task 5: PaymentConfig — HMAC utilities + MoMo config

**Files:**
- Create: `NetworkManagerWeb/src/java/Utils/PaymentConfig.java`

- [ ] **Step 1: Write PaymentConfig.java**

```java
package Utils;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.*;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

public class PaymentConfig {

    // MoMo sandbox config (replace with real values)
    public static final String MOMO_PARTNER_CODE = "MOMO_PARTNER_CODE";
    public static final String MOMO_ACCESS_KEY = "MOMO_ACCESS_KEY";
    public static final String MOMO_SECRET_KEY = "MOMO_SECRET_KEY";
    public static final String MOMO_API_ENDPOINT = "https://test-payment.momo.vn/v2/gateway/api/create";
    public static final String MOMO_RETURN_URL = "http://localhost:8080/NetworkManagerWeb/PaymentController?action=momo-return";
    public static final String MOMO_IPN_URL = "http://localhost:8080/NetworkManagerWeb/PaymentController?action=momo-ipn";

    public static String hmacSHA512(String key, String data) {
        try {
            if (key == null || data == null) throw new NullPointerException();
            Mac hmac512 = Mac.getInstance("HmacSHA512");
            SecretKeySpec secretKey = new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA512");
            hmac512.init(secretKey);
            byte[] result = hmac512.doFinal(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(2 * result.length);
            for (byte b : result) sb.append(String.format("%02x", b & 0xff));
            return sb.toString();
        } catch (Exception ex) {
            return "";
        }
    }

    public static String getRandomNumber(int len) {
        Random rnd = new Random();
        String chars = "0123456789";
        StringBuilder sb = new StringBuilder(len);
        for (int i = 0; i < len; i++) sb.append(chars.charAt(rnd.nextInt(chars.length())));
        return sb.toString();
    }
}
```

---

### Task 6: Update userDashboard.jsp — Add 3 inline payment sections

**Files:**
- Modify: `NetworkManagerWeb/web/userDashboard.jsp`

Instead of creating a separate `upgrade-plan.jsp`, add three new inline sections inside `userDashboard.jsp`:

1. `page-upgradeplan` — Plan Overview comparison + Upgrade form
2. `page-usertransactions` — Transaction history table
3. `page-paymentresult` — Payment success/fail message

- [ ] **Step 1: Add pageTitles entries (in the `<script>` block)**

Insert after existing pageTitles:
```javascript
'upgradeplan':     ['Upgrade Plan',    '/ Service'],
'usertransactions': ['Transactions',    '/ Service'],
'paymentresult':   ['Payment Result',  '/ Service']
```

- [ ] **Step 2: Add sidebar items (in the `<nav class="sidebar">`)**

Insert after the Notifications button, before Support section:
```html
<div class="sidebar-section-label">Service</div>
<button class="nav-item-link" onclick="showPage('upgradeplan', this)">
    <i class="bi bi-infinity"></i> Upgrade Plan
</button>
<button class="nav-item-link" onclick="showPage('usertransactions', this)">
    <i class="bi bi-clock-history"></i> Transactions
</button>
```

- [ ] **Step 3: Add URL tab parameter handling on page load**

Add after the pageTitles definition:
```javascript
// Auto-navigate to tab from URL parameter
(function() {
    const params = new URLSearchParams(window.location.search);
    const tab = params.get('tab');
    if (tab && pageTitles[tab]) {
        const btn = document.querySelector(`.nav-item-link[onclick*="'${tab}'"]`);
        if (btn) showPage(tab, btn);
    }
})();
```

- [ ] **Step 4: Add the 3 new page-section divs** (after existing sections, before closing `.page-body`)

```jsp
<%-- ===== UPGRADE PLAN SECTION ===== --%>
<div class="page-section" id="page-upgradeplan">
    <%-- Plan data loaded via request attributes from PaymentController forward --%>
    <%
        ArrayList<ServicePlanDTO> plans = (ArrayList<ServicePlanDTO>) request.getAttribute("plans");
        UserBandwidthDTO ub = (UserBandwidthDTO) request.getAttribute("userBandwidth");
        if (plans == null) {
            // Not forwarded from controller — load directly
            ServicePlanDAO spDao = new ServicePlanDAO();
            UserBandwidthDAO ubDao = new UserBandwidthDAO();
            plans = spDao.ListAll();
            ub = ubDao.findByUserId(currentUser.getUserId());
        }
        double currentBW = (ub != null) ? ub.getBandwidthLimit() : 100;
        String error = request.getParameter("error");
        String refParam = request.getParameter("ref");
    %>
    <% if (error != null) { %>
        <div class="alert alert-danger" style="background:rgba(239,68,68,0.16);border:1px solid rgba(239,68,68,0.3);color:#f87171;">
            <i class="bi bi-exclamation-triangle"></i>
            <% if ("invalid_plan".equals(error)) { %>Invalid plan selected.<% }
               else if ("create_failed".equals(error)) { %>Failed to create transaction. Please try again.<% }
               else if ("invalid_tx".equals(error)) { %>Invalid transaction.<% }
               else { %>An error occurred.<% } %>
        </div>
    <% } %>

    <%-- Plan Overview --%>
    <div class="section-card mb-4">
        <div class="section-card-header">
            <h6><i class="bi bi-speedometer2 me-2"></i>Current Plan</h6>
        </div>
        <div class="section-card-body">
            <div class="speed-compare">
                <div class="speed-box current">
                    <div class="speed-val" style="color:#60a5fa;"><%= (int)currentBW %></div>
                    <div class="stat-label">Mbps</div>
                    <div><small style="color:var(--text-muted);">Current Plan</small></div>
                </div>
                <div class="speed-arrow"><i class="bi bi-arrow-right"></i></div>
                <div class="speed-box upgraded">
                    <div class="speed-val" style="color:#c4b5fd;">300</div>
                    <div class="stat-label">Mbps</div>
                    <div><small style="color:#a78bfa;">Premium Plan</small></div>
                </div>
            </div>
            <% if (ub != null && ub.getExpiresAt() != null) { %>
                <div class="text-center mt-3">
                    <span class="status-badge status-success">
                        <i class="bi bi-check-circle me-1"></i>Active until <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(ub.getExpiresAt()) %>
                    </span>
                </div>
            <% } %>
        </div>
    </div>

    <%-- Upgrade Form --%>
    <div class="section-card mb-4">
        <div class="section-card-header">
            <h6><i class="bi bi-stars me-2"></i>Upgrade to Premium 300 Mbps</h6>
        </div>
        <div class="section-card-body">
            <% if (plans != null) for (ServicePlanDTO plan : plans) { %>
            <div class="price-card">
                <h5 style="color:#c4b5fd;font-weight:700;"><%= plan.getPlanName() %></h5>
                <div class="speed-compare" style="gap:12px;">
                    <span style="font-size:24px;font-weight:700;color:#60a5fa;"><%= (int)plan.getFromBandwidth() %> Mbps</span>
                    <i class="bi bi-arrow-right" style="color:var(--neon-cyan);font-size:20px;"></i>
                    <span style="font-size:24px;font-weight:700;color:#c4b5fd;"><%= (int)plan.getToBandwidth() %> Mbps</span>
                </div>
                <div class="price-amount"><%= String.format("%,d", plan.getPrice()) %> <span>VND</span></div>
                <p class="text-muted mt-2"><%= plan.getDescription() %></p>
                <p class="text-muted" style="font-size:12px;"><%= plan.getDurationDays() %> days validity</p>

                <form action="PaymentController" method="post" onsubmit="return validatePayment()">
                    <input type="hidden" name="action" value="create">
                    <input type="hidden" name="planId" value="<%= plan.getPlanId() %>">
                    <div class="mb-3 text-start">
                        <label class="form-label" style="font-size:12px;color:#9fb0d8;">Payment Method</label>
                        <select name="paymentMethod" id="paymentMethod" class="form-control-custom w-100" required>
                            <option value="">-- Select --</option>
                            <option value="MOMO">MoMo Wallet</option>
                            <option value="BANKING">Bank Transfer (manual confirmation)</option>
                        </select>
                    </div>
                    <button type="submit" class="btn-upgrade w-100 mt-2">
                        <i class="bi bi-lock me-1"></i>Pay <%= String.format("%,d", plan.getPrice()) %> VND
                    </button>
                </form>
                <p class="text-muted mt-2" style="font-size:11px;">
                    <i class="bi bi-info-circle"></i> Bank transfers require manual Admin confirmation (processing time: 1-24 hours).
                </p>
            </div>
            <% } %>
        </div>
    </div>
</div>

<%-- ===== TRANSACTIONS SECTION ===== --%>
<div class="page-section" id="page-usertransactions">
    <%
        ArrayList<PaymentTransactionDTO> txs = (ArrayList<PaymentTransactionDTO>) request.getAttribute("transactions");
        Map<Integer, String> planNames = (Map<Integer, String>) request.getAttribute("planNames");
        if (txs == null) {
            PaymentTransactionDAO ptDao = new PaymentTransactionDAO();
            ServicePlanDAO spDao2 = new ServicePlanDAO();
            txs = ptDao.findByUser(currentUser.getUserId());
            planNames = new HashMap<>();
            for (PaymentTransactionDTO tx : txs) {
                if (!planNames.containsKey(tx.getPlanId())) {
                    ServicePlanDTO sp = spDao2.searchById(tx.getPlanId());
                    planNames.put(tx.getPlanId(), sp != null ? sp.getPlanName() : "Unknown");
                }
            }
        }
    %>
    <div class="section-card">
        <div class="section-card-header">
            <h6><i class="bi bi-clock-history me-2"></i>Transaction History</h6>
        </div>
        <div class="section-card-body" style="padding:0;">
            <div style="overflow-x:auto;">
                <table class="rt-table">
                    <thead>
                        <tr>
                            <th>#</th><th>Date</th><th>Plan</th><th>Method</th><th>Amount</th><th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (txs != null && !txs.isEmpty()) {
                            int idx = 0;
                            for (PaymentTransactionDTO tx : txs) { idx++;
                            String pn = (planNames != null) ? planNames.getOrDefault(tx.getPlanId(), "Unknown") : "Unknown";
                            String statusClass = "status-pending";
                            if ("SUCCESS".equals(tx.getPaymentStatus())) statusClass = "status-success";
                            else if ("FAILED".equals(tx.getPaymentStatus())) statusClass = "status-failed";
                            else if ("PENDING_CONFIRMATION".equals(tx.getPaymentStatus())) statusClass = "status-pending";
                        %>
                        <tr>
                            <td><span style="color:var(--text-muted);">#<%= idx %></span></td>
                            <td style="color:var(--text-muted);"><%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(tx.getCreatedAt()) %></td>
                            <td><%= pn %></td>
                            <td><%= tx.getPaymentMethod() %></td>
                            <td><%= String.format("%,d", tx.getAmount()) %> VND</td>
                            <td><span class="status-badge <%= statusClass %>"><%= tx.getPaymentStatus() %></span></td>
                        </tr>
                        <% } } else { %>
                        <tr><td colspan="6" class="text-center py-4" style="color:var(--text-muted);">No transactions yet</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<%-- ===== PAYMENT RESULT SECTION ===== --%>
<div class="page-section" id="page-paymentresult">
    <%
        PaymentTransactionDTO paymentTx = (PaymentTransactionDTO) request.getAttribute("paymentTx");
        if (paymentTx == null) {
            String resultRef = request.getParameter("ref");
            if (resultRef != null) {
                PaymentTransactionDAO ptDao2 = new PaymentTransactionDAO();
                paymentTx = ptDao2.findByRef(resultRef);
            }
        }
    %>
    <div class="section-card">
        <div class="section-card-body text-center py-5">
            <% if (paymentTx != null) { %>
                <% if ("SUCCESS".equals(paymentTx.getPaymentStatus())) { %>
                    <i class="bi bi-check-circle-fill" style="font-size:64px;color:#4ade80;"></i>
                    <h3 class="mt-3" style="color:#4ade80;">Payment Successful!</h3>
                    <p class="text-muted mb-1">Your bandwidth has been upgraded to 300 Mbps</p>
                    <p class="text-muted" style="font-size:12px;">Reference: <%= paymentTx.getTransactionRef() %></p>
                    <button class="btn-upgrade mt-3" onclick="showPage('upgradeplan', document.querySelector('.nav-item-link[onclick*=\"upgradeplan\"]'))">
                        <i class="bi bi-arrow-left me-1"></i>Back to Plan
                    </button>
                <% } else if ("PENDING_CONFIRMATION".equals(paymentTx.getPaymentStatus())) { %>
                    <i class="bi bi-clock" style="font-size:64px;color:#fbbf24;"></i>
                    <h3 class="mt-3" style="color:#fbbf24;">Payment Pending Confirmation</h3>
                    <p class="text-muted mb-1">Your bank transfer is being reviewed by admin.</p>
                    <p class="text-muted" style="font-size:12px;">Reference: <%= paymentTx.getTransactionRef() %></p>
                    <p class="text-muted" style="font-size:11px;">This usually takes 1-24 hours on business days.</p>
                    <button class="btn-upgrade mt-3" onclick="showPage('upgradeplan', document.querySelector('.nav-item-link[onclick*=\"upgradeplan\"]'))">
                        <i class="bi bi-arrow-left me-1"></i>Back to Plan
                    </button>
                <% } else if ("FAILED".equals(paymentTx.getPaymentStatus())) { %>
                    <i class="bi bi-x-circle-fill" style="font-size:64px;color:#f87171;"></i>
                    <h3 class="mt-3" style="color:#f87171;">Payment Failed</h3>
                    <p class="text-muted">Please try again or choose another payment method.</p>
                    <button class="btn-upgrade mt-3" onclick="showPage('upgradeplan', document.querySelector('.nav-item-link[onclick*=\"upgradeplan\"]'))">
                        <i class="bi bi-arrow-left me-1"></i>Try Again
                    </button>
                <% } else { %>
                    <%-- PENDING hoặc trạng thái không xác định --%>
                    <i class="bi bi-hourglass-split" style="font-size:64px;color:#60a5fa;"></i>
                    <h3 class="mt-3" style="color:#60a5fa;">Processing...</h3>
                    <p class="text-muted">We're confirming your payment, this may take a few seconds.</p>
                    <p class="text-muted" style="font-size:12px;">Reference: <%= paymentTx.getTransactionRef() %></p>
                    <button class="btn-upgrade mt-3" onclick="showPage('upgradeplan', document.querySelector('.nav-item-link[onclick*=\"upgradeplan\"]'))">
                        <i class="bi bi-arrow-left me-1"></i>Back to Plan
                    </button>
                <% } %>
            <% } else { %>
                <i class="bi bi-search" style="font-size:64px;color:var(--text-muted);"></i>
                <h3 class="mt-3" style="color:var(--text-muted);">No Payment Result</h3>
                <p class="text-muted">No transaction reference provided.</p>
                <button class="btn-upgrade mt-3" onclick="showPage('upgradeplan', document.querySelector('.nav-item-link[onclick*=\"upgradeplan\"]'))">
                    <i class="bi bi-arrow-left me-1"></i>Browse Plans
                </button>
            <% } %>
        </div>
    </div>
</div>
```

- [ ] **Step 5: Add CSS for the new sections**

Add to the `<style>` block:
```css
.speed-compare { display: flex; align-items: center; justify-content: center; gap: 20px; margin: 20px 0; }
.speed-box { text-align: center; padding: 16px 24px; border-radius: var(--radius-md); min-width: 120px; }
.speed-box.current { background: rgba(96,165,250,0.1); border: 1px solid rgba(96,165,250,0.2); }
.speed-box.upgraded { background: rgba(139,92,246,0.12); border: 1px solid rgba(139,92,246,0.3); }
.speed-val { font-size: 28px; font-weight: 800; }
.speed-arrow { font-size: 28px; color: var(--neon-cyan); }
.price-card { background: linear-gradient(135deg, rgba(139,92,246,0.12), rgba(217,70,239,0.06)); border: 1px solid rgba(139,92,246,0.3); border-radius: var(--radius-lg); padding: 24px; text-align: center; max-width: 480px; margin: 0 auto; }
.price-amount { font-size: 42px; font-weight: 800; color: #c4b5fd; }
.price-amount span { font-size: 18px; color: var(--text-muted); }
.btn-upgrade { background: linear-gradient(135deg, var(--neon-purple), var(--neon-pink)); border: none; color: white; padding: 12px 32px; border-radius: 10px; font-weight: 700; font-size: 16px; cursor: pointer; transition: .2s; }
.btn-upgrade:hover { filter: brightness(1.15); box-shadow: 0 0 24px rgba(139,92,246,0.4); }
.btn-upgrade:disabled { opacity: 0.5; cursor: not-allowed; }
.form-control-custom { background: #0f162b; border: 1px solid var(--border); color: #e7ecff; border-radius: 8px; padding: 10px 14px; }
.form-control-custom:focus { border-color: var(--neon-purple); box-shadow: 0 0 0 2px rgba(139,92,246,0.2); }
.status-badge { padding: 3px 10px; border-radius: 999px; font-size: 11px; font-weight: 700; }
.status-success { background: rgba(74,222,128,0.16); color: #4ade80; border: 1px solid rgba(74,222,128,0.3); }
.status-pending { background: rgba(251,191,36,0.16); color: #fbbf24; border: 1px solid rgba(251,191,36,0.3); }
.status-failed { background: rgba(239,68,68,0.16); color: #f87171; border: 1px solid rgba(239,68,68,0.3); }
.rt-table { width:100%; border-collapse:collapse; font-size:0.82rem; }
.rt-table thead tr { background:rgba(22,31,54,0.95); border-bottom:1px solid var(--border); }
.rt-table thead th { padding:11px 13px; color:var(--text-muted); font-weight:600; font-size:0.7rem; letter-spacing:.08em; text-transform:uppercase; white-space:nowrap; }
.rt-table tbody tr { border-bottom:1px solid rgba(42,53,85,0.35); }
.rt-table tbody td { padding:11px 13px; color:var(--text-primary); vertical-align:middle; }
```

- [ ] **Step 6: Add the `validatePayment()` function** in the `<script>` block:

```javascript
function validatePayment() {
    var method = document.getElementById('paymentMethod');
    if (!method.value) { alert('Please select a payment method'); return false; }
    return confirm('Confirm upgrade to Premium 300 Mbps?');
}
```

---

### Task 7: Add sidebar buttons in userDashboard.jsp

*(Covered in Task 6 Step 2 above — no separate file needed)*

---

### Task 8: Dashboard bandwidth stat card

**Files:**
- Modify: `NetworkManagerWeb/web/userDashboard.jsp`

- [ ] **Step 1: Read actual bandwidth from DB instead of hard-coding**

Replace the static "My Bandwidth" card in the dashboard section with:

```jsp
<%
    // Load user bandwidth for dashboard card
    UserBandwidthDAO ubDaoCard = new UserBandwidthDAO();
    UserBandwidthDTO ubCard = ubDaoCard.findByUserId(currentUser.getUserId());
    double bwLimit = (ubCard != null) ? ubCard.getBandwidthLimit() : 100;
    boolean isUpgraded = bwLimit > 100;
%>
<div class="col-6 col-md-3">
    <div class="stat-card">
        <div class="stat-icon" style="background:<%= isUpgraded ? "rgba(74,222,128,0.16)" : "rgba(139,92,246,0.16)" %>;color:<%= isUpgraded ? "#4ade80" : "#c4b5fd" %>;">
            <i class="bi bi-speedometer2"></i>
        </div>
        <div class="stat-value" style="color:<%= isUpgraded ? "#4ade80" : "#c4b5fd" %>;">
            <%= (int)bwLimit %> <span style="font-size:14px;color:#97a8d0;">Mbps</span>
        </div>
        <div class="stat-label">My Bandwidth</div>
        <div class="stat-delta"><%= isUpgraded ? "Premium 300 Mbps" : "Standard plan" %></div>
    </div>
</div>
```

---

### Task 9 (Future — Admin module): Confirm banking transaction

**Khi làm Admin plan, cần thêm action này.** Chưa implement trong phase user-side này.

```java
// Trong AdminPaymentController (hoặc PaymentController với role check Admin)
case "confirm-banking":
    String ref = req.getParameter("ref");
    if (ref == null) { /* error */ return; }
    PaymentTransactionDTO tx = txDAO.findByRef(ref);
    if (tx == null || !"PENDING_CONFIRMATION".equals(tx.getPaymentStatus())) { /* error */ return; }
    boolean ok = txDAO.updateStatusByRef(ref, "SUCCESS");
    if (ok) {
        // Gọi được vì upgradeBandwidth() là package-private (default) trong cùng package Controller
        upgradeBandwidth(tx.getUserId(), tx.getPlanId());
    }
    resp.sendRedirect("staffDashboard.jsp?page=billing");
    break;
```

---

### Implementation Order

1. **Task 1**: DB script → execute SQL
2. **Task 2**: DTOs (3 files)
3. **Task 3**: DAOs (3 files)
4. **Task 5**: PaymentConfig utility
5. **Task 4**: PaymentController + web.xml
6. **Task 6 + 7 + 8**: userDashboard.jsp updates
7. *Sau đó: Task 9 (Admin confirm-banking) khi làm Admin plan*
