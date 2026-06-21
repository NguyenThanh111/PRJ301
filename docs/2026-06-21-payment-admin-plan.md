# [ADMIN SIDE] Upgrade Bandwidth Management — Implementation Plan

> **For agentic workers:** Use subagent-driven-development or executing-plans to implement task-by-task.

**Goal:** Cho Admin quản lý các giao dịch nâng cấp băng thông của User, theo dõi doanh thu, phát hiện rủi ro, và quản lý bằng biểu đồ trực quan.

**Architecture:** 4 section mới trong `staffDashboard.jsp` (SPA), sidebar mới trong `sidebar.jsp`, dùng Chart.js cho biểu đồ, SystemLog để audit. Tách biệt hoàn toàn khỏi User side.

**Tech Stack:** Java Servlet/JSP, SQL Server, JDBC (DAO pattern), Bootstrap 5.3.3, Chart.js.

## Global Constraints

- Package: `Models`, `Controller`, `Utils`
- DAO implement `IDAO<T, K>` interface
- Kết nối DB qua `Utils.DbUtils.getConnection()`
- UI theo dark neon theme hiện tại (CSS variables)
- JSP dùng JSTL + Bootstrap 5.3.3 + Bootstrap Icons
- Chart.js cho biểu đồ quản lý
- Admin check: `roleLower eq 'admin'`

---

### Task 1: DAO bổ sung — Method thống kê cho Admin

**Files:**
- Modify: `NetworkManagerWeb/src/java/Models/PaymentTransactionDAO.java`
- Modify: `NetworkManagerWeb/src/java/Models/UserBandwidthDAO.java`

**Interfaces:**
- Consumes: PaymentTransactionDTO, UserBandwidthDTO từ User plan
- Produces: Methods thống kê, aggregate queries

- [ ] **Step 1: Thêm methods thống kê vào PaymentTransactionDAO.java**

```java
public long getTotalRevenue() {
    String sql = "SELECT ISNULL(SUM(amount), 0) FROM PaymentTransaction WHERE payment_status = 'SUCCESS'";
    try (Connection conn = DbUtils.getConnection(); Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(sql)) {
        if (rs.next()) return rs.getLong(1);
    } catch (Exception e) { e.printStackTrace(); }
    return 0;
}

public long getMonthlyRevenue() {
    String sql = "SELECT ISNULL(SUM(amount), 0) FROM PaymentTransaction WHERE payment_status = 'SUCCESS' AND MONTH(created_at) = MONTH(GETDATE()) AND YEAR(created_at) = YEAR(GETDATE())";
    try (Connection conn = DbUtils.getConnection(); Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(sql)) {
        if (rs.next()) return rs.getLong(1);
    } catch (Exception e) { e.printStackTrace(); }
    return 0;
}

public int countByStatus(String status) {
    String sql = "SELECT COUNT(*) FROM PaymentTransaction WHERE payment_status = ?";
    try (Connection conn = DbUtils.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, status);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) return rs.getInt(1);
    } catch (Exception e) { e.printStackTrace(); }
    return 0;
}

public ArrayList<PaymentTransactionDTO> findRecent(int limit) {
    ArrayList<PaymentTransactionDTO> list = new ArrayList<>();
    String sql = "SELECT TOP (?) * FROM PaymentTransaction ORDER BY created_at DESC";
    try (Connection conn = DbUtils.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, limit);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) list.add(mapRow(rs));
    } catch (Exception e) { e.printStackTrace(); }
    return list;
}

// Doanh thu theo từng tháng trong năm
public ArrayList<Object[]> monthlyRevenue(int year) {
    ArrayList<Object[]> list = new ArrayList<>();
    String sql = "SELECT MONTH(created_at) as m, ISNULL(SUM(amount), 0) as total FROM PaymentTransaction WHERE payment_status = 'SUCCESS' AND YEAR(created_at) = ? GROUP BY MONTH(created_at) ORDER BY m";
    try (Connection conn = DbUtils.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, year);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) list.add(new Object[]{rs.getInt("m"), rs.getLong("total")});
    } catch (Exception e) { e.printStackTrace(); }
    return list;
}
```

- [ ] **Step 2: Thêm methods vào UserBandwidthDAO.java**

