<%-- network-alerts.jsp – Network Alerts page served by NetworkAlertController --%>
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
                        <title>Network Alerts — Network Manager</title>
                        <meta name="description"
                            content="Network Alerts dashboard for monitoring, filtering and resolving infrastructure incidents.">
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
                                --sev-critical: #ef4444;
                                --sev-warning: #f59e0b;
                                --sev-info: #60a5fa;
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
                                color: #9fb0d9;
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

                            /* ─── Severity filter tabs ─── */
                            .sev-tabs {
                                display: flex;
                                gap: 6px;
                                flex-wrap: wrap;
                                padding: 14px 18px;
                                border-bottom: 1px solid var(--border);
                            }

                            .sev-tab {
                                border-radius: 8px;
                                padding: 5px 14px;
                                font-size: 12px;
                                font-weight: 700;
                                cursor: pointer;
                                transition: .18s;
                                text-decoration: none;
                                display: inline-flex;
                                align-items: center;
                                gap: 7px;
                                border: 1px solid var(--border);
                                background: rgba(22, 31, 54, .6);
                                color: var(--text-muted);
                            }

                            .sev-tab:hover {
                                color: #e5ddff;
                                filter: brightness(1.1);
                            }

                            .sev-tab.tab-all.active {
                                background: rgba(139, 92, 246, .25);
                                border-color: rgba(139, 92, 246, .6);
                                color: #f0ebff;
                            }

                            .sev-tab.tab-critical.active {
                                background: rgba(239, 68, 68, .2);
                                border-color: rgba(239, 68, 68, .6);
                                color: #fecaca;
                            }

                            .sev-tab.tab-warning.active {
                                background: rgba(245, 158, 11, .18);
                                border-color: rgba(245, 158, 11, .6);
                                color: #fde68a;
                            }

                            .sev-tab.tab-info.active {
                                background: rgba(96, 165, 250, .18);
                                border-color: rgba(96, 165, 250, .6);
                                color: #bae6fd;
                            }

                            .sev-count {
                                display: inline-flex;
                                align-items: center;
                                justify-content: center;
                                min-width: 18px;
                                height: 18px;
                                border-radius: 9px;
                                font-size: 10px;
                                padding: 0 5px;
                            }

                            .sev-count-all {
                                background: rgba(139, 92, 246, .3);
                                color: #e0d6ff;
                            }

                            .sev-count-critical {
                                background: rgba(239, 68, 68, .35);
                                color: #fecaca;
                            }

                            .sev-count-warning {
                                background: rgba(245, 158, 11, .3);
                                color: #fde68a;
                            }

                            .sev-count-info {
                                background: rgba(96, 165, 250, .3);
                                color: #bae6fd;
                            }

                            /* ─── Alert table ─── */
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

                            /* ─── Severity badges ─── */
                            .sev-badge {
                                display: inline-flex;
                                align-items: center;
                                gap: 5px;
                                border-radius: 6px;
                                padding: 3px 9px;
                                font-size: .72rem;
                                font-weight: 700;
                                text-transform: uppercase;
                                letter-spacing: .06em;
                            }

                            .sev-critical {
                                background: rgba(239, 68, 68, .18);
                                border: 1px solid rgba(239, 68, 68, .45);
                                color: #fca5a5;
                            }

                            .sev-warning {
                                background: rgba(245, 158, 11, .15);
                                border: 1px solid rgba(245, 158, 11, .45);
                                color: #fde68a;
                            }

                            .sev-info {
                                background: rgba(96, 165, 250, .14);
                                border: 1px solid rgba(96, 165, 250, .4);
                                color: #bae6fd;
                            }

                            .dot {
                                width: 8px;
                                height: 8px;
                                border-radius: 50%;
                                display: inline-block;
                            }

                            .dot-critical {
                                background: #ef4444;
                                box-shadow: 0 0 8px rgba(239, 68, 68, .8);
                                animation: pulse-red 2s infinite;
                            }

                            .dot-warning {
                                background: #f59e0b;
                                box-shadow: 0 0 8px rgba(245, 158, 11, .7);
                                animation: pulse-amber 2s infinite;
                            }

                            .dot-info {
                                background: #60a5fa;
                                box-shadow: 0 0 8px rgba(96, 165, 250, .6);
                            }

                            @keyframes pulse-red {

                                0%,
                                100% {
                                    opacity: 1
                                }

                                50% {
                                    opacity: .5
                                }
                            }

                            @keyframes pulse-amber {

                                0%,
                                100% {
                                    opacity: 1
                                }

                                50% {
                                    opacity: .6
                                }
                            }

                            /* ─── Type badge ─── */
                            .type-badge {
                                display: inline-flex;
                                align-items: center;
                                gap: 5px;
                                background: rgba(139, 92, 246, .1);
                                border: 1px solid rgba(139, 92, 246, .28);
                                color: #c4b5fd;
                                border-radius: 6px;
                                padding: 2px 8px;
                                font-size: .72rem;
                                font-weight: 600;
                            }

                            /* ─── Device badge ─── */
                            .dev-badge {
                                display: inline-flex;
                                align-items: center;
                                gap: 4px;
                                font-size: .72rem;
                                font-weight: 600;
                                color: var(--neon-cyan);
                                background: rgba(34, 211, 238, .07);
                                border: 1px solid rgba(34, 211, 238, .2);
                                border-radius: 5px;
                                padding: 1px 7px;
                            }

                            /* ─── Action buttons ─── */
                            .rt-actions {
                                display: flex;
                                gap: 5px;
                                align-items: center;
                            }

                            .rt-btn {
                                display: inline-flex;
                                align-items: center;
                                justify-content: center;
                                padding: 5px 10px;
                                border-radius: 7px;
                                border: 1px solid transparent;
                                font-size: 12px;
                                font-weight: 600;
                                cursor: pointer;
                                transition: all .18s;
                                text-decoration: none;
                                gap: 4px;
                            }

                            .rt-btn-resolve {
                                border-color: rgba(52, 211, 153, .35);
                                color: #6ee7b7;
                                background: rgba(52, 211, 153, .1);
                            }

                            .rt-btn-resolve:hover {
                                background: rgba(52, 211, 153, .24);
                                box-shadow: 0 0 8px rgba(52, 211, 153, .3);
                                color: #6ee7b7;
                            }

                            .rt-btn-resolve:active {
                                transform: scale(.97);
                            }

                            /* ─── Create Alert Form ─── */
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

                            .form-label-custom {
                                font-size: 12px;
                                color: var(--text-muted);
                                font-weight: 600;
                                margin-bottom: 5px;
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

                            .btn-danger-theme {
                                border: 1px solid rgba(239, 68, 68, .4);
                                background: rgba(239, 68, 68, .15);
                                color: #fca5a5;
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

                            .btn-danger-theme:hover {
                                background: rgba(239, 68, 68, .28);
                            }

                            .btn-danger-theme:active {
                                transform: scale(.98);
                            }

                            .create-form-wrap {
                                background: rgba(139, 92, 246, .05);
                                border: 1px dashed rgba(139, 92, 246, .35);
                                border-radius: var(--radius-lg);
                                padding: 20px;
                            }

                            /* ─── Flash toasts ─── */
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

                            .toast-info {
                                background: rgba(96, 165, 250, .12);
                                border: 1px solid rgba(96, 165, 250, .4);
                                color: #bae6fd;
                            }

                            /* ─── Chart ─── */
                            .chart-wrap {
                                position: relative;
                                height: 220px;
                            }

                            /* ─── Confirm modal ─── */
                            .confirm-overlay {
                                position: fixed;
                                inset: 0;
                                background: rgba(5, 7, 13, .7);
                                backdrop-filter: blur(4px);
                                z-index: 900;
                                display: flex;
                                align-items: center;
                                justify-content: center;
                                opacity: 0;
                                pointer-events: none;
                                transition: opacity .2s;
                            }

                            .confirm-overlay.show {
                                opacity: 1;
                                pointer-events: all;
                            }

                            .confirm-box {
                                background: linear-gradient(180deg, #10172a, #0b1020);
                                border: 1px solid var(--border);
                                border-radius: var(--radius-lg);
                                padding: 28px 32px;
                                max-width: 400px;
                                width: 90%;
                                text-align: center;
                            }

                            .confirm-icon {
                                font-size: 40px;
                                margin-bottom: 12px;
                                color: #fca5a5;
                            }

                            .confirm-title {
                                font-size: 17px;
                                font-weight: 700;
                                margin-bottom: 8px;
                            }

                            .confirm-body {
                                font-size: 13px;
                                color: var(--text-muted);
                                margin-bottom: 22px;
                            }

                            .confirm-btns {
                                display: flex;
                                gap: 10px;
                                justify-content: center;
                            }

                            @media (max-width: 900px) {
                                .sidebar {
                                    display: none;
                                }

                                .main-content {
                                    margin-left: 0;
                                }
                            }
                        .pagination-controls { display: flex; align-items: center; gap: 8px; }
                        .pagination-controls .page-btn { width: 32px; height: 32px; border-radius: 8px; border: 1px solid var(--border); background: rgba(139, 92, 246, 0.15); color: #e8ddff; display: flex; align-items: center; justify-content: center; cursor: pointer; transition: 0.15s ease; font-size: 14px; }
                        .pagination-controls .page-btn:hover { background: rgba(139, 92, 246, 0.3); border-color: rgba(139, 92, 246, 0.6); }
                        .pagination-controls .page-btn:disabled { opacity: 0.35; cursor: not-allowed; }
                        .pagination-controls .page-info { font-size: 12px; color: var(--text-muted); min-width: 70px; text-align: center; }
                        </style>
                    </head>

                    <body>

                        <!-- ══════════════════════ SIDEBAR ══════════════════════ -->
                        <c:set var="sidebarActive" value="alerts" scope="request" />
                        <%@include file="sidebar.jsp" %>

                        <!-- ══════════════════════ MAIN ══════════════════════ -->
                        <div class="main-content">

                            <!-- Top bar -->
                            <div class="topbar">
                                <div>
                                    <span class="topbar-title">Network Alerts</span>
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
                                <c:if test="${param.msg eq 'resolved'}">
                                    <div class="toast-msg toast-success">
                                        <i class="bi bi-check-circle-fill"></i> Alert resolved and removed successfully.
                                    </div>
                                </c:if>
                                <c:if test="${param.msg eq 'created'}">
                                    <div class="toast-msg toast-info">
                                        <i class="bi bi-info-circle-fill"></i> New alert created successfully.
                                    </div>
                                </c:if>
                                <c:if test="${param.error eq 'resolve_failed'}">
                                    <div class="toast-msg toast-error">
                                        <i class="bi bi-x-circle-fill"></i> Failed to resolve the alert. Please try
                                        again.
                                    </div>
                                </c:if>
                                <c:if test="${param.error eq 'create_failed'}">
                                    <div class="toast-msg toast-error">
                                        <i class="bi bi-x-circle-fill"></i> Failed to create the alert. Please check
                                        your input.
                                    </div>
                                </c:if>
                                <c:if test="${param.error eq 'missing_fields'}">
                                    <div class="toast-msg toast-error">
                                        <i class="bi bi-exclamation-circle-fill"></i> Missing required fields. Fill
                                        Alert Type, Message and Severity.
                                    </div>
                                </c:if>
                                <c:if test="${param.error eq 'missing_id'}">
                                    <div class="toast-msg toast-error">
                                        <i class="bi bi-exclamation-circle-fill"></i> Alert ID is missing. Please try
                                        again.
                                    </div>
                                </c:if>

                                <!-- ── Compute counts client-side; also build JSTL sets for KPI ── -->
                                <c:set var="totalAlerts" value="${fn:length(alerts)}" />
                                <c:set var="critCount" value="0" />
                                <c:set var="warnCount" value="0" />
                                <c:set var="infoCount" value="0" />
                                <c:forEach var="a" items="${alerts}">
                                    <c:if test="${fn:toUpperCase(a.severity) eq 'CRITICAL'}">
                                        <c:set var="critCount" value="${critCount + 1}" />
                                    </c:if>
                                    <c:if test="${fn:toUpperCase(a.severity) eq 'WARNING'}">
                                        <c:set var="warnCount" value="${warnCount + 1}" />
                                    </c:if>
                                    <c:if test="${fn:toUpperCase(a.severity) eq 'INFO'}">
                                        <c:set var="infoCount" value="${infoCount + 1}" />
                                    </c:if>
                                </c:forEach>

                                <!-- ── KPI Row ── -->
                                <div class="row g-3 mb-3">
                                    <div class="col-6 col-lg-3">
                                        <div class="stat-card">
                                            <div class="stat-icon"
                                                style="background:rgba(139,92,246,.15);color:#8b5cf6;">
                                                <i class="bi bi-bell-fill"></i>
                                            </div>
                                            <div class="stat-value" style="color:#c4b5fd;">${totalAlerts}</div>
                                            <div class="stat-label">Total Alerts</div>
                                            <div class="stat-delta"><span
                                                    style="color:var(--neon-cyan);">${severityFilter eq 'ALL' ? 'All
                                                    severity levels' : 'Filtered by: '.concat(severityFilter)}</span>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-6 col-lg-3">
                                        <div class="stat-card">
                                            <div class="stat-icon"
                                                style="background:rgba(239,68,68,.15);color:#ef4444;">
                                                <i class="bi bi-fire"></i>
                                            </div>
                                            <div class="stat-value" style="color:#f87171;">${critCount}</div>
                                            <div class="stat-label">Critical</div>
                                            <div class="stat-delta" style="color:#fca5a5;">Immediate attention required
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-6 col-lg-3">
                                        <div class="stat-card">
                                            <div class="stat-icon"
                                                style="background:rgba(245,158,11,.15);color:#f59e0b;">
                                                <i class="bi bi-exclamation-triangle-fill"></i>
                                            </div>
                                            <div class="stat-value" style="color:#fde68a;">${warnCount}</div>
                                            <div class="stat-label">Warnings</div>
                                            <div class="stat-delta" style="color:#fde68a;">Should be reviewed soon</div>
                                        </div>
                                    </div>
                                    <div class="col-6 col-lg-3">
                                        <div class="stat-card">
                                            <div class="stat-icon"
                                                style="background:rgba(96,165,250,.15);color:#60a5fa;">
                                                <i class="bi bi-info-circle-fill"></i>
                                            </div>
                                            <div class="stat-value" style="color:#bae6fd;">${infoCount}</div>
                                            <div class="stat-label">Informational</div>
                                            <div class="stat-delta" style="color:#bae6fd;">Non-critical notices</div>
                                        </div>
                                    </div>
                                </div>

                                <!-- ── Row: Severity Donut + Create Alert ── -->
                                <div class="row g-3 mb-3">
                                    <!-- Donut chart -->
                                    <div class="col-lg-4">
                                        <div class="section-card h-100">
                                            <div class="section-card-header">
                                                <h6><i class="bi bi-pie-chart-fill me-2"
                                                        style="color:var(--neon-purple);"></i>Severity Distribution</h6>
                                            </div>
                                            <div class="section-card-body"
                                                style="display:flex;align-items:center;justify-content:center;">
                                                <div class="chart-wrap" style="width:100%;">
                                                    <canvas id="severityChart"></canvas>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <!-- Create Alert Form -->
                                    <div class="col-lg-8">
                                        <div class="section-card h-100">
                                            <div class="section-card-header">
                                                <h6><i class="bi bi-plus-circle me-2"
                                                        style="color:var(--neon-emerald);"></i>Create New Alert</h6>
                                                <span style="font-size:11px;color:var(--text-muted);">Manual alert entry
                                                    for admin review</span>
                                            </div>
                                            <div class="section-card-body">
                                                <form action="NetworkAlertController" method="post"
                                                    class="create-form-wrap">
                                                    <input type="hidden" name="action" value="create">
                                                    <div class="row g-3">
                                                        <div class="col-md-4">
                                                            <div class="form-label-custom">Alert Type <span
                                                                    style="color:#f87171;">*</span></div>
                                                            <input type="text" name="alertType" class="form-ctrl"
                                                                placeholder="e.g. DOWNTIME, HIGH_LOAD" required
                                                                maxlength="100">
                                                        </div>
                                                        <div class="col-md-4">
                                                            <div class="form-label-custom">Severity <span
                                                                    style="color:#f87171;">*</span></div>
                                                            <select name="severity" class="form-ctrl" required>
                                                                <option value="" disabled selected>— Select —</option>
                                                                <option value="CRITICAL">CRITICAL</option>
                                                                <option value="WARNING">WARNING</option>
                                                                <option value="INFO">INFO</option>
                                                            </select>
                                                        </div>
                                                        <div class="col-md-4">
                                                            <div class="form-label-custom">Linked Device (optional)
                                                            </div>
                                                            <select name="routerId" class="form-ctrl" id="routerSel">
                                                                <option value="">No Router</option>
                                                                <c:forEach var="r" items="${routerList}">
                                                                    <option value="${r.routerId}">${r.routerName} (${r.ipAddress})</option>
                                                                </c:forEach>
                                                            </select>
                                                        </div>
                                                        <div class="col-12">
                                                            <div class="form-label-custom">Message <span
                                                                    style="color:#f87171;">*</span></div>
                                                            <textarea name="message" class="form-ctrl" rows="2"
                                                                placeholder="Describe the alert in detail…" required
                                                                maxlength="1000" style="resize:vertical;"></textarea>
                                                        </div>
                                                        <div class="col-md-6">
                                                            <div class="form-label-custom">AP ID (optional)</div>
                                                            <input type="number" name="apId" class="form-ctrl" min="1"
                                                                placeholder="Leave blank if N/A">
                                                        </div>
                                                        <div class="col-md-6">
                                                            <div class="form-label-custom">Switch ID (optional)</div>
                                                            <input type="number" name="switchId" class="form-ctrl"
                                                                min="1" placeholder="Leave blank if N/A">
                                                        </div>
                                                        <div class="col-12"
                                                            style="display:flex;justify-content:flex-end;gap:8px;">
                                                            <button type="reset" class="btn-theme">
                                                                <i class="bi bi-x-lg"></i> Clear
                                                            </button>
                                                            <button type="submit" class="btn-danger-theme">
                                                                <i class="bi bi-bell-fill"></i> Create Alert
                                                            </button>
                                                        </div>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- ── Severity Filter Tabs + Table ── -->
                                <div class="section-card mb-0"
                                    style="border-bottom-left-radius:0;border-bottom-right-radius:0;border-bottom:none;">
                                    <div class="sev-tabs">
                                        <a href="NetworkAlertController?action=list"
                                            class="sev-tab tab-all ${severityFilter eq 'ALL' ? 'active' : ''}">
                                            <i class="bi bi-grid-3x3-gap"></i> All
                                            <span class="sev-count sev-count-all">${totalAlerts}</span>
                                        </a>
                                        <a href="NetworkAlertController?action=filter&severity=CRITICAL"
                                            class="sev-tab tab-critical ${severityFilter eq 'CRITICAL' ? 'active' : ''}">
                                            <span class="dot dot-critical"></span> Critical
                                            <span class="sev-count sev-count-critical">${critCount}</span>
                                        </a>
                                        <a href="NetworkAlertController?action=filter&severity=WARNING"
                                            class="sev-tab tab-warning ${severityFilter eq 'WARNING' ? 'active' : ''}">
                                            <span class="dot dot-warning"></span> Warning
                                            <span class="sev-count sev-count-warning">${warnCount}</span>
                                        </a>
                                        <a href="NetworkAlertController?action=filter&severity=INFO"
                                            class="sev-tab tab-info ${severityFilter eq 'INFO' ? 'active' : ''}">
                                            <span class="dot dot-info"></span> Info
                                            <span class="sev-count sev-count-info">${infoCount}</span>
                                        </a>

                                        <!-- inline quick search -->
                                        <div style="margin-left:auto;display:flex;align-items:center;gap:6px;">
                                            <div style="position:relative;">
                                                <i class="bi bi-search"
                                                    style="position:absolute;left:10px;top:50%;transform:translateY(-50%);color:var(--text-muted);font-size:12px;"></i>
                                                <input type="text" id="alertSearch" placeholder="Search alerts…"
                                                    oninput="filterTable()" style="background:rgba(22,31,54,.8);border:1px solid var(--border);
                                        color:var(--text-primary);border-radius:8px;padding:5px 10px 5px 30px;
                                        font-size:12px;width:200px;outline:none;"
                                                    onfocus="this.style.borderColor='#8b5cf6'"
                                                    onblur="this.style.borderColor='var(--border)'">
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="section-card" style="border-top-left-radius:0;border-top-right-radius:0;">
                                    <div class="section-card-header">
                                        <h6>
                                            <i class="bi bi-table me-2"></i>
                                            <c:choose>
                                                <c:when test="${severityFilter eq 'ALL'}">All Network Alerts</c:when>
                                                <c:otherwise>Filtered — <span
                                                        style="color:${severityFilter eq 'CRITICAL' ? '#f87171' : (severityFilter eq 'WARNING' ? '#fde68a' : '#bae6fd')}">${severityFilter}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </h6>
                                        <div class="d-flex align-items-center gap-2">
                                            <span style="font-size:12px;color:var(--text-muted);">${totalAlerts} record(s)</span>
                                            <div class="pagination-controls">
                                                <button class="page-btn" onclick="prevPage('alertTable')" id="alertTable-prev"><i class="bi bi-chevron-left"></i></button>
                                                <span class="page-info" id="alertTable-page-info">Page 1 of 1</span>
                                                <button class="page-btn" onclick="nextPage('alertTable')" id="alertTable-next"><i class="bi bi-chevron-right"></i></button>
                                            </div>
                                        </div>
                                    </div>
                                    <div style="overflow-x:auto;">
                                        <table class="rt-table" id="alertTable">
                                            <thead>
                                                <tr>
                                                    <th><i class="bi bi-hash me-1"></i>ID</th>
                                                    <th><i class="bi bi-tag me-1"></i>Type</th>
                                                    <th><i class="bi bi-thermometer-half me-1"></i>Severity</th>
                                                    <th><i class="bi bi-chat-left-text me-1"></i>Message</th>
                                                    <th><i class="bi bi-hdd-network me-1"></i>Device</th>
                                                    <th><i class="bi bi-clock me-1"></i>Created At</th>
                                                    <th><i class="bi bi-three-dots me-1"></i>Action</th>
                                                </tr>
                                            </thead>
                                            <tbody id="alertTbody">
                                                <c:choose>
                                                    <c:when test="${not empty alerts}">
                                                        <c:forEach var="alert" items="${alerts}">
                                                            <c:set var="sevUp"
                                                                value="${fn:toUpperCase(alert.severity)}" />
                                                            <tr data-sev="${sevUp}"
                                                                data-msg="${fn:toLowerCase(alert.message)}"
                                                                data-type="${fn:toLowerCase(alert.alertType)}">
                                                                <td><span class="rt-id">#${alert.alertId}</span></td>
                                                                <td><span class="type-badge"><i
                                                                            class="bi bi-tag-fill"></i>${alert.alertType}</span>
                                                                </td>
                                                                <td>
                                                                    <span
                                                                        class="sev-badge ${sevUp eq 'CRITICAL' ? 'sev-critical' : (sevUp eq 'WARNING' ? 'sev-warning' : 'sev-info')}">
                                                                        <span
                                                                            class="dot ${sevUp eq 'CRITICAL' ? 'dot-critical' : (sevUp eq 'WARNING' ? 'dot-warning' : 'dot-info')}"></span>
                                                                        ${alert.severity}
                                                                    </span>
                                                                </td>
                                                                <td style="max-width:300px;">
                                                                    <span
                                                                        style="font-size:.8rem;line-height:1.4;display:block;
                                                color:${sevUp eq 'CRITICAL' ? '#fca5a5' : (sevUp eq 'WARNING' ? '#fde68a' : 'var(--text-primary)')}">
                                                                        ${alert.message}
                                                                    </span>
                                                                </td>
                                                                <td>
                                                                    <c:choose>
                                                                        <c:when test="${alert.routerId != null}">
                                                                            <span class="dev-badge">
                                                                                <i class="bi bi-router-fill"></i> Router
                                                                                #${alert.routerId}
                                                                            </span>
                                                                        </c:when>
                                                                        <c:when test="${alert.apId != null}">
                                                                            <span class="dev-badge"
                                                                                style="color:#d946ef;border-color:rgba(217,70,239,.25);background:rgba(217,70,239,.07);">
                                                                                <i class="bi bi-reception-4"></i> AP
                                                                                #${alert.apId}
                                                                            </span>
                                                                        </c:when>
                                                                        <c:when test="${alert.switchId != null}">
                                                                            <span class="dev-badge"
                                                                                style="color:#fbbf24;border-color:rgba(251,191,36,.25);background:rgba(251,191,36,.07);">
                                                                                <i class="bi bi-hdd-network-fill"></i>
                                                                                Switch #${alert.switchId}
                                                                            </span>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <span
                                                                                style="font-size:.72rem;color:var(--text-muted);">—</span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                                <td
                                                                    style="font-family:'Courier New',monospace;font-size:.76rem;color:#93c5fd;white-space:nowrap;">
                                                                    ${alert.createdAt}
                                                                </td>
                                                                <td>
                                                                    <div class="rt-actions">
                                                                        <!-- Resolve (delete) -->
                                                                        <a href="#" class="rt-btn rt-btn-resolve"
                                                                            onclick="confirmResolve(${alert.alertId}); return false;"
                                                                            title="Mark as resolved">
                                                                            <i class="bi bi-check2-circle"></i> Resolve
                                                                        </a>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <tr>
                                                            <td colspan="7">
                                                                <div class="rt-empty">
                                                                    <i class="bi bi-bell-slash"></i>
                                                                    No alerts found.
                                                                    <span
                                                                        style="display:block;margin-top:6px;font-size:12px;">
                                                                        <c:choose>
                                                                            <c:when test="${severityFilter ne 'ALL'}">
                                                                                No ${severityFilter} alerts at this
                                                                                time. <a
                                                                                    href="NetworkAlertController?action=list"
                                                                                    style="color:var(--neon-purple);">View
                                                                                    all</a>
                                                                            </c:when>
                                                                            <c:otherwise>Your network is running clean.
                                                                                No alerts to report.</c:otherwise>
                                                                        </c:choose>
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

                            </div><!-- /.page-body -->
                        </div><!-- /.main-content -->

                        <!-- ══ Confirm Resolve Modal ══ -->
                        <div class="confirm-overlay" id="confirmOverlay">
                            <div class="confirm-box">
                                <div class="confirm-icon"><i class="bi bi-check-circle"></i></div>
                                <div class="confirm-title">Resolve this alert?</div>
                                <div class="confirm-body">
                                    This will permanently remove the alert from the system.<br>
                                    This action cannot be undone.
                                </div>
                                <div class="confirm-btns">
                                    <button class="btn-theme" onclick="closeConfirm()">
                                        <i class="bi bi-x"></i> Cancel
                                    </button>
                                    <a href="#" id="confirmResolveLink" class="btn-danger-theme">
                                        <i class="bi bi-check2-circle"></i> Yes, Resolve
                                    </a>
                                </div>
                            </div>
                        </div>

                        <!-- ══════════════════════ SCRIPTS ══════════════════════ -->
                        <script>
                            /* ── Severity donut chart ── */
                            (function () {
                                const crit = ${ critCount };
                                const warn = ${ warnCount };
                                const info = ${ infoCount };
                                const total = crit + warn + info;

                                // Update sidebar badge
                                const badge = document.getElementById('alertBadge');
                                if (badge && total > 0) badge.textContent = total;

                                const ctx = document.getElementById('severityChart');
                                if (!ctx) return;
                                new Chart(ctx, {
                                    type: 'doughnut',
                                    data: {
                                        labels: ['Critical', 'Warning', 'Info'],
                                        datasets: [{
                                            data: [crit, warn, info],
                                            backgroundColor: ['rgba(239,68,68,.6)', 'rgba(245,158,11,.55)', 'rgba(96,165,250,.55)'],
                                            borderColor: ['#ef4444', '#f59e0b', '#60a5fa'],
                                            borderWidth: 1.5,
                                            hoverOffset: 6
                                        }]
                                    },
                                    options: {
                                        responsive: true, maintainAspectRatio: false,
                                        cutout: '68%',
                                        plugins: {
                                            legend: {
                                                position: 'bottom',
                                                labels: { color: '#9aa6c7', font: { size: 11 }, boxWidth: 12, padding: 14 }
                                            },
                                            tooltip: {
                                                backgroundColor: 'rgba(10,14,28,.95)',
                                                borderColor: '#2a3555', borderWidth: 1,
                                                titleColor: '#f2f5ff', bodyColor: '#9aa6c7', padding: 10,
                                                callbacks: {
                                                    label: ctx => ` ${ctx.label}: ${ctx.raw} (${total ? Math.round(ctx.raw * 100 / total) : 0}%)`
                                                }
                                            }
                                        }
                                    }
                                });
                            })();

                            /* ── Inline search filter ── */
                            function filterTable() {
                                const query = document.getElementById('alertSearch').value.toLowerCase();
                                const rows = document.querySelectorAll('#alertTbody tr[data-sev]');
                                rows.forEach(row => {
                                    const msg = row.dataset.msg || '';
                                    const type = row.dataset.type || '';
                                    row.style.display = (msg.includes(query) || type.includes(query)) ? '' : 'none';
                                });
                            }

                            /* ── Resolve confirm modal ── */
                            function confirmResolve(alertId) {
                                const link = document.getElementById('confirmResolveLink');
                                if (link) link.href = 'NetworkAlertController?action=resolve&alertId=' + alertId;
                                document.getElementById('confirmOverlay').classList.add('show');
                            }
                            function closeConfirm() {
                                document.getElementById('confirmOverlay').classList.remove('show');
                            }
                            document.getElementById('confirmOverlay').addEventListener('click', function (e) {
                                if (e.target === this) closeConfirm();
                            });
                            document.addEventListener('keydown', e => { if (e.key === 'Escape') closeConfirm(); });

                            // Pagination
                            const PAGE_SIZE = 10;
                            const paginationState = {};

                            function initPagination(tableId) {
                                const tbody = document.querySelector('#' + tableId + ' tbody');
                                if (!tbody) return;
                                const rows = Array.from(tbody.querySelectorAll('tr'));
                                const total = Math.max(1, Math.ceil(rows.length / PAGE_SIZE));
                                paginationState[tableId] = { current: 1, total: total, rows: rows };
                                showPageForTable(tableId);
                            }

                            function showPageForTable(tableId) {
                                const state = paginationState[tableId];
                                if (!state) return;
                                const start = (state.current - 1) * PAGE_SIZE;
                                const end = start + PAGE_SIZE;
                                state.rows.forEach(function(r, i) {
                                    r.style.display = (i >= start && i < end) ? '' : 'none';
                                });
                                document.getElementById(tableId + '-page-info').textContent = 'Page ' + state.current + ' of ' + state.total;
                                document.getElementById(tableId + '-prev').disabled = state.current <= 1;
                                document.getElementById(tableId + '-next').disabled = state.current >= state.total;
                            }

                            function prevPage(tableId) {
                                const state = paginationState[tableId];
                                if (state && state.current > 1) { state.current--; showPageForTable(tableId); }
                            }

                            function nextPage(tableId) {
                                const state = paginationState[tableId];
                                if (state && state.current < state.total) { state.current++; showPageForTable(tableId); }
                            }

                            document.addEventListener('DOMContentLoaded', function() {
                                initPagination('alertTable');
                            });
                        </script>
                    </body>

                    </html>