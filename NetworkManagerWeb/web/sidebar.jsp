<%-- sidebar.jsp - Shared sidebar for all staff pages --%>
<%@page import="Models_DAO.NetworkAlertDAO" %>
<c:set var="sa" value="${sidebarActive}" />
<% NetworkAlertDAO _alertDAO = new NetworkAlertDAO(); int _totalAlerts = _alertDAO.ListAll().size(); pageContext.setAttribute("_totalAlerts", _totalAlerts); %>
<nav class="sidebar">
    <div class="sidebar-brand">
        <div class="sidebar-brand-icon"><i class="bi bi-diagram-3-fill"></i></div>
        <div class="brand-title">Network<br>Manager</div>
    </div>

    <div class="sidebar-section-label">Overview</div>
    <a href="staffDashboard.jsp?page=dashboard" class="nav-item-link text-decoration-none ${sa eq 'dashboard' ? 'active' : ''}">
        <i class="bi bi-speedometer2"></i> Dashboard
    </a>

    <div class="sidebar-section-label">Infrastructure</div>
    <a href="staffDashboard.jsp?page=devices" class="nav-item-link text-decoration-none ${sa eq 'devices' ? 'active' : ''}">
        <i class="bi bi-laptop"></i> Network Devices
    </a>
    <a href="staffDashboard.jsp?page=accesspoints" class="nav-item-link text-decoration-none ${sa eq 'accesspoints' ? 'active' : ''}">
        <i class="bi bi-reception-4"></i> Access Points
    </a>
    <a href="staffDashboard.jsp?page=routers" class="nav-item-link text-decoration-none ${sa eq 'routers' ? 'active' : ''}">
        <i class="bi bi-router"></i> Routers
    </a>
    <a href="staffDashboard.jsp?page=switches" class="nav-item-link text-decoration-none ${sa eq 'switches' ? 'active' : ''}">
        <i class="bi bi-hdd-network"></i> Switches
    </a>
    <a href="staffDashboard.jsp?page=vlan" class="nav-item-link text-decoration-none ${sa eq 'vlan' ? 'active' : ''}">
        <i class="bi bi-diagram-3"></i> VLAN
    </a>
    <a href="staffDashboard.jsp?page=ipmanage" class="nav-item-link text-decoration-none ${sa eq 'ipmanage' ? 'active' : ''}">
        <i class="bi bi-globe"></i> IP Management
    </a>

    <div class="sidebar-section-label">Monitoring</div>
    <a href="staffDashboard.jsp?page=bandwidth" class="nav-item-link text-decoration-none ${sa eq 'bandwidth' ? 'active' : ''}">
        <i class="bi bi-bar-chart-line"></i> Bandwidth Usage
    </a>
    <a href="WifiController?action=list" class="nav-item-link text-decoration-none ${sa eq 'wifianalytics' ? 'active' : ''}">
        <i class="bi bi-graph-up"></i> WiFi Analytics
    </a>
    <a href="NetworkAlertController?action=list" class="nav-item-link text-decoration-none ${sa eq 'alerts' ? 'active' : ''}">
        <i class="bi bi-exclamation-triangle"></i> Network Alerts
        <span id="alertBadge" class="ms-auto" style="background:rgba(239,68,68,.25);color:#fda4af;border-radius:999px;padding:1px 7px;font-size:10px;font-weight:700;">${_totalAlerts gt 0 ? _totalAlerts : ''}</span>
    </a>

    <div class="sidebar-section-label">Management</div>
    <a href="staffDashboard.jsp?page=tickets" class="nav-item-link text-decoration-none ${sa eq 'tickets' ? 'active' : ''}">
        <i class="bi bi-ticket-perforated"></i> Support Tickets
    </a>
    <a href="staffDashboard.jsp?page=maintenance" class="nav-item-link text-decoration-none ${sa eq 'maintenance' ? 'active' : ''}">
        <i class="bi bi-tools"></i> Maintenance
    </a>
    <a href="staffDashboard.jsp?page=rooms" class="nav-item-link text-decoration-none ${sa eq 'rooms' ? 'active' : ''}">
        <i class="bi bi-building"></i> Rooms
    </a>

    <c:if test="${isAdmin}">
        <div class="sidebar-section-label">Administration</div>
        <a href="UserController?action=list" class="nav-item-link text-decoration-none ${sa eq 'users' ? 'active' : ''}">
            <i class="bi bi-people"></i> Manage Users
        </a>
        <a href="AuthLogController" class="nav-item-link text-decoration-none ${sa eq 'authlogs' ? 'active' : ''}">
            <i class="bi bi-shield-check"></i> Auth Logs
        </a>
        <a href="SystemLogController" class="nav-item-link text-decoration-none ${sa eq 'systemlogs' ? 'active' : ''}">
            <i class="bi bi-journal-text"></i> System Logs
        </a>
    </c:if>

    <div class="sidebar-footer">
        <div class="d-flex align-items-center gap-2 mb-2">
            <div class="user-avatar ${isAdmin ? 'admin-avatar' : 'tech-avatar'}">
                ${fn:substring(displayName, 0, 1)}
            </div>
            <div>
                <div style="font-size:13px;font-weight:600;color:#e8ecff;">${displayName}</div>
                <div style="font-size:11px;color:#8ea0cb;">${role}</div>
            </div>
        </div>
        <a href="LoginController?action=logout" class="nav-item-link text-danger text-decoration-none" style="padding-left:0;">
            <i class="bi bi-box-arrow-left"></i> Sign Out
        </a>
    </div>
</nav>