```java
public int countUpgraded() {
    String sql = "SELECT COUNT(*) FROM UserBandwidth WHERE is_active = 1 AND bandwidth_limit > 100";
    try (Connection conn = DbUtils.getConnection(); Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(sql)) {
        if (rs.next()) return rs.getInt(1);
    } catch (Exception e) { e.printStackTrace(); }
    return 0;
}

public int countExpiringSoon(int days) {
    String sql = "SELECT COUNT(*) FROM UserBandwidth WHERE is_active = 1 AND expires_at IS NOT NULL AND DATEDIFF(DAY, GETDATE(), expires_at) BETWEEN 0 AND ?";
    try (Connection conn = DbUtils.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, days);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) return rs.getInt(1);
    } catch (Exception e) { e.printStackTrace(); }
    return 0;
}

public ArrayList<UserBandwidthDTO> listExpiringSoon(int days) {
    ArrayList<UserBandwidthDTO> list = new ArrayList<>();
    String sql = "SELECT * FROM UserBandwidth WHERE is_active = 1 AND expires_at IS NOT NULL AND DATEDIFF(DAY, GETDATE(), expires_at) BETWEEN 0 AND ? ORDER BY expires_at";
    try (Connection conn = DbUtils.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, days);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) list.add(mapRow(rs));
    } catch (Exception e) { e.printStackTrace(); }
    return list;
}

public ArrayList<Object[]> countUpgradedByMonth(int year) {
    ArrayList<Object[]> list = new ArrayList<>();
    String sql = "SELECT MONTH(upgraded_at) as m, COUNT(*) as total FROM UserBandwidth WHERE YEAR(upgraded_at) = ? AND upgraded_at IS NOT NULL GROUP BY MONTH(upgraded_at) ORDER BY m";
    try (Connection conn = DbUtils.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, year);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) list.add(new Object[]{rs.getInt("m"), rs.getInt("total")});
    } catch (Exception e) { e.printStackTrace(); }
    return list;
}

// Phát hiện bất thường: user nâng cấp nhiều lần
public ArrayList<Object[]> findSuspiciousUsers(int minCount) {
    ArrayList<Object[]> list = new ArrayList<>();
    String sql = "SELECT pt.user_id, COUNT(*) as cnt FROM PaymentTransaction pt WHERE pt.payment_status = 'SUCCESS' GROUP BY pt.user_id HAVING COUNT(*) >= ? ORDER BY cnt DESC";
    try (Connection conn = DbUtils.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, minCount);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) list.add(new Object[]{rs.getInt("user_id"), rs.getInt("cnt")});
    } catch (Exception e) { e.printStackTrace(); }
    return list;
}
```

---

### Task 2: AdminPaymentController — Xử lý Admin

**Files:**
- Create: `NetworkManagerWeb/src/java/Controller/AdminPaymentController.java`
- Modify: `NetworkManagerWeb/web/WEB-INF/web.xml`

**Interfaces:**
- Consumes: Tất cả DAOs, các methods thống kê từ Task 1
- Produces: URL `/AdminPaymentController`

- [ ] **Step 1: Viết AdminPaymentController.java**

