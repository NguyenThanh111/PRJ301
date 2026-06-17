<%-- wifi-analytics.jsp – WiFi Analytics page served by WifiController --%>
    <%@page contentType="text/html" pageEncoding="UTF-8" %>
        <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
            <%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
                <%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
                    <c:set var="currentUser" value="${sessionScope.user}" />
                    <c:set var="role" value="${sessionScope.role}" />
                    <c:set var="roleLower" value="${fn:toLowerCase(role)}" />
                    <c:if
                        test="${empty currentUser || empty role || (roleLower ne 'admin' && roleLower ne 'technician')}">
                        <c:redirect url="login.jsp" />
                    </c:if>
                    <c:set var="displayName"
                        value="${empty currentUser.fullName ? currentUser.userName : currentUser.fullName}" />
                    <c:set var="isAdmin" value="${roleLower eq 'admin'}" />
                    <!DOCTYPE html>
                    <html lang="en">

                    <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>WiFi Analytics — Network Manager</title>
                        <meta name="description"
                            content="WiFi Analytics dashboard for monitoring access point performance, user sessions and throughput trends.">
                        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
                            rel="stylesheet">
                        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"
                            rel="stylesheet">
                        <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
                        <style>
                            /* ─── Design tokens (matches staffDashboard.jsp) ─── */
                            :root {
                                --bg-0: #05070d;
                                --bg-1: #0b1020;
                                --surface: #10172a;
                                --surface-2: #161f36;
                                --border: #2a3555;
                                --text-primary: #f2f5ff;
                                --text-muted: #9aa6c7;
                                --neon-purple: #8b5cf6;
                                --neon-pink: #d946ef;
                                --neon-blue: #60a5fa;
                                --neon-cyan: #22d3ee;
                                --neon-emerald: #34d399;
                                --neon-amber: #fbbf24;
                                --sidebar-w: 260px;
                                --radius-md: 10px;
                                --radius-lg: 14px;
                                --glow: 0 0 18px rgba(139, 92, 246, .22);
                            }

                            * {
                                box-sizing: border-box;
                                margin: 0;
                                padding: 0;
                            }

                            body {
                                background:
                                    linear-gradient(rgba(5, 8, 18, .88), rgba(6, 9, 20, .84)),
                                    radial-gradient(circle at 12% 12%, rgba(139, 92, 246, .16), transparent 28%),
                                    url('theme/original-d5209459af4999984ad44693bbcb28f7.webp') center/cover fixed no-repeat;
                                color: var(--text-primary);
                                min-height: 100vh;
                                font-family: "Segoe UI", Arial, sans-serif;
                            }

                            /* ─── Sidebar ─── */
                            .sidebar {
                                position: fixed;
                                inset: 0 auto 0 0;
                                width: var(--sidebar-w);
                                background: linear-gradient(180deg, rgba(16, 23, 42, .96), rgba(10, 14, 28, .98));
                                border-right: 1px solid var(--border);
                                display: flex;
                                flex-direction: column;
                                z-index: 100;
                                overflow-y: auto;
                            }

                            .sidebar-brand {
                                display: flex;
                                align-items: center;
                                gap: 10px;
                                padding: 16px 18px;
                                border-bottom: 1px solid var(--border);
                            }

                            .sidebar-brand-icon {
                                width: 38px;
                                height: 38px;
                                border-radius: 11px;
                                display: flex;
                                align-items: center;
                                justify-content: center;
                                color: white;
                                background: linear-gradient(135deg, var(--neon-purple), var(--neon-pink));
                                box-shadow: var(--glow);
                            }

                            .brand-title {
                                font-size: 13px;
                                font-weight: 700;
                                letter-spacing: .04em;
                                text-transform: uppercase;
                                color: #d8c9ff;
                                line-height: 1.1;
                            }

                            .sidebar-section-label {
                                font-size: 11px;
                                letter-spacing: .12em;
                                text-transform: uppercase;
                                color: #7f8db4;
                                padding: 14px 18px 6px;
                                font-weight: 600;
                            }

                            .nav-item-link {
                                border: none;
                                background: transparent;
                                width: 100%;
                                text-align: left;
                                color: #a5b2d8;
                                font-size: 14px;
                                padding: 10px 18px;
                                display: flex;
                                align-items: center;
                                gap: 10px;
                                cursor: pointer;
                                transition: .18s ease;
                                text-decoration: none;
                            }

                            .nav-item-link i {
                                width: 16px;
                                text-align: center;
                            }

                            .nav-item-link:hover {
                                background: rgba(139, 92, 246, .12);
                                color: #e5ddff;
                            }

                            .nav-item-link.active {
                                background: linear-gradient(90deg, rgba(139, 92, 246, .3), rgba(217, 70, 239, .08));
                                color: #f2ecff;
                                border-right: 3px solid var(--neon-purple);
                                font-weight: 600;
                            }

                            .sidebar-footer {
                                margin-top: auto;
                                padding: 14px 18px;
                                border-top: 1px solid var(--border);
                            }

                            .user-avatar {
                                width: 34px;
                                height: 34px;
                                border-radius: 50%;
                                display: flex;
                                align-items: center;
                                justify-content: center;
                                font-size: 14px;
                                color: white;
                                font-weight: 700;
                            }

                            .admin-avatar {
                                background: linear-gradient(135deg, #ef4444, #f97316);
                            }

                            .tech-avatar {
                                background: linear-gradient(135deg, #8b5cf6, #60a5fa);
                            }

                            /* ─── Layout ─── */
                            .main-content {
                                margin-left: var(--sidebar-w);
                                min-height: 100vh;
                            }

                            .topbar {
                                position: sticky;
                                top: 0;
                                z-index: 60;
                                padding: 14px 24px;
                                border-bottom: 1px solid var(--border);
                                background: rgba(12, 17, 32, .9);
                                backdrop-filter: blur(8px);
                                display: flex;
                                align-items: center;
                                justify-content: space-between;
                            }

                            .topbar-title {
                                font-size: 18px;
                                font-weight: 700;
                            }

                            .topbar-breadcrumb {
                                font-size: 12px;
                                color: var(--text-muted);
                                margin-left: 8px;
                            }

                            .role-badge-admin,
                            .role-badge-tech {
                                border-radius: 999px;
                                padding: 4px 10px;
                                font-size: 11px;
                                letter-spacing: .08em;
                                text-transform: uppercase;
                                font-weight: 700;
                            }

                            .role-badge-admin {
                                color: #fecaca;
                                background: rgba(239, 68, 68, .16);
                                border: 1px solid rgba(239, 68, 68, .4);
                            }

                            .role-badge-tech {
                                color: #ddd6fe;
                                background: rgba(139, 92, 246, .16);
                                border: 1px solid rgba(139, 92, 246, .4);
                            }

                            .page-body {
                                padding: 22px;
                            }

                            /* ─── Cards ─── */
                            .stat-card,
                            .section-card {
                                background: linear-gradient(180deg, rgba(20, 28, 48, .92), rgba(15, 21, 38, .95));
                                border: 1px solid var(--border);
                                border-radius: var(--radius-lg);
                            }

                            .stat-card {
                                padding: 18px;
                                transition: border-color .2s;
                            }

                            .stat-card:hover {
                                border-color: rgba(139, 92, 246, .55);
                            }

                            .stat-icon {
                                width: 44px;
                                height: 44px;
                                border-radius: 12px;
                                display: flex;
                                align-items: center;
                                justify-content: center;
                                margin-bottom: 12px;
                                font-size: 20px;
                            }

                            .stat-value {
                                font-size: 28px;
                                font-weight: 800;
                                line-height: 1;
                                margin-bottom: 4px;
                            }

                            .stat-label {
                                font-size: 12px;
                                color: var(--text-muted);
                            }

                            .stat-delta {
                                font-size: 11px;
                                margin-top: 6px;
                            }

                            .stat-delta.up {
                                color: var(--neon-emerald);
                            }

                            .stat-delta.down {
                                color: #f87171;
                            }

                            .section-card-header {
                                padding: 14px 18px;
                                border-bottom: 1px solid var(--border);
                                display: flex;
                                align-items: center;
                                justify-content: space-between;
                                flex-wrap: wrap;
                                gap: 8px;
                            }

                            .section-card-header h6 {
                                margin: 0;
                                font-size: 14px;
                                font-weight: 700;
                                color: #ebedff;
                            }

                            .section-card-body {
                                padding: 18px;
                            }

                            /* ─── AP filter tabs ─── */
                            .ap-tabs {
                                display: flex;
                                gap: 6px;
                                flex-wrap: wrap;
                                padding: 14px 18px;
                                border-bottom: 1px solid var(--border);
                            }

                            .ap-tab {
                                border: 1px solid var(--border);
                                background: rgba(22, 31, 54, .6);
                                color: var(--text-muted);
                                border-radius: 8px;
                                padding: 5px 13px;
                                font-size: 12px;
                                font-weight: 600;
                                cursor: pointer;
                                transition: .18s;
                                text-decoration: none;
                                display: inline-flex;
                                align-items: center;
                                gap: 6px;
                            }

                            .ap-tab:hover {
                                border-color: rgba(139, 92, 246, .5);
                                color: #e0d6ff;
                            }

                            .ap-tab.active {
                                background: rgba(139, 92, 246, .22);
                                border-color: rgba(139, 92, 246, .7);
                                color: #f0ebff;
                            }

                            /* ─── Analytics table ─── */
                            .rt-table {
                                width: 100%;
                                border-collapse: collapse;
                                font-size: .82rem;
                            }

                            .rt-table thead tr {
                                background: rgba(22, 31, 54, .95);
                                border-bottom: 1px solid var(--border);
                            }

                            .rt-table thead th {
                                padding: 11px 14px;
                                color: var(--text-muted);
                                font-weight: 600;
                                font-size: .7rem;
                                letter-spacing: .08em;
                                text-transform: uppercase;
                                white-space: nowrap;
                            }

                            .rt-table tbody tr {
                                border-bottom: 1px solid rgba(42, 53, 85, .35);
                                transition: background .15s;
                            }

                            .rt-table tbody tr:last-child {
                                border-bottom: none;
                            }

                            .rt-table tbody tr:hover {
                                background: rgba(139, 92, 246, .06);
                            }

                            .rt-table tbody td {
                                padding: 11px 14px;
                                color: var(--text-primary);
                                vertical-align: middle;
                            }

                            .rt-id {
                                display: inline-flex;
                                align-items: center;
                                justify-content: center;
                                background: rgba(96, 165, 250, .1);
                                border: 1px solid rgba(96, 165, 250, .22);
                                color: #60a5fa;
                                border-radius: 5px;
                                padding: 1px 8px;
                                font-size: .72rem;
                                font-weight: 700;
                                font-family: monospace;
                            }

                            .rt-ip {
                                font-family: 'Courier New', monospace;
                                font-size: .78rem;
                                color: #22d3ee;
                                background: rgba(34, 211, 238, .07);
                                border-radius: 4px;
                                padding: 1px 6px;
                                display: inline-block;
                            }

                            .rt-empty {
                                padding: 52px 24px;
                                text-align: center;
                                color: var(--text-muted);
                            }

                            .rt-empty i {
                                font-size: 44px;
                                color: var(--border);
                                display: block;
                                margin-bottom: 12px;
                            }

                            /* speed bar */
                            .speed-bar-wrap {
                                display: flex;
                                align-items: center;
                                gap: 8px;
                                min-width: 120px;
                            }

                            .speed-bar-bg {
                                flex: 1;
                                height: 6px;
                                background: rgba(42, 53, 85, .6);
                                border-radius: 3px;
                                overflow: hidden;
                            }

                            .speed-bar-fill {
                                height: 100%;
                                border-radius: 3px;
                                background: linear-gradient(90deg, #8b5cf6, #22d3ee);
                            }

                            .speed-val {
                                font-size: .78rem;
                                color: var(--neon-cyan);
                                font-weight: 700;
                                white-space: nowrap;
                            }

                            /* status dots */
                            .dot {
                                width: 8px;
                                height: 8px;
                                border-radius: 50%;
                                display: inline-block;
                                margin-right: 6px;
                            }

                            .dot-online {
                                background: #34d399;
                                box-shadow: 0 0 7px rgba(52, 211, 153, .7);
                            }

                            .dot-offline {
                                background: #f87171;
                                box-shadow: 0 0 7px rgba(248, 113, 113, .7);
                            }

                            .dot-maint {
                                background: #fbbf24;
                                box-shadow: 0 0 7px rgba(251, 191, 36, .7);
                            }

                            /* ─── Generate form ─── */
                            .gen-form-card {
                                background: rgba(139, 92, 246, .06);
                                border: 1px dashed rgba(139, 92, 246, .4);
                                border-radius: var(--radius-lg);
                                padding: 20px;
                            }

                            .form-label-custom {
                                font-size: 12px;
                                color: var(--text-muted);
                                font-weight: 600;
                                margin-bottom: 5px;
                            }

                            .form-ctrl {
                                background: rgba(16, 23, 42, .9);
                                border: 1px solid var(--border);
                                color: var(--text-primary);
                                border-radius: 8px;
                                padding: 8px 12px;
                                font-size: 13px;
                                width: 100%;
                                outline: none;
                                transition: border-color .2s;
                            }

                            .form-ctrl:focus {
                                border-color: var(--neon-purple);
                                box-shadow: 0 0 0 3px rgba(139, 92, 246, .18);
                            }

                            .form-ctrl option {
                                background: #0b1020;
                            }

                            .btn-theme {
                                border: 1px solid rgba(139, 92, 246, .5);
                                background: rgba(139, 92, 246, .2);
                                color: #e8ddff;
                                border-radius: 8px;
                                padding: 7px 14px;
                                font-size: 13px;
                                font-weight: 600;
                                cursor: pointer;
                                transition: all .18s;
                                display: inline-flex;
                                align-items: center;
                                gap: 6px;
                            }

                            .btn-theme:hover {
                                background: rgba(139, 92, 246, .35);
                                filter: brightness(1.1);
                            }

                            .btn-theme:active {
                                transform: scale(.98);
                            }

                            .btn-success-theme {
                                border: 1px solid rgba(52, 211, 153, .4);
                                background: rgba(52, 211, 153, .15);
                                color: #6ee7b7;
                                border-radius: 8px;
                                padding: 7px 16px;
                                font-size: 13px;
                                font-weight: 600;
                                cursor: pointer;
                                transition: all .18s;
                                display: inline-flex;
                                align-items: center;
                                gap: 6px;
                            }

                            .btn-success-theme:hover {
                                background: rgba(52, 211, 153, .28);
                            }

                            .btn-success-theme:active {
                                transform: scale(.98);
                            }

                            /* ─── Alert toasts ─── */
                            .toast-msg {
                                border-radius: 10px;
                                padding: 12px 18px;
                                font-size: 13px;
                                font-weight: 600;
                                display: flex;
                                align-items: center;
                                gap: 10px;
                                margin-bottom: 16px;
                            }

                            .toast-success {
                                background: rgba(52, 211, 153, .14);
                                border: 1px solid rgba(52, 211, 153, .4);
                                color: #6ee7b7;
                            }

                            .toast-error {
                                background: rgba(248, 113, 113, .12);
                                border: 1px solid rgba(248, 113, 113, .4);
                                color: #fca5a5;
                            }

                            /* ─── Chart container ─── */
                            .chart-wrap {
                                position: relative;
                                height: 240px;
                            }

                            /* ─── Pagination ─── */
                            .page-item .page-link {
                                background: rgba(22, 31, 54, .8);
                                border-color: var(--border);
                                color: var(--text-muted);
                                font-size: 13px;
                            }

                            .page-item.active .page-link {
                                background: rgba(139, 92, 246, .3);
                                border-color: rgba(139, 92, 246, .6);
                                color: #f0ebff;
                            }

                            .page-item .page-link:hover {
                                background: rgba(139, 92, 246, .18);
                                color: #e0d6ff;
                            }

                            @media (max-width: 900px) {
                                .sidebar {
                                    display: none;
                                }

                                .main-content {
                                    margin-left: 0;
                                }
                            }
                        </style>
                    </head>

                    <body>

                        <!-- ══════════════════════ SIDEBAR ══════════════════════ -->
                        <c:set var="sidebarActive" value="wifianalytics" scope="request" />
                        <%@include file="sidebar.jsp" %>

                        <!-- ══════════════════════ MAIN ══════════════════════ -->
                        <div class="main-content">

                            <!-- Top bar -->
                            <div class="topbar">
                                <div>
                                    <span class="topbar-title">WiFi Analytics</span>
                                    <span class="topbar-breadcrumb">/ Monitoring</span>
                                </div>
                                <div style="display:flex;align-items:center;gap:10px;">
                                    <span class="${isAdmin ? 'role-badge-admin' : 'role-badge-tech'}">${role}</span>
                                    <span style="font-size:13px;color:#9db0db;">Welcome, <strong
                                            style="color:#f2f5ff;">${displayName}</strong></span>
                                </div>
                            </div>

                            <div class="page-body">

                                <!-- Flash messages -->
                                <c:if test="${param.msg eq 'generated'}">
                                    <div class="toast-msg toast-success">
                                        <i class="bi bi-check-circle-fill"></i> Analytics record generated / updated
                                        successfully.
                                    </div>
                                </c:if>
                                <c:if test="${param.error eq 'generate_failed'}">
                                    <div class="toast-msg toast-error">
                                        <i class="bi bi-x-circle-fill"></i> Failed to generate analytics record. Please
                                        try again.
                                    </div>
                                </c:if>
                                <c:if test="${param.error eq 'missing_params'}">
                                    <div class="toast-msg toast-error">
                                        <i class="bi bi-exclamation-circle-fill"></i> Missing required parameters.
                                        Please fill all fields.
                                    </div>
                                </c:if>

                                <!-- ── KPI Row ── -->
                                <div class="row g-3 mb-3">
                                    <!-- Total Records -->
                                    <div class="col-6 col-lg-3">
                                        <div class="stat-card">
                                            <div class="stat-icon"
                                                style="background:rgba(139,92,246,.15);color:#8b5cf6;">
                                                <i class="bi bi-graph-up-arrow"></i>
                                            </div>
                                            <div class="stat-value" style="color:#c4b5fd;">
                                                <c:choose>
                                                    <c:when test="${not empty analyticsList}">
                                                        ${fn:length(analyticsList)}</c:when>
                                                    <c:otherwise>0</c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div class="stat-label">Total Records</div>
                                            <div class="stat-delta up"><i class="bi bi-arrow-up-short"></i> All time
                                            </div>
                                        </div>
                                    </div>
                                    <!-- Total APs -->
                                    <div class="col-6 col-lg-3">
                                        <div class="stat-card">
                                            <div class="stat-icon"
                                                style="background:rgba(34,211,238,.12);color:#22d3ee;">
                                                <i class="bi bi-reception-4"></i>
                                            </div>
                                            <div class="stat-value" style="color:#67e8f9;">
                                                <c:choose>
                                                    <c:when test="${not empty apList}">${fn:length(apList)}</c:when>
                                                    <c:otherwise>0</c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div class="stat-label">Access Points</div>
                                            <div class="stat-delta" style="color:var(--text-muted);">Tracked units</div>
                                        </div>
                                    </div>
                                    <!-- Avg Speed highlight -->
                                    <div class="col-6 col-lg-3">
                                        <div class="stat-card">
                                            <div class="stat-icon"
                                                style="background:rgba(52,211,153,.12);color:#34d399;">
                                                <i class="bi bi-speedometer"></i>
                                            </div>
                                            <div class="stat-value" style="color:#6ee7b7;" id="kpiAvgSpeed">—</div>
                                            <div class="stat-label">Avg Speed (Mbps) — Latest</div>
                                            <div class="stat-delta up" id="kpiSpeedDelta">Across all APs today</div>
                                        </div>
                                    </div>
                                    <!-- Peak users -->
                                    <div class="col-6 col-lg-3">
                                        <div class="stat-card">
                                            <div class="stat-icon"
                                                style="background:rgba(251,191,36,.12);color:#fbbf24;">
                                                <i class="bi bi-people-fill"></i>
                                            </div>
                                            <div class="stat-value" style="color:#fde68a;" id="kpiPeakUsers">—</div>
                                            <div class="stat-label">Peak Users — Latest</div>
                                            <div class="stat-delta up" id="kpiPeakDelta">Highest session</div>
                                        </div>
                                    </div>
                                </div>

                                <!-- ── Row: Chart + Generate Form ── -->
                                <div class="row g-3 mb-3">
                                    <!-- Trend chart -->
                                    <div class="col-lg-8">
                                        <div class="section-card h-100">
                                            <div class="section-card-header">
                                                <h6><i class="bi bi-activity me-2"
                                                        style="color:var(--neon-purple);"></i>Speed & User Trend</h6>
                                                <select class="form-ctrl" id="chartApFilter" style="width:180px;"
                                                    onchange="refreshChart()">
                                                    <option value="all">All Access Points</option>
                                                    <c:forEach var="ap" items="${apList}">
                                                        <option value="${ap.apId}">${ap.apName}</option>
                                                    </c:forEach>
                                                </select>
                                            </div>
                                            <div class="section-card-body">
                                                <div class="chart-wrap">
                                                    <canvas id="wifiTrendChart"></canvas>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <!-- Generate Daily Analytics Form -->
                                    <div class="col-lg-4">
                                        <div class="section-card h-100">
                                            <div class="section-card-header">
                                                <h6><i class="bi bi-plus-circle me-2"
                                                        style="color:var(--neon-emerald);"></i>Record Daily Data</h6>
                                            </div>
                                            <div class="section-card-body">
                                                <form action="WifiController" method="post" class="gen-form-card">
                                                    <input type="hidden" name="action" value="generate">
                                                    <div class="mb-3">
                                                        <div class="form-label-custom">Access Point</div>
                                                        <select name="apId" id="genApId" class="form-ctrl" required>
                                                            <option value="" disabled selected>— Select AP —</option>
                                                            <c:forEach var="ap" items="${apList}">
                                                                <option value="${ap.apId}">${ap.apName} (${ap.ssid})
                                                                </option>
                                                            </c:forEach>
                                                        </select>
                                                    </div>
                                                    <div class="mb-3">
                                                        <div class="form-label-custom">Total Users</div>
                                                        <input type="number" name="totalUsers" class="form-ctrl" min="0"
                                                            max="10000" placeholder="e.g. 350" required>
                                                    </div>
                                                    <div class="mb-3">
                                                        <div class="form-label-custom">Peak Concurrent Users</div>
                                                        <input type="number" name="peakUsers" class="form-ctrl" min="0"
                                                            max="10000" placeholder="e.g. 80" required>
                                                    </div>
                                                    <div class="mb-3">
                                                        <div class="form-label-custom">Average Speed (Mbps)</div>
                                                        <input type="number" name="avgSpeed" class="form-ctrl"
                                                            step="0.01" min="0" placeholder="e.g. 45.5" required>
                                                    </div>
                                                    <button type="submit" class="btn-success-theme w-100">
                                                        <i class="bi bi-save2"></i> Save / Update Today's Record
                                                    </button>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- ── Monthly Report Filter ── -->
                                <div class="section-card mb-3">
                                    <div class="section-card-header">
                                        <h6><i class="bi bi-calendar-month me-2"
                                                style="color:var(--neon-blue);"></i>Monthly Report</h6>
                                        <form action="WifiController" method="get"
                                            style="display:flex;gap:8px;align-items:center;flex-wrap:wrap;">
                                            <input type="hidden" name="action" value="monthly">
                                            <select name="apId" class="form-ctrl" style="width:160px;" required>
                                                <option value="" disabled selected>AP</option>
                                                <c:forEach var="ap" items="${apList}">
                                                    <option value="${ap.apId}" <c:if
                                                        test="${selectedAP != null && selectedAP.apId == ap.apId}">
                                                        selected</c:if>>
                                                        ${ap.apName}
                                                    </option>
                                                </c:forEach>
                                            </select>
                                            <input type="number" name="year" class="form-ctrl" style="width:90px;"
                                                min="2020" max="2030" placeholder="Year" required
                                                value="${not empty reportYear ? reportYear : ''}">
                                            <input type="number" name="month" class="form-ctrl" style="width:75px;"
                                                min="1" max="12" placeholder="Mo." required
                                                value="${not empty reportMonth ? reportMonth : ''}">
                                            <button type="submit" class="btn-theme">
                                                <i class="bi bi-search"></i> View
                                            </button>
                                            <c:if test="${not empty monthlyData}">
                                                <a href="WifiController?action=list" class="btn-theme">
                                                    <i class="bi bi-x"></i> Clear
                                                </a>
                                            </c:if>
                                        </form>
                                    </div>
                                    <c:if test="${not empty monthlyData}">
                                        <div style="padding:10px 18px;font-size:13px;color:var(--text-muted);">
                                            Showing
                                            <strong
                                                style="color:var(--text-primary);">${fn:length(monthlyData)}</strong>
                                            records for
                                            <strong style="color:#c4b5fd;">${selectedAP.apName}</strong>
                                            —
                                            <fmt:formatNumber value="${reportMonth}" minIntegerDigits="2" />
                                            /${reportYear}
                                        </div>
                                    </c:if>
                                </div>

                                <!-- ── AP Filter Tabs ── -->
                                <div class="section-card mb-0"
                                    style="border-bottom-left-radius:0;border-bottom-right-radius:0;border-bottom:none;">
                                    <div class="ap-tabs">
                                        <a href="WifiController?action=list"
                                            class="ap-tab ${empty param.apId && param.action ne 'apAnalytics' ? 'active' : ''}">
                                            <i class="bi bi-grid-3x3-gap"></i> All APs
                                        </a>
                                        <c:forEach var="ap" items="${apList}">
                                            <a href="WifiController?action=apAnalytics&apId=${ap.apId}"
                                                class="ap-tab ${selectedAP != null && selectedAP.apId == ap.apId ? 'active' : ''}">
                                                <span
                                                    class="dot ${ap.status eq 'ONLINE' ? 'dot-online' : (ap.status eq 'OFFLINE' ? 'dot-offline' : 'dot-maint')}"></span>
                                                ${ap.apName}
                                            </a>
                                        </c:forEach>
                                    </div>
                                </div>

                                <!-- ── Analytics Table ── -->
                                <div class="section-card" style="border-top-left-radius:0;border-top-right-radius:0;">
                                    <div class="section-card-header">
                                        <h6>
                                            <i class="bi bi-table me-2"></i>
                                            <c:choose>
                                                <c:when test="${not empty monthlyData}">
                                                    Monthly Report — ${selectedAP.apName}
                                                </c:when>
                                                <c:when test="${selectedAP != null}">
                                                    Analytics for: <span
                                                        style="color:var(--neon-purple);">${selectedAP.apName}</span>
                                                    <span
                                                        style="font-size:11px;color:var(--text-muted);margin-left:6px;">(${selectedAP.ssid})</span>
                                                </c:when>
                                                <c:otherwise>All Analytics Records</c:otherwise>
                                            </c:choose>
                                        </h6>
                                        <div style="display:flex;gap:8px;align-items:center;">
                                            <c:if test="${selectedAP != null}">
                                                <span class="rt-ip">${selectedAP.ipAddress}</span>
                                                <span
                                                    class="dot ${selectedAP.status eq 'ONLINE' ? 'dot-online' : (selectedAP.status eq 'OFFLINE' ? 'dot-offline' : 'dot-maint')}"></span>
                                                <span
                                                    style="font-size:12px;color:var(--text-muted);">${selectedAP.status}</span>
                                            </c:if>
                                            <span style="font-size:12px;color:var(--text-muted);">
                                                <c:choose>
                                                    <c:when test="${not empty monthlyData}">${fn:length(monthlyData)}
                                                        records</c:when>
                                                    <c:when test="${not empty analyticsList}">
                                                        ${fn:length(analyticsList)} records</c:when>
                                                    <c:otherwise>0 records</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </div>
                                    </div>
                                    <div style="overflow-x:auto;">
                                        <table class="rt-table">
                                            <thead>
                                                <tr>
                                                    <th><i class="bi bi-hash me-1"></i>ID</th>
                                                    <th><i class="bi bi-reception-4 me-1"></i>AP ID</th>
                                                    <th><i class="bi bi-calendar-date me-1"></i>Date</th>
                                                    <th><i class="bi bi-people me-1"></i>Total Users</th>
                                                    <th><i class="bi bi-person-lines-fill me-1"></i>Peak Users</th>
                                                    <th><i class="bi bi-speedometer me-1"></i>Avg Speed</th>
                                                    <th><i class="bi bi-bar-chart me-1"></i>Load %</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <%-- Determine which list to display --%>
                                                    <c:set var="displayList"
                                                        value="${not empty monthlyData ? monthlyData : analyticsList}" />
                                                    <c:choose>
                                                        <c:when test="${not empty displayList}">
                                                            <c:forEach var="rec" items="${displayList}">
                                                                <tr>
                                                                    <td><span class="rt-id">#${rec.analyticsId}</span>
                                                                    </td>
                                                                    <td>
                                                                        <a href="WifiController?action=apAnalytics&apId=${rec.apId}"
                                                                            style="color:var(--neon-purple);text-decoration:none;font-weight:600;font-size:.82rem;">
                                                                            <i
                                                                                class="bi bi-reception-4 me-1"></i>AP-${rec.apId}
                                                                        </a>
                                                                    </td>
                                                                    <td
                                                                        style="font-family:'Courier New',monospace;color:#93c5fd;font-size:.8rem;">
                                                                        ${rec.analyticsDate}</td>
                                                                    <td>
                                                                        <span
                                                                            style="font-weight:700;color:var(--text-primary);">${rec.totalUsers}</span>
                                                                        <span
                                                                            style="font-size:.72rem;color:var(--text-muted);">
                                                                            users</span>
                                                                    </td>
                                                                    <td>
                                                                        <span
                                                                            style="font-weight:700;color:#fde68a;">${rec.peakUsers}</span>
                                                                        <span
                                                                            style="font-size:.72rem;color:var(--text-muted);">
                                                                            peak</span>
                                                                    </td>
                                                                    <td>
                                                                        <div class="speed-bar-wrap">
                                                                            <div class="speed-bar-bg">
                                                                                <%-- width capped at 100 Mbps for
                                                                                    visualization --%>
                                                                                    <div class="speed-bar-fill"
                                                                                        style="width:${rec.avgSpeed > 100 ? 100 : rec.avgSpeed}%">
                                                                                    </div>
                                                                            </div>
                                                                            <span class="speed-val">
                                                                                <fmt:formatNumber
                                                                                    value="${rec.avgSpeed}"
                                                                                    maxFractionDigits="1" /> Mbps
                                                                            </span>
                                                                        </div>
                                                                    </td>
                                                                    <td>
                                                                        <%-- Load=peakUsers / 256 * 100 (assuming 256
                                                                            max clients per AP) --%>
                                                                            <c:set var="loadPct"
                                                                                value="${rec.peakUsers > 256 ? 100 : (rec.peakUsers * 100 / 256)}" />
                                                                            <div class="speed-bar-wrap">
                                                                                <div class="speed-bar-bg">
                                                                                    <div style="height:100%;border-radius:3px;
                                                        background:${loadPct > 75 ? '#ef4444' : (loadPct > 50 ? '#fbbf24' : '#34d399')};
                                                        width:${loadPct}%;"></div>
                                                                                </div>
                                                                                <span
                                                                                    style="font-size:.78rem;font-weight:700;
                                                    color:${loadPct > 75 ? '#f87171' : (loadPct > 50 ? '#fde68a' : '#6ee7b7')};">
                                                                                    <fmt:formatNumber value="${loadPct}"
                                                                                        maxFractionDigits="0" />%
                                                                                </span>
                                                                            </div>
                                                                    </td>
                                                                </tr>
                                                            </c:forEach>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <tr>
                                                                <td colspan="7">
                                                                    <div class="rt-empty">
                                                                        <i class="bi bi-graph-up"></i>
                                                                        No analytics records found.
                                                                        <span
                                                                            style="display:block;margin-top:6px;font-size:12px;">
                                                                            Use the "Record Daily Data" form to add your
                                                                            first entry.
                                                                        </span>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                        </c:otherwise>
                                                    </c:choose>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                                <!-- end analytics table -->

                            </div><!-- /.page-body -->
                        </div><!-- /.main-content -->

                        <!-- ══════════════════════ SCRIPTS ══════════════════════ -->
                        <script>
                            /* ── Embed analytics data from server for chart ── */
                            const rawData = [
                                <c:forEach var="rec" items="${analyticsList}" varStatus="st">
                                    {
                                        id:          ${rec.analyticsId},
                                    apId:        ${rec.apId},
                                    date:        '${rec.analyticsDate}',
                                    totalUsers:  ${rec.totalUsers},
                                    peakUsers:   ${rec.peakUsers},
                                    avgSpeed:    ${rec.avgSpeed}
    }<c:if test="${!st.last}">,</c:if>
                                </c:forEach>
                            ];

                            /* KPI compute */
                            (function () {
                                if (!rawData.length) return;
                                // Sort ascending by date for chart
                                rawData.sort((a, b) => a.date.localeCompare(b.date));
                                // Latest record
                                const latest = rawData[rawData.length - 1];
                                const kpiSpeed = document.getElementById('kpiAvgSpeed');
                                const kpiPeak = document.getElementById('kpiPeakUsers');
                                if (kpiSpeed) kpiSpeed.textContent = latest.avgSpeed.toFixed(1);
                                if (kpiPeak) kpiPeak.textContent = latest.peakUsers;
                            })();

                            /* ── Chart.js trend ── */
                            let trendChart = null;

                            function buildChartData(apFilter) {
                                let filtered = apFilter === 'all'
                                    ? rawData
                                    : rawData.filter(r => r.apId == apFilter);
                                filtered = filtered.slice(-30); // last 30 points

                                const labels = filtered.map(r => r.date);
                                const speed = filtered.map(r => r.avgSpeed);
                                const users = filtered.map(r => r.totalUsers);
                                const peak = filtered.map(r => r.peakUsers);
                                return { labels, speed, users, peak };
                            }

                            function refreshChart() {
                                const apFilter = document.getElementById('chartApFilter').value;
                                const { labels, speed, users, peak } = buildChartData(apFilter);

                                if (trendChart) {
                                    trendChart.data.labels = labels;
                                    trendChart.data.datasets[0].data = speed;
                                    trendChart.data.datasets[1].data = users;
                                    trendChart.data.datasets[2].data = peak;
                                    trendChart.update();
                                    return;
                                }

                                const ctx = document.getElementById('wifiTrendChart').getContext('2d');
                                trendChart = new Chart(ctx, {
                                    type: 'line',
                                    data: {
                                        labels,
                                        datasets: [
                                            {
                                                label: 'Avg Speed (Mbps)',
                                                data: speed,
                                                borderColor: '#8b5cf6',
                                                backgroundColor: 'rgba(139,92,246,.08)',
                                                tension: 0.38, fill: true, pointRadius: 3,
                                                borderWidth: 2, yAxisID: 'ySpeed'
                                            },
                                            {
                                                label: 'Total Users',
                                                data: users,
                                                borderColor: '#22d3ee',
                                                backgroundColor: 'transparent',
                                                tension: 0.38, fill: false, pointRadius: 3,
                                                borderWidth: 2, borderDash: [4, 3], yAxisID: 'yUsers'
                                            },
                                            {
                                                label: 'Peak Users',
                                                data: peak,
                                                borderColor: '#fbbf24',
                                                backgroundColor: 'transparent',
                                                tension: 0.38, fill: false, pointRadius: 3,
                                                borderWidth: 1.5, borderDash: [2, 4], yAxisID: 'yUsers'
                                            }
                                        ]
                                    },
                                    options: {
                                        responsive: true, maintainAspectRatio: false,
                                        interaction: { mode: 'index', intersect: false },
                                        plugins: {
                                            legend: {
                                                labels: { color: '#9aa6c7', font: { size: 11 }, boxWidth: 14 }
                                            },
                                            tooltip: {
                                                backgroundColor: 'rgba(10,14,28,.95)',
                                                borderColor: '#2a3555', borderWidth: 1,
                                                titleColor: '#f2f5ff', bodyColor: '#9aa6c7',
                                                padding: 10
                                            }
                                        },
                                        scales: {
                                            x: {
                                                ticks: { color: '#7f8db4', font: { size: 10 }, maxRotation: 40 },
                                                grid: { color: 'rgba(42,53,85,.3)' }
                                            },
                                            ySpeed: {
                                                type: 'linear', position: 'left',
                                                ticks: { color: '#8b5cf6', font: { size: 10 } },
                                                grid: { color: 'rgba(42,53,85,.25)' },
                                                title: { display: true, text: 'Mbps', color: '#8b5cf6', font: { size: 10 } }
                                            },
                                            yUsers: {
                                                type: 'linear', position: 'right',
                                                ticks: { color: '#22d3ee', font: { size: 10 } },
                                                grid: { drawOnChartArea: false },
                                                title: { display: true, text: 'Users', color: '#22d3ee', font: { size: 10 } }
                                            }
                                        }
                                    }
                                });
                            }

                            document.addEventListener('DOMContentLoaded', () => {
                                refreshChart();

                                // Pre-select AP in chart if viewing AP analytics
                                <c:if test="${selectedAP != null}">
                                    const sel = document.getElementById('chartApFilter');
                                    if (sel) sel.value = '${selectedAP.apId}';
                                    refreshChart();
                                </c:if>
                            });
                        </script>
                    </body>

                    </html>