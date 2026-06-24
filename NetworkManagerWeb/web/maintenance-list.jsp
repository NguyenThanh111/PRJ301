<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@page import="Models_DAO.MaintenanceScheduleDAO"%>
<%@page import="Models.MaintenanceScheduleDTO"%>
<%@page import="java.util.ArrayList"%>
<%
    Models.UserDTO currentUser = (Models.UserDTO) session.getAttribute("user");
    String role = (String) session.getAttribute("role");
    if (currentUser == null || role == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    request.setAttribute("currentUser", currentUser);
    request.setAttribute("role", role);
    request.setAttribute("roleLower", role.toLowerCase());
    request.setAttribute("displayName", currentUser.getFullName() != null && !currentUser.getFullName().isEmpty() ? currentUser.getFullName() : currentUser.getUsername());
    request.setAttribute("isAdmin", role.equalsIgnoreCase("admin"));

    MaintenanceScheduleDAO dao = new MaintenanceScheduleDAO();
    ArrayList<MaintenanceScheduleDTO> tasks = dao.ListAll();
    request.setAttribute("tasks", tasks);

    int countPlanned = 0;
    int countInProgress = 0;
    int countCompleted = 0;

    for(MaintenanceScheduleDTO t : tasks) {
        if("PLANNED".equalsIgnoreCase(t.getStatus())) countPlanned++;
        else if("IN_PROGRESS".equalsIgnoreCase(t.getStatus())) countInProgress++;
        else if("COMPLETED".equalsIgnoreCase(t.getStatus())) countCompleted++;
    }

    request.setAttribute("totalTasks", tasks.size());
    request.setAttribute("countPlanned", countPlanned);
    request.setAttribute("countInProgress", countInProgress);
    request.setAttribute("countCompleted", countCompleted);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Maintenance Schedules â€” Network Manager</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
    <style>
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
            --glow: 0 0 18px rgba(251, 191, 36, .22);
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            background: linear-gradient(rgba(5, 8, 18, .88), rgba(6, 9, 20, .84)),
                        radial-gradient(circle at 12% 12%, rgba(251, 191, 36, .12), transparent 28%),
                        url('theme/original-d5209459af4999984ad44693bbcb28f7.webp') center/cover fixed no-repeat;
            color: var(--text-primary); min-height: 100vh; font-family: "Segoe UI", Arial, sans-serif;
        }

                                    /* â”€â”€â”€ Sidebar â”€â”€â”€ */
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

                            /* â”€â”€â”€ Layout â”€â”€â”€ */
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

        .main-content { margin-left: var(--sidebar-w); min-height: 100vh; }

        .topbar {
            position: sticky; top: 0; z-index: 60; padding: 14px 24px;
            border-bottom: 1px solid var(--border); background: rgba(12, 17, 32, .9);
            backdrop-filter: blur(8px); display: flex; align-items: center; justify-content: space-between;
        }

        .topbar-title { font-size: 18px; font-weight: 700; }
        .topbar-breadcrumb { font-size: 12px; color: var(--text-muted); margin-left: 8px; }

        .role-badge-admin, .role-badge-tech {
            border-radius: 999px; padding: 4px 10px; font-size: 11px;
            letter-spacing: .08em; text-transform: uppercase; font-weight: 700;
        }
        .role-badge-admin { color: #fecaca; background: rgba(239, 68, 68, .16); border: 1px solid rgba(239, 68, 68, .4); }
        .role-badge-tech { color: #ddd6fe; background: rgba(139, 92, 246, .16); border: 1px solid rgba(139, 92, 246, .4); }

        .page-body { padding: 22px; }

        .stat-card, .section-card {
            background: linear-gradient(180deg, rgba(20, 28, 48, .92), rgba(15, 21, 38, .95));
            border: 1px solid var(--border); border-radius: var(--radius-lg);
        }

        .stat-card { padding: 18px; transition: border-color .2s; }
        .stat-card:hover { border-color: rgba(251, 191, 36, .45); }
        .stat-icon {
            width: 44px; height: 44px; border-radius: 12px; display: flex; align-items: center;
            justify-content: center; margin-bottom: 12px; font-size: 20px;
        }
        .stat-value { font-size: 28px; font-weight: 800; line-height: 1; margin-bottom: 4px; }
        .stat-label { font-size: 12px; color: var(--text-muted); }
        .stat-delta { font-size: 11px; margin-top: 6px; }

        .section-card-header {
            padding: 14px 18px; border-bottom: 1px solid var(--border); display: flex;
            align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 8px;
        }
        .section-card-header h6 { margin: 0; font-size: 14px; font-weight: 700; color: #ebedff; }
        .section-card-body { padding: 18px; }

        .chart-wrap { position: relative; height: 260px; width: 100%; display: flex; justify-content: center; }

        .rt-table { width: 100%; border-collapse: collapse; font-size: .82rem; }
        .rt-table thead tr { background: rgba(22, 31, 54, .95); border-bottom: 1px solid var(--border); }
        .rt-table thead th {
            padding: 11px 14px; color: var(--text-muted); font-weight: 600; font-size: .7rem;
            letter-spacing: .08em; text-transform: uppercase; white-space: nowrap;
        }
        .rt-table tbody tr { border-bottom: 1px solid rgba(42, 53, 85, .35); transition: background .15s; }
        .rt-table tbody tr:hover { background: rgba(251, 191, 36, .06); }
        .rt-table tbody td { padding: 11px 14px; color: var(--text-primary); vertical-align: middle; }

        .rt-id {
            display: inline-flex; align-items: center; justify-content: center; background: rgba(251, 191, 36, .12);
            border: 1px solid rgba(251, 191, 36, .25); color: var(--neon-amber); border-radius: 5px; padding: 1px 8px;
            font-size: .72rem; font-weight: 700; font-family: monospace;
        }

        .status-badge {
            display: inline-flex; align-items: center; gap: 5px; padding: 4px 11px;
            border-radius: 20px; font-size: 0.72rem; font-weight: 700; letter-spacing: 0.05em;
            text-transform: uppercase; white-space: nowrap;
        }
        .status-badge::before { content: ''; width: 6px; height: 6px; border-radius: 50%; display: inline-block; }
        
        .status-planned { background: rgba(96, 165, 250, 0.12); border: 1px solid rgba(96, 165, 250, 0.3); color: var(--neon-blue); }
        .status-planned::before { background: var(--neon-blue); box-shadow: 0 0 6px var(--neon-blue); }

        .status-inprogress { background: rgba(251, 191, 36, 0.12); border: 1px solid rgba(251, 191, 36, 0.3); color: var(--neon-amber); }
        .status-inprogress::before { background: var(--neon-amber); box-shadow: 0 0 6px var(--neon-amber); animation: blink 1.4s infinite; }

        .status-completed { background: rgba(52, 211, 153, 0.12); border: 1px solid rgba(52, 211, 153, 0.3); color: var(--neon-emerald); }
        .status-completed::before { background: var(--neon-emerald); }

        @keyframes blink { 0%,100% { opacity:1; } 50% { opacity:0.3; } }

        .btn-theme {
            border: 1px solid rgba(251, 191, 36, .5); background: rgba(251, 191, 36, .2); color: #fde68a;
            border-radius: 8px; padding: 7px 14px; font-size: 13px; font-weight: 600; cursor: pointer;
            transition: all .18s; display: inline-flex; align-items: center; gap: 6px; text-decoration: none;
        }
        .btn-theme:hover { background: rgba(251, 191, 36, .35); filter: brightness(1.1); color: #fff; }

        .btn-icon {
            display: inline-flex; align-items: center; justify-content: center;
            width: 32px; height: 32px; border-radius: 7px; border: 1px solid transparent;
            font-size: 14px; cursor: pointer; text-decoration: none; transition: all 0.2s; background: transparent;
        }

        .btn-icon-edit { border-color: rgba(96,165,250,0.3); color: var(--neon-blue); background: rgba(96,165,250,0.08); }
        .btn-icon-edit:hover { background: rgba(96,165,250,0.2); box-shadow: 0 0 10px rgba(96,165,250,0.3); color: var(--neon-blue); }

        .btn-icon-delete { border-color: rgba(248,113,113,0.3); color: #f87171; background: rgba(248,113,113,0.08); }
        .btn-icon-delete:hover { background: rgba(248,113,113,0.2); box-shadow: 0 0 10px rgba(248,113,113,0.3); color: #f87171; }

        .btn-icon-complete { border-color: rgba(52,211,153,0.3); color: var(--neon-emerald); background: rgba(52,211,153,0.08); }
        .btn-icon-complete:hover { background: rgba(52,211,153,0.2); box-shadow: 0 0 10px rgba(52,211,153,0.3); color: var(--neon-emerald); }

        /* Filter Tabs */
        .sev-tabs {
            display: flex; gap: 8px; flex-wrap: wrap; padding: 14px 18px; border-bottom: 1px solid var(--border);
        }
        .sev-tab {
            border-radius: 8px; padding: 6px 14px; font-size: 12px; font-weight: 700; cursor: pointer;
            transition: .18s; display: inline-flex; align-items: center; gap: 7px;
            border: 1px solid var(--border); background: rgba(22, 31, 54, .6); color: var(--text-muted);
            text-decoration: none; user-select: none;
        }
        .sev-tab:hover { color: #e5ddff; filter: brightness(1.1); }
        .sev-tab.tab-all.active { background: rgba(139, 92, 246, .25); border-color: rgba(139, 92, 246, .6); color: #f0ebff; }
        .sev-tab.tab-planned.active { background: rgba(96, 165, 250, .2); border-color: rgba(96, 165, 250, .6); color: #bae6fd; }
        .sev-tab.tab-inprogress.active { background: rgba(251, 191, 36, .18); border-color: rgba(251, 191, 36, .6); color: #fde68a; }
        .sev-tab.tab-completed.active { background: rgba(52, 211, 153, .18); border-color: rgba(52, 211, 153, .6); color: #a7f3d0; }

        .sev-count {
            display: inline-flex; align-items: center; justify-content: center; min-width: 20px;
            height: 20px; border-radius: 10px; font-size: 10px; padding: 0 6px; font-weight: 800;
        }
        .sev-count-all { background: rgba(139, 92, 246, .3); color: #e0d6ff; }
        .sev-count-planned { background: rgba(96, 165, 250, .3); color: #bae6fd; }
        .sev-count-inprogress { background: rgba(251, 191, 36, .3); color: #fde68a; }
        .sev-count-completed { background: rgba(52, 211, 153, .3); color: #a7f3d0; }

        .dot { width: 8px; height: 8px; border-radius: 50%; display: inline-block; }
        .dot-planned { background: var(--neon-blue); box-shadow: 0 0 6px var(--neon-blue); }
        .dot-inprogress { background: var(--neon-amber); box-shadow: 0 0 6px var(--neon-amber); animation: blink 1.4s infinite; }
        .dot-completed { background: var(--neon-emerald); }

        /* Pagination Controls */
        .pagination-controls { display: flex; align-items: center; gap: 8px; }
        .pagination-controls .page-btn { width: 32px; height: 32px; border-radius: 8px; border: 1px solid var(--border); background: rgba(139, 92, 246, 0.15); color: #e8ddff; display: flex; align-items: center; justify-content: center; cursor: pointer; transition: 0.15s ease; font-size: 14px; }
        .pagination-controls .page-btn:hover { background: rgba(139, 92, 246, 0.3); border-color: rgba(139, 92, 246, 0.6); }
        .pagination-controls .page-btn:disabled { opacity: 0.35; cursor: not-allowed; }
        .pagination-controls .page-info { font-size: 12px; color: var(--text-muted); min-width: 70px; text-align: center; }

        @media (max-width: 900px) { .sidebar { display: none; } .main-content { margin-left: 0; } }
    </style>
</head>
<body>

    <c:set var="sidebarActive" value="maintenance" scope="request" />
    <%@include file="sidebar.jsp" %>

    <div class="main-content">
        <div class="topbar">
            <div>
                <span class="topbar-title">Maintenance</span>
                <span class="topbar-breadcrumb">/ Operations</span>
            </div>
            <div style="display:flex;align-items:center;gap:10px;">
                <span class="${isAdmin ? 'role-badge-admin' : 'role-badge-tech'}">${role}</span>
                <span style="font-size:13px;color:#9db0db;">Welcome, <strong style="color:#f2f5ff;">${displayName}</strong></span>
            </div>
        </div>

        <div class="page-body">
            <!-- KPI Row -->
            <div class="row g-3 mb-3">
                <div class="col-6 col-lg-3">
                    <div class="stat-card">
                        <div class="stat-icon" style="background:rgba(251,191,36,.15);color:#fbbf24;"><i class="bi bi-tools"></i></div>
                        <div class="stat-value" style="color:#fde68a;">${totalTasks}</div>
                        <div class="stat-label">Total Schedules</div>
                        <div class="stat-delta" style="color:var(--text-muted);">All time tasks</div>
                    </div>
                </div>
                <div class="col-6 col-lg-3">
                    <div class="stat-card">
                        <div class="stat-icon" style="background:rgba(96,165,250,.12);color:#60a5fa;"><i class="bi bi-calendar-event"></i></div>
                        <div class="stat-value" style="color:#bfdbfe;">${countPlanned}</div>
                        <div class="stat-label">Planned</div>
                        <div class="stat-delta" style="color:var(--text-muted);">Upcoming tasks</div>
                    </div>
                </div>
                <div class="col-6 col-lg-3">
                    <div class="stat-card">
                        <div class="stat-icon" style="background:rgba(245,158,11,.12);color:#f59e0b;"><i class="bi bi-gear-wide-connected"></i></div>
                        <div class="stat-value" style="color:#fde68a;">${countInProgress}</div>
                        <div class="stat-label">In Progress</div>
                        <div class="stat-delta" style="color:var(--text-muted);">Currently executing</div>
                    </div>
                </div>
                <div class="col-6 col-lg-3">
                    <div class="stat-card">
                        <div class="stat-icon" style="background:rgba(52,211,153,.12);color:#34d399;"><i class="bi bi-check2-circle"></i></div>
                        <div class="stat-value" style="color:#6ee7b7;">${countCompleted}</div>
                        <div class="stat-label">Completed</div>
                        <div class="stat-delta" style="color:var(--text-muted);">Finished tasks</div>
                    </div>
                </div>
            </div>

            <!-- Chart Row -->
            <div class="row g-3 mb-3">
                <div class="col-12">
                    <div class="section-card h-100">
                        <div class="section-card-header">
                            <h6><i class="bi bi-pie-chart me-2" style="color:var(--neon-amber);"></i>Status Distribution</h6>
                        </div>
                        <div class="section-card-body">
                            <div class="chart-wrap">
                                <canvas id="maintenanceChart"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Table Row -->
            <div class="section-card">
                <div class="section-card-header">
                    <h6><i class="bi bi-card-checklist me-2" style="color:var(--neon-emerald);"></i>Maintenance Log</h6>
                    <div style="display:flex; align-items:center; gap:15px;">
                        <div class="pagination-controls">
                            <button class="page-btn" onclick="prevPage('maintenance-table')" id="maintenance-table-prev"><i class="bi bi-chevron-left"></i></button>
                            <span class="page-info" id="maintenance-table-page-info">Page 1 of 1</span>
                            <button class="page-btn" onclick="nextPage('maintenance-table')" id="maintenance-table-next"><i class="bi bi-chevron-right"></i></button>
                        </div>
                        <a href="maintenance-form.jsp" class="btn-theme"><i class="bi bi-plus-lg"></i> Schedule Task</a>
                    </div>
                </div>
                
                <div class="sev-tabs">
                    <div class="sev-tab tab-all active" onclick="filterTasks('ALL', this)">
                        <i class="bi bi-grid-fill"></i> All <span class="sev-count sev-count-all">${totalTasks}</span>
                    </div>
                    <div class="sev-tab tab-planned" onclick="filterTasks('PLANNED', this)">
                        <span class="dot dot-planned"></span> Planned <span class="sev-count sev-count-planned">${countPlanned}</span>
                    </div>
                    <div class="sev-tab tab-inprogress" onclick="filterTasks('IN_PROGRESS', this)">
                        <span class="dot dot-inprogress"></span> In Progress <span class="sev-count sev-count-inprogress">${countInProgress}</span>
                    </div>
                    <div class="sev-tab tab-completed" onclick="filterTasks('COMPLETED', this)">
                        <span class="dot dot-completed"></span> Completed <span class="sev-count sev-count-completed">${countCompleted}</span>
                    </div>
                </div>

                <div class="section-card-body p-0" style="overflow-x:auto;">
                    <table class="rt-table" id="maintenance-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Task Title</th>
                                <th>Start Time</th>
                                <th>End Time</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty tasks}">
                                    <c:forEach var="task" items="${tasks}">
                                        <tr class="task-row" data-status="${task.status}">
                                            <td><span class="rt-id">#${task.maintenanceId}</span></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${task.status eq 'COMPLETED'}">
                                                        <div style="font-weight:600; color:#6ee7b7; font-size: 0.95rem;"><i class="bi bi-check-circle-fill me-2" style="font-size:0.85rem; color:#34d399;"></i>${task.title}</div>
                                                    </c:when>
                                                    <c:when test="${task.status eq 'IN_PROGRESS'}">
                                                        <div style="font-weight:600; color:#fde68a; font-size: 0.95rem;"><i class="bi bi-gear-fill me-2" style="font-size:0.85rem; color:#fbbf24;"></i>${task.title}</div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div style="font-weight:600; color:#bae6fd; font-size: 0.95rem;"><i class="bi bi-clock-fill me-2" style="font-size:0.85rem; color:#60a5fa;"></i>${task.title}</div>
                                                    </c:otherwise>
                                                </c:choose>
                                                <div style="font-size:0.75rem; color:var(--text-muted); margin-top:6px; line-height:1.5; white-space:pre-wrap; word-wrap:break-word; background:rgba(15,23,42,0.6); padding:8px 12px; border-radius:6px; border-left: 2px solid rgba(139,92,246,0.4);">
                                                    ${task.description}
                                                </div>
                                            </td>
                                            <td style="color:#d8c9ff;"><fmt:formatDate value="${task.startTime}" pattern="MMM dd, yyyy HH:mm" /></td>
                                            <td style="color:#a5b2d8;">
                                                <c:choose>
                                                    <c:when test="${not empty task.endTime}">
                                                        <fmt:formatDate value="${task.endTime}" pattern="MMM dd, yyyy HH:mm" />
                                                    </c:when>
                                                    <c:otherwise>
                                                        <em style="opacity: 0.6;">Not set</em>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <div class="status-badge 
                                                    <c:choose>
                                                        <c:when test="${task.status eq 'PLANNED'}">status-planned</c:when>
                                                        <c:when test="${task.status eq 'IN_PROGRESS'}">status-inprogress</c:when>
                                                        <c:when test="${task.status eq 'COMPLETED'}">status-completed</c:when>
                                                    </c:choose>">
                                                    ${task.status}
                                                </div>
                                            </td>
                                            <td>
                                                <div style="display:flex; gap: 5px; align-items:center;">
                                                    <c:if test="${task.status ne 'COMPLETED'}">
                                                        <form action="MaintenanceServlet" method="post" style="margin:0;">
                                                            <input type="hidden" name="action" value="maintenanceComplete">
                                                            <input type="hidden" name="maintenanceId" value="${task.maintenanceId}">
                                                            <button type="submit" class="btn-icon btn-icon-complete" title="Mark as Completed" onclick="return confirm('Complete this task?');">
                                                                <i class="bi bi-check-lg"></i>
                                                            </button>
                                                        </form>
                                                    </c:if>
                                                    
                                                    <a class="btn-icon btn-icon-edit" href="MaintenanceServlet?action=maintenanceEdit&maintenanceId=${task.maintenanceId}" title="Edit task">
                                                        <i class="bi bi-pencil-fill"></i>
                                                    </a>
                                                    
                                                    <form action="MaintenanceServlet" method="post" style="margin:0;">
                                                        <input type="hidden" name="action" value="maintenanceDelete">
                                                        <input type="hidden" name="maintenanceId" value="${task.maintenanceId}">
                                                        <button type="submit" class="btn-icon btn-icon-delete" title="Delete task" onclick="return confirm('Delete this maintenance task?');">
                                                            <i class="bi bi-trash3-fill"></i>
                                                        </button>
                                                    </form>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="6" style="text-align:center; padding: 40px; color:var(--text-muted);">
                                            <i class="bi bi-tools fs-1 mb-2 d-block text-secondary"></i> No maintenance tasks scheduled.
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </div>

    <script>
        // Extract data for chart
        const countPlanned = ${countPlanned};
        const countInProgress = ${countInProgress};
        const countCompleted = ${countCompleted};

        if(countPlanned > 0 || countInProgress > 0 || countCompleted > 0) {
            const ctx = document.getElementById('maintenanceChart').getContext('2d');
            new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: ['Planned', 'In Progress', 'Completed'],
                    datasets: [{
                        data: [countPlanned, countInProgress, countCompleted],
                        backgroundColor: [
                            'rgba(96, 165, 250, 0.8)',   // Blue
                            'rgba(251, 191, 36, 0.8)',   // Amber
                            'rgba(52, 211, 153, 0.8)'    // Emerald
                        ],
                        borderColor: [
                            'rgba(96, 165, 250, 1)',
                            'rgba(251, 191, 36, 1)',
                            'rgba(52, 211, 153, 1)'
                        ],
                        borderWidth: 1,
                        hoverOffset: 4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'right',
                            labels: {
                                color: '#9aa6c7',
                                font: { family: "'Segoe UI', sans-serif" },
                                padding: 20
                            }
                        },
                        tooltip: {
                            backgroundColor: 'rgba(15, 23, 42, 0.9)',
                            titleColor: '#fff',
                            bodyColor: '#e2e8f0',
                            borderColor: 'rgba(251, 191, 36, 0.3)',
                            borderWidth: 1,
                            padding: 12,
                            cornerRadius: 8
                        }
                    },
                    cutout: '70%'
                }
            });
        } else {
            // Hide chart if no data
            document.getElementById('maintenanceChart').style.display = 'none';
        }

        // Filter functionality
        function filterTasks(status, element) {
            // Update active tab styling
            document.querySelectorAll('.sev-tab').forEach(tab => tab.classList.remove('active'));
            element.classList.add('active');

            // Filter rows
            const allRows = Array.from(document.querySelectorAll('.task-row'));
            let matchingRows = [];
            
            allRows.forEach(row => {
                row.style.display = 'none'; // hide all initially
                if (status === 'ALL' || row.getAttribute('data-status') === status) {
                    matchingRows.push(row);
                }
            });

            // Handle empty state message
            let emptyMsg = document.getElementById('empty-filter-msg');
            if(matchingRows.length === 0) {
                if(!emptyMsg) {
                    const tbody = document.querySelector('.rt-table tbody');
                    const tr = document.createElement('tr');
                    tr.id = 'empty-filter-msg';
                    tr.innerHTML = `<td colspan="6" style="text-align:center; padding: 40px; color:var(--text-muted);"><i class="bi bi-funnel fs-1 mb-2 d-block text-secondary"></i> No tasks match the selected filter.</td>`;
                    tbody.appendChild(tr);
                } else {
                    emptyMsg.style.display = '';
                }
                document.querySelector('.pagination-controls').style.display = 'none';
            } else {
                if(emptyMsg) emptyMsg.style.display = 'none';
                document.querySelector('.pagination-controls').style.display = 'flex';
                initPagination('maintenance-table', matchingRows);
            }
        }

        // Pagination
        const PAGE_SIZE = 10;
        const paginationState = {};

        function initPagination(tableId, rowsArray) {
            let rows = rowsArray;
            if (!rows) {
                const tbody = document.querySelector('#' + tableId + ' tbody');
                if (!tbody) return;
                rows = Array.from(tbody.querySelectorAll('tr.task-row'));
            }
            const total = Math.max(1, Math.ceil(rows.length / PAGE_SIZE));
            paginationState[tableId] = { current: 1, total: total, rows: rows };
            showPageForTable(tableId);
        }

        function showPageForTable(tableId) {
            const state = paginationState[tableId];
            if (!state) return;
            
            // First hide all rows in the table
            const tbody = document.querySelector('#' + tableId + ' tbody');
            if (tbody) {
                Array.from(tbody.querySelectorAll('tr.task-row')).forEach(r => r.style.display = 'none');
            }

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

        document.addEventListener('DOMContentLoaded', () => {
            initPagination('maintenance-table');
        });
    </script>
</body>
</html>