```java
package Controller;

import Models.*;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet(name = "AdminPaymentController", urlPatterns = {"/AdminPaymentController"})
public class AdminPaymentController extends HttpServlet {

    private final ServicePlanDAO planDAO = new ServicePlanDAO();
    private final PaymentTransactionDAO txDAO = new PaymentTransactionDAO();
    private final UserBandwidthDAO ubDAO = new UserBandwidthDAO();
    private final UserDAO userDAO = new UserDAO();
    private final SystemLogDAO logDAO = new SystemLogDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html;charset=UTF-8");

        HttpSession session = req.getSession();
        UserDTO user = (UserDTO) session.getAttribute("user");
        String role = (String) session.getAttribute("role");
        if (user == null || role == null || !role.equalsIgnoreCase("Admin")) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String action = req.getParameter("action");
        if (action == null) action = "overview";

        switch (action) {
            case "overview":
                loadOverview(req);
                req.getRequestDispatcher("staffDashboard.jsp?page=billing-overview").forward(req, resp);
                break;
            case "transactions":
                loadTransactions(req);
                req.getRequestDispatcher("staffDashboard.jsp?page=billing-transactions").forward(req, resp);
                break;
            case "plans":
                req.setAttribute("plans", planDAO.ListAll());
                req.getRequestDispatcher("staffDashboard.jsp?page=billing-plans").forward(req, resp);
                break;
            case "risks":
                loadRisks(req);
                req.getRequestDispatcher("staffDashboard.jsp?page=billing-risks").forward(req, resp);
                break;
            case "manual-downgrade":
                handleManualDowngrade(req, resp);
                break;
            case "manual-sync":
                handleManualSync(req, resp);
                break;
            default:
                resp.sendRedirect("AdminPaymentController?action=overview");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doGet(req, resp);
    }

    private void loadOverview(HttpServletRequest req) {
        long totalRevenue = txDAO.getTotalRevenue();
        long monthlyRevenue = txDAO.getMonthlyRevenue();
        int totalUpgraded = ubDAO.countUpgraded();
        int expiringSoon = ubDAO.countExpiringSoon(3);
        int totalSuccess = txDAO.countByStatus("SUCCESS");
        int totalFailed = txDAO.countByStatus("FAILED");
        int totalPending = txDAO.countByStatus("PENDING");

        ArrayList<Object[]> monthlyRev = txDAO.monthlyRevenue(Calendar.getInstance().get(Calendar.YEAR));
        ArrayList<Object[]> monthlyUpgrades = ubDAO.countUpgradedByMonth(Calendar.getInstance().get(Calendar.YEAR));

        req.setAttribute("totalRevenue", totalRevenue);
        req.setAttribute("monthlyRevenue", monthlyRevenue);
        req.setAttribute("totalUpgraded", totalUpgraded);
        req.setAttribute("expiringSoon", expiringSoon);
        req.setAttribute("totalSuccess", totalSuccess);
        req.setAttribute("totalFailed", totalFailed);
        req.setAttribute("totalPending", totalPending);
        req.setAttribute("monthlyRev", monthlyRev);
        req.setAttribute("monthlyUpgrades", monthlyUpgrades);
    }

    private void loadTransactions(HttpServletRequest req) {
        String statusFilter = req.getParameter("status");
        ArrayList<PaymentTransactionDTO> list = txDAO.findRecent(100);
        HashMap<Integer, String> userNames = new HashMap<>();
        HashMap<Integer, String> planNames = new HashMap<>();
        ServicePlanDAO spDAO = new ServicePlanDAO();
        for (PaymentTransactionDTO tx : list) {
            if (!userNames.containsKey(tx.getUserId())) {
                UserDTO u = userDAO.searchById(tx.getUserId());
                userNames.put(tx.getUserId(), u != null ? u.getFullName() : "Unknown");
            }
            if (!planNames.containsKey(tx.getPlanId())) {
                ServicePlanDTO sp = spDAO.searchById(tx.getPlanId());
                planNames.put(tx.getPlanId(), sp != null ? sp.getPlanName() : "Unknown");
            }
        }
        req.setAttribute("txList", list);
        req.setAttribute("txUserNames", userNames);
        req.setAttribute("txPlanNames", planNames);
    }

    private void loadRisks(HttpServletRequest req) {
        // 1. Payment OK nhưng DB chưa update
        ArrayList<PaymentTransactionDTO> inconsistent = new ArrayList<>();
        for (PaymentTransactionDTO tx : txDAO.findRecent(50)) {
            if ("SUCCESS".equals(tx.getPaymentStatus())) {
                UserBandwidthDTO ub = ubDAO.findByUserId(tx.getUserId());
                if (ub == null || ub.getExpiresAt() == null) {
                    inconsistent.add(tx);
                }
            }
        }
        req.setAttribute("inconsistentTxs", inconsistent);

        // 2. Sắp hết hạn
        req.setAttribute("expiringList", ubDAO.listExpiringSoon(3));

        // 3. User bất thường (nâng cấp > 3 lần)
        req.setAttribute("suspiciousUsers", ubDAO.findSuspiciousUsers(3));

        // 4. User info lookup
        HashMap<Integer, String> riskUserNames = new HashMap<>();
        for (PaymentTransactionDTO tx : inconsistent) {
            if (!riskUserNames.containsKey(tx.getUserId())) {
                UserDTO u = userDAO.searchById(tx.getUserId());
                riskUserNames.put(tx.getUserId(), u != null ? u.getFullName() : "Unknown");
            }
        }
        for (Object[] su : ubDAO.findSuspiciousUsers(3)) {
            int uid = (int) su[0];
            if (!riskUserNames.containsKey(uid)) {
                UserDTO u = userDAO.searchById(uid);
                riskUserNames.put(uid, u != null ? u.getFullName() : "Unknown");
            }
        }
        req.setAttribute("riskUserNames", riskUserNames);
    }

    private void handleManualDowngrade(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int userId = Integer.parseInt(req.getParameter("userId"));
        UserBandwidthDTO ub = ubDAO.findByUserId(userId);
        if (ub != null) {
            ub.setBandwidthLimit(100);
            ub.setExpiresAt(null);
            ub.setUpgradedAt(null);
            ub.setIsActive(true);
            ubDAO.update(ub);

            logDAO.insert(new SystemLogDTO(0, "BANDWIDTH_DOWNGRADE", new Timestamp(System.currentTimeMillis()),
                    "Manual downgrade User ID " + userId + " to 100 Mbps", userId));
        }
        resp.sendRedirect("AdminPaymentController?action=risks");
    }

    private void handleManualSync(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int txId = Integer.parseInt(req.getParameter("txId"));
        PaymentTransactionDTO tx = txDAO.searchById(txId);
        if (tx != null && "SUCCESS".equals(tx.getPaymentStatus())) {
            ServicePlanDTO plan = planDAO.searchById(tx.getPlanId());
            if (plan != null) {
                UserBandwidthDTO ub = ubDAO.findByUserId(tx.getUserId());
                Calendar cal = Calendar.getInstance();
                Timestamp now = new Timestamp(cal.getTimeInMillis());
                cal.add(Calendar.DAY_OF_MONTH, plan.getDurationDays());
                Timestamp expires = new Timestamp(cal.getTimeInMillis());
                if (ub == null) {
                    ub = new UserBandwidthDTO(0, tx.getUserId(), plan.getToBandwidth(), now, expires, true);
                    ubDAO.insert(ub);
                } else {
                    ub.setBandwidthLimit(plan.getToBandwidth());
                    ub.setUpgradedAt(now);
                    ub.setExpiresAt(expires);
                    ub.setIsActive(true);
                    ubDAO.update(ub);
                }
                logDAO.insert(new SystemLogDTO(0, "BANDWIDTH_SYNC", new Timestamp(System.currentTimeMillis()),
                        "Manual sync Transaction #" + txId + " for User ID " + tx.getUserId(), 1));
            }
        }
        resp.sendRedirect("AdminPaymentController?action=risks");
    }
}
```

- [ ] **Step 2: Thêm vào web.xml**

```xml
<servlet>
    <servlet-name>AdminPaymentController</servlet-name>
    <servlet-class>Controller.AdminPaymentController</servlet-class>
</servlet>
<servlet-mapping>
    <servlet-name>AdminPaymentController</servlet-name>
    <url-pattern>/AdminPaymentController</url-pattern>
</servlet-mapping>
```

---

### Task 3: Update sidebar.jsp — Thêm menu Billing & Plans

**Files:**
- Modify: `NetworkManagerWeb/web/sidebar.jsp`

- [ ] **Step 1: Thêm section "Billing & Plans" sau Administration, chỉ hiện với Admin**

Chèn trước `</c:if>` của phần Administration:
```html
<div class="sidebar-section-label">Billing &amp; Plans</div>
<a href="AdminPaymentController?action=overview" class="nav-item-link text-decoration-none ${sa eq 'billing-overview' ? 'active' : ''}">
    <i class="bi bi-graph-up"></i> Bandwidth Analytics
</a>
<a href="AdminPaymentController?action=transactions" class="nav-item-link text-decoration-none ${sa eq 'billing-transactions' ? 'active' : ''}">
    <i class="bi bi-currency-dollar"></i> Transaction Logs
</a>
<a href="AdminPaymentController?action=plans" class="nav-item-link text-decoration-none ${sa eq 'billing-plans' ? 'active' : ''}">
    <i class="bi bi-card-list"></i> Plans Management
</a>
<a href="AdminPaymentController?action=risks" class="nav-item-link text-decoration-none ${sa eq 'billing-risks' ? 'active' : ''}">
    <i class="bi bi-shield-exclamation"></i> Risk Management
</a>
```

---

### Task 4: Staff dashboard — Section Billing Overview (biểu đồ)

**Files:**
- Modify: `NetworkManagerWeb/web/staffDashboard.jsp`

- [ ] **Step 1: Thêm section `#page-billing-overview` trong phần Administration của staffDashboard.jsp**

Thêm sau section `#page-systemlogs`, trong `<c:if test="${isAdmin}">`:

```jsp
<div class="page-section" id="page-billing-overview">
    <div class="row g-3 mb-4">
        <div class="col-6 col-md-3">
            <div class="stat-card">
                <div class="stat-icon" style="background:rgba(139,92,246,0.16);color:#c4b5fd;"><i class="bi bi-people"></i></div>
                <div class="stat-value" style="color:#c4b5fd;">${totalUpgraded}</div>
                <div class="stat-label">Upgraded Users</div>
                <div class="stat-delta">Premium plan active</div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="stat-card">
                <div class="stat-icon" style="background:rgba(74,222,128,0.16);color:#4ade80;"><i class="bi bi-cash-stack"></i></div>
                <div class="stat-value" style="color:#4ade80;"><fmt:formatNumber value="${monthlyRevenue}" pattern="#,###"/></div>
                <div class="stat-label">Monthly Revenue</div>
                <div class="stat-delta">VND this month</div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="stat-card">
                <div class="stat-icon" style="background:rgba(251,191,36,0.16);color:#fbbf24;"><i class="bi bi-clock"></i></div>
                <div class="stat-value" style="color:#fbbf24;">${expiringSoon}</div>
                <div class="stat-label">Expiring Soon</div>
                <div class="stat-delta">Within 3 days</div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="stat-card">
                <div class="stat-icon" style="background:rgba(96,165,250,0.16);color:#60a5fa;"><i class="bi bi-pie-chart"></i></div>
                <div class="stat-value" style="color:#60a5fa;">${totalSuccess}<span style="font-size:14px;color:#97a8d0;">/${totalSuccess + totalFailed}</span></div>
                <div class="stat-label">Success Rate</div>
                <div class="stat-delta">${totalFailed} failed</div>
            </div>
        </div>
    </div>

    <div class="row g-3 mb-4">
        <div class="col-md-6">
            <div class="section-card">
                <div class="section-card-header"><h6><i class="bi bi-bar-chart-line me-2"></i>Monthly Revenue</h6></div>
                <div class="section-card-body">
                    <canvas id="revenueChart" height="200"></canvas>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="section-card">
                <div class="section-card-header"><h6><i class="bi bi-graph-up me-2"></i>Upgrades per Month</h6></div>
                <div class="section-card-body">
                    <canvas id="upgradeChart" height="200"></canvas>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-3">
        <div class="col-md-4">
            <div class="section-card">
                <div class="section-card-header"><h6><i class="bi bi-pie-chart me-2"></i>Payment Methods</h6></div>
                <div class="section-card-body">
                    <canvas id="methodChart" height="200"></canvas>
                </div>
            </div>
        </div>
        <div class="col-md-8">
            <div class="section-card">
                <div class="section-card-header"><h6><i class="bi bi-lightning me-2"></i>Revenue Breakdown</h6></div>
                <div class="section-card-body">
                    <div class="row g-2">
                        <div class="col-4 text-center py-3" style="border-right:1px solid var(--border);">
                            <div style="font-size:28px;font-weight:800;color:#c4b5fd;"><fmt:formatNumber value="${totalRevenue}" pattern="#,###"/></div>
                            <div class="stat-label">Total Revenue (VND)</div>
                        </div>
                        <div class="col-4 text-center py-3" style="border-right:1px solid var(--border);">
                            <div style="font-size:28px;font-weight:800;color:#4ade80;">${totalSuccess}</div>
                            <div class="stat-label">Successful Payments</div>
                        </div>
                        <div class="col-4 text-center py-3">
                            <div style="font-size:28px;font-weight:800;color:#f87171;">${totalPending}</div>
                            <div class="stat-label">Pending Payments</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    var monthNames = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

    // Revenue chart
    var revCtx = document.getElementById('revenueChart');
    if (revCtx) {
        var revData = ${monthlyRevJson};
        new Chart(revCtx, {
            type: 'bar',
            data: {
                labels: monthNames,
                datasets: [{
                    label: 'Revenue (VND)',
                    data: revData,
                    backgroundColor: 'rgba(139,92,246,0.5)',
                    borderColor: '#8b5cf6',
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                plugins: { legend: { labels: { color: '#9aa6c7' } } },
                scales: {
                    x: { ticks: { color: '#9aa6c7' }, grid: { color: 'rgba(42,53,85,0.3)' } },
                    y: { ticks: { color: '#9aa6c7' }, grid: { color: 'rgba(42,53,85,0.3)' } }
                }
            }
        });
    }

    // Upgrade chart
    var upCtx = document.getElementById('upgradeChart');
    if (upCtx) {
        var upData = ${monthlyUpgradesJson};
        new Chart(upCtx, {
            type: 'line',
            data: {
                labels: monthNames,
                datasets: [{
                    label: 'Upgrades',
                    data: upData,
                    borderColor: '#4ade80',
                    backgroundColor: 'rgba(74,222,128,0.1)',
                    fill: true,
                    tension: 0.4
                }]
            },
            options: {
                responsive: true,
                plugins: { legend: { labels: { color: '#9aa6c7' } } },
                scales: {
                    x: { ticks: { color: '#9aa6c7' }, grid: { color: 'rgba(42,53,85,0.3)' } },
                    y: { ticks: { color: '#9aa6c7', stepSize: 1 }, grid: { color: 'rgba(42,53,85,0.3)' } }
                }
            }
        });
    }

    // Method chart (pie)
    var methodCtx = document.getElementById('methodChart');
    if (methodCtx) {
        new Chart(methodCtx, {
            type: 'doughnut',
            data: {
                labels: ['MoMo', 'Bank Transfer'],
                datasets: [{
                    data: [${momoCount}, ${bankCount}],
                    backgroundColor: ['#8b5cf6', '#60a5fa'],
                    borderWidth: 0
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: { color: '#9aa6c7', padding: 12 }
                    }
                }
            }
        });
    }
});
</script>
```

- [ ] **Step 2: Bổ sung thêm attributes JSON cho Chart.js trong AdminPaymentController.loadOverview()**

Thêm vào cuối method `loadOverview`:
```java
// JSON data cho Chart.js
StringBuilder revJson = new StringBuilder("[");
java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
for (int i = 1; i <= 12; i++) {
    boolean found = false;
    for (Object[] row : monthlyRev) {
        if ((int)row[0] == i) {
            if (revJson.length() > 1) revJson.append(",");
            revJson.append((long)row[1]);
            found = true; break;
        }
    }
    if (!found) {
        if (revJson.length() > 1) revJson.append(",");
        revJson.append("0");
    }
}
revJson.append("]");
req.setAttribute("monthlyRevJson", revJson.toString());

StringBuilder upJson = new StringBuilder("[");
for (int i = 1; i <= 12; i++) {
    boolean found = false;
    for (Object[] row : monthlyUpgrades) {
        if ((int)row[0] == i) {
            if (upJson.length() > 1) upJson.append(",");
            upJson.append((int)row[1]);
            found = true; break;
        }
    }
    if (!found) {
        if (upJson.length() > 1) upJson.append(",");
        upJson.append("0");
    }
}
upJson.append("]");
req.setAttribute("monthlyUpgradesJson", upJson.toString());

// Payment method counts
int momoCount = 0, bankCount = 0;
for (PaymentTransactionDTO tx : txDAO.ListAll()) {
    if ("SUCCESS".equals(tx.getPaymentStatus())) {
        if ("MOMO".equalsIgnoreCase(tx.getPaymentMethod())) momoCount++;
        else bankCount++;
    }
}
req.setAttribute("momoCount", momoCount);
req.setAttribute("bankCount", bankCount);
```

---

### Task 5: Staff dashboard — Section Transaction Logs

**Files:**
- Modify: `NetworkManagerWeb/web/staffDashboard.jsp`

- [ ] **Step 1: Thêm section `#page-billing-transactions`**

```jsp
<div class="page-section" id="page-billing-transactions">
    <div class="section-card">
        <div class="section-card-header">
            <h6><i class="bi bi-currency-dollar me-2"></i>Transaction Logs</h6>
        </div>
        <div class="section-card-body" style="padding:0;">
            <div style="overflow-x:auto;">
                <table class="rt-table">
                    <thead>
                        <tr>
                            <th>#</th><th>Date</th><th>User</th><th>Plan</th><th>Method</th><th>Amount</th><th>Status</th><th>Ref</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty txList}">
                                <c:forEach var="tx" items="${txList}">
                                    <tr>
                                        <td><span class="rt-id">#${tx.transactionId}</span></td>
                                        <td style="color:var(--text-muted);"><fmt:formatDate value="${tx.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                        <td><c:out value="${txUserNames[tx.userId]}" default="User #${tx.userId}"/></td>
                                        <td><c:out value="${txPlanNames[tx.planId]}" default="Plan #${tx.planId}"/></td>
                                        <td>${tx.paymentMethod}</td>
                                        <td style="font-weight:600;"><fmt:formatNumber value="${tx.amount}" pattern="#,###"/> VND</td>
                                        <td><span class="status-badge ${tx.paymentStatus eq 'SUCCESS' ? 'status-success' : tx.paymentStatus eq 'FAILED' ? 'status-failed' : 'status-pending'}">${tx.paymentStatus}</span></td>
                                        <td style="font-family:monospace;font-size:11px;color:var(--text-muted);">${tx.transactionRef}</td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr><td colspan="8" class="text-center py-4" style="color:var(--text-muted);">No transactions found</td></tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
```

---

### Task 6: Staff dashboard — Section Plans Management

**Files:**
- Modify: `NetworkManagerWeb/web/staffDashboard.jsp`

- [ ] **Step 1: Thêm section `#page-billing-plans`**

```jsp
<div class="page-section" id="page-billing-plans">
    <div class="section-card">
        <div class="section-card-header">
            <h6><i class="bi bi-card-list me-2"></i>Service Plans</h6>
            <button class="btn-theme" onclick="alert('Add plan form - coming soon')"><i class="bi bi-plus-lg me-1"></i>Add Plan</button>
        </div>
        <div class="section-card-body" style="padding:0;">
            <div style="overflow-x:auto;">
                <table class="rt-table">
                    <thead>
                        <tr>
                            <th>ID</th><th>Name</th><th>From</th><th>To</th><th>Price</th><th>Duration</th><th>Active</th><th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="p" items="${plans}">
                            <tr>
                                <td><span class="rt-id">#${p.planId}</span></td>
                                <td style="font-weight:600;">${p.planName}</td>
                                <td>${p.fromBandwidth} Mbps</td>
                                <td style="color:#c4b5fd;font-weight:600;">${p.toBandwidth} Mbps</td>
                                <td><fmt:formatNumber value="${p.price}" pattern="#,###"/> VND</td>
                                <td>${p.durationDays} days</td>
                                <td><span class="status-badge ${p.isActive ? 'status-success' : 'status-failed'}">${p.isActive ? 'ACTIVE' : 'INACTIVE'}</span></td>
                                <td>
                                    <button class="btn-theme" onclick="alert('Edit plan #${p.planId}')"><i class="bi bi-pencil"></i></button>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
```

---

### Task 7: Staff dashboard — Section Risk Management

**Files:**
- Modify: `NetworkManagerWeb/web/staffDashboard.jsp`

- [ ] **Step 1: Thêm section `#page-billing-risks`**

```jsp
<div class="page-section" id="page-billing-risks">
    <%-- Inconsistent Transactions --%>
    <div class="section-card mb-3">
        <div class="section-card-header">
            <h6><i class="bi bi-exclamation-triangle me-2" style="color:#f87171;"></i>Inconsistent Payments</h6>
            <span class="status-badge status-failed">${inconsistentTxs.size()} issues</span>
        </div>
        <div class="section-card-body" style="padding:0;">
            <div style="overflow-x:auto;">
                <table class="rt-table">
                    <thead>
                        <tr><th>#</th><th>User</th><th>Amount</th><th>Date</th><th>Action</th></tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty inconsistentTxs}">
                                <c:forEach var="tx" items="${inconsistentTxs}">
                                    <tr>
                                        <td><span class="rt-id">#${tx.transactionId}</span></td>
                                        <td><c:out value="${riskUserNames[tx.userId]}" default="User #${tx.userId}"/></td>
                                        <td><fmt:formatNumber value="${tx.amount}" pattern="#,###"/> VND</td>
                                        <td style="color:var(--text-muted);"><fmt:formatDate value="${tx.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                        <td><a href="AdminPaymentController?action=manual-sync&txId=${tx.transactionId}" class="btn-theme text-decoration-none"><i class="bi bi-arrow-repeat me-1"></i>Manual Sync</a></td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr><td colspan="5" class="text-center py-4" style="color:#4ade80;"><i class="bi bi-check-circle me-1"></i>All payments are consistent</td></tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <%-- Expiring Soon --%>
    <div class="section-card mb-3">
        <div class="section-card-header">
            <h6><i class="bi bi-clock me-2" style="color:#fbbf24;"></i>Expiring Soon (3 days)</h6>
            <span class="status-badge status-pending">${expiringList.size()} items</span>
        </div>
        <div class="section-card-body" style="padding:0;">
            <div style="overflow-x:auto;">
                <table class="rt-table">
                    <thead>
                        <tr><th>User ID</th><th>Bandwidth</th><th>Expires</th><th>Action</th></tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty expiringList}">
                                <c:forEach var="ub" items="${expiringList}">
                                    <tr>
                                        <td><span class="rt-id">#${ub.userId}</span></td>
                                        <td style="font-weight:600;">${ub.bandwidthLimit} Mbps</td>
                                        <td style="color:#fbbf24;"><fmt:formatDate value="${ub.expiresAt}" pattern="dd/MM/yyyy"/></td>
                                        <td>
                                            <a href="AdminPaymentController?action=manual-downgrade&userId=${ub.userId}" class="btn-theme text-decoration-none" onclick="return confirm('Downgrade this user to 100 Mbps?')"><i class="bi bi-arrow-down-circle me-1"></i>Downgrade</a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr><td colspan="4" class="text-center py-4" style="color:#4ade80;"><i class="bi bi-check-circle me-1"></i>No expiring upgrades</td></tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <%-- Suspicious Users --%>
    <div class="section-card">
        <div class="section-card-header">
            <h6><i class="bi bi-shield-exclamation me-2" style="color:#ef4444;"></i>Suspicious Activity</h6>
            <span class="status-badge status-failed">${suspiciousUsers.size()} flagged</span>
        </div>
        <div class="section-card-body" style="padding:0;">
            <div style="overflow-x:auto;">
                <table class="rt-table">
                    <thead>
                        <tr><th>User</th><th>Upgrade Count</th><th>Status</th></tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty suspiciousUsers}">
                                <c:forEach var="su" items="${suspiciousUsers}">
                                    <tr>
                                        <td><c:out value="${riskUserNames[su[0]]}" default="User #${su[0]}"/></td>
                                        <td style="color:#f87171;font-weight:600;">${su[1]} times</td>
                                        <td><span class="status-badge status-failed">⚠ Flagged</span></td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr><td colspan="3" class="text-center py-4" style="color:#4ade80;"><i class="bi bi-shield-check me-1"></i>No suspicious activity detected</td></tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
```

---

### Task 8: Update pageTitles cho staffDashboard.jsp

**Files:**
- Modify: `NetworkManagerWeb/web/staffDashboard.jsp`

- [ ] **Step 1: Thêm entries vào pageTitles**

```javascript
'billing-overview':    { title: 'Bandwidth Analytics',  breadcrumb: '/ Billing' },
'billing-transactions':{ title: 'Transaction Logs',     breadcrumb: '/ Billing' },
'billing-plans':       { title: 'Plans Management',    breadcrumb: '/ Billing' },
'billing-risks':       { title: 'Risk Management',     breadcrumb: '/ Billing' }
```

---

### Task 9: Thêm CSS cho status badges vào staffDashboard.jsp

**Files:**
- Modify: `NetworkManagerWeb/web/staffDashboard.jsp`

- [ ] **Step 1: Thêm CSS classes vào style block**

```css
.status-badge { padding: 3px 10px; border-radius: 999px; font-size: 11px; font-weight: 700; white-space: nowrap; }
.status-success { background: rgba(74,222,128,0.16); color: #4ade80; border: 1px solid rgba(74,222,128,0.3); }
.status-pending { background: rgba(251,191,36,0.16); color: #fbbf24; border: 1px solid rgba(251,191,36,0.3); }
.status-failed { background: rgba(239,68,68,0.16); color: #f87171; border: 1px solid rgba(239,68,68,0.3); }
```
