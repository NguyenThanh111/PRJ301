<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@page import="Models.MaintenanceScheduleDAO"%>
<%@page import="Models.MaintenanceScheduleDTO"%>
<%@page import="java.util.ArrayList"%>
<%
    MaintenanceScheduleDAO dao = new MaintenanceScheduleDAO();
    ArrayList<MaintenanceScheduleDTO> tasks = dao.ListAll();
    request.setAttribute("tasks", tasks);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Maintenance Schedules — Network Manager</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root {
            --bg-0: #05070d; --bg-1: #0b1020; --surface: #10172a; --surface-2: #161f36; --border: #2a3555;
            --text-primary: #f2f5ff; --text-muted: #9aa6c7;
            --neon-purple: #8b5cf6; --neon-pink: #d946ef; --neon-blue: #60a5fa; --neon-cyan: #22d3ee;
            --neon-green: #34d399; --neon-yellow: #fbbf24; --neon-red: #f87171;
            --radius-md: 10px; --radius-lg: 14px;
            --glow-purple: 0 0 18px rgba(139, 92, 246, 0.30);
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            background: linear-gradient(rgba(5, 8, 18, 0.88), rgba(6, 9, 20, 0.84)),
                        radial-gradient(circle at 12% 12%, rgba(251, 191, 36, 0.12), transparent 28%),
                        url('theme/original-d5209459af4999984ad44693bbcb28f7.webp') center/cover fixed no-repeat;
            color: var(--text-primary); min-height: 100vh; font-family: "Segoe UI", Arial, sans-serif;
        }

        .page-wrapper { max-width: 1400px; margin: 0 auto; padding: 32px 24px; animation: fadeInUp 0.35s ease both; }

        @keyframes fadeInUp { from { opacity: 0; transform: translateY(16px); } to { opacity: 1; transform: translateY(0); } }

        .page-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 28px; }
        .page-title-group { display: flex; align-items: center; gap: 14px; }
        .page-icon {
            width: 48px; height: 48px; background: linear-gradient(135deg, #d97706, #fbbf24);
            border-radius: var(--radius-md); display: flex; align-items: center; justify-content: center;
            font-size: 22px; box-shadow: 0 0 15px rgba(251,191,36,0.3); flex-shrink: 0; color: #1e1e1e;
        }
        .page-title {
            font-size: 1.7rem; font-weight: 700; letter-spacing: -0.5px;
            background: linear-gradient(90deg, #f2f5ff 0%, var(--neon-yellow) 100%);
            -webkit-background-clip: text; -webkit-text-fill-color: transparent; margin: 0;
        }
        .page-subtitle { color: var(--text-muted); font-size: 0.82rem; margin: 2px 0 0; }

        .header-actions { display: flex; gap: 10px; align-items: center; }

        .btn-dash {
            display: inline-flex; align-items: center; gap: 7px; padding: 9px 18px;
            border-radius: var(--radius-md); font-size: 0.875rem; font-weight: 600;
            border: none; cursor: pointer; text-decoration: none; transition: all 0.2s; white-space: nowrap;
        }
        .btn-dash-ghost { background: rgba(42, 53, 85, 0.55); color: var(--text-muted); border: 1px solid var(--border); }
        .btn-dash-ghost:hover { background: rgba(42, 53, 85, 0.85); color: var(--text-primary); border-color: var(--neon-yellow); }

        .btn-dash-primary {
            background: linear-gradient(135deg, #b45309 0%, #d97706 100%); color: #fff;
            box-shadow: 0 4px 14px rgba(217,119,6,0.35);
        }
        .btn-dash-primary:hover {
            background: linear-gradient(135deg, #d97706 0%, #f59e0b 100%);
            transform: translateY(-1px); box-shadow: 0 6px 20px rgba(245,158,11,0.5); color: #fff;
        }

        .table-card {
            background: rgba(16, 23, 42, 0.82); border: 1px solid var(--border); border-radius: var(--radius-lg);
            overflow: hidden; box-shadow: 0 8px 40px rgba(0,0,0,0.45); backdrop-filter: blur(12px);
        }
        .table-card table { width: 100%; border-collapse: collapse; font-size: 0.875rem; }
        .table-card thead tr { background: rgba(22, 31, 54, 0.95); border-bottom: 1px solid var(--border); }
        .table-card thead th {
            padding: 14px 16px; color: var(--text-muted); font-weight: 600; font-size: 0.75rem;
            letter-spacing: 0.08em; text-transform: uppercase; white-space: nowrap;
        }
        .table-card tbody tr { border-bottom: 1px solid rgba(42, 53, 85, 0.4); transition: background 0.18s; }
        .table-card tbody tr:last-child { border-bottom: none; }
        .table-card tbody tr:hover { background: rgba(251, 191, 36, 0.06); }
        .table-card tbody td { padding: 13px 16px; color: var(--text-primary); vertical-align: middle; }

        .id-badge {
            display: inline-flex; align-items: center; justify-content: center;
            background: rgba(251, 191, 36, 0.12); border: 1px solid rgba(251, 191, 36, 0.25);
            color: var(--neon-yellow); border-radius: 6px; padding: 2px 10px;
            font-size: 0.78rem; font-weight: 700; font-family: monospace; min-width: 36px;
        }

        .status-badge {
            display: inline-flex; align-items: center; gap: 5px; padding: 4px 11px;
            border-radius: 20px; font-size: 0.72rem; font-weight: 700; letter-spacing: 0.05em;
            text-transform: uppercase; white-space: nowrap;
        }
        .status-badge::before { content: ''; width: 6px; height: 6px; border-radius: 50%; display: inline-block; }
        
        .status-planned { background: rgba(96, 165, 250, 0.12); border: 1px solid rgba(96, 165, 250, 0.3); color: var(--neon-blue); }
        .status-planned::before { background: var(--neon-blue); box-shadow: 0 0 6px var(--neon-blue); }

        .status-inprogress { background: rgba(251, 191, 36, 0.12); border: 1px solid rgba(251, 191, 36, 0.3); color: var(--neon-yellow); }
        .status-inprogress::before { background: var(--neon-yellow); box-shadow: 0 0 6px var(--neon-yellow); animation: blink 1.4s infinite; }

        .status-completed { background: rgba(52, 211, 153, 0.12); border: 1px solid rgba(52, 211, 153, 0.3); color: var(--neon-green); }
        .status-completed::before { background: var(--neon-green); }

        @keyframes blink { 0%,100% { opacity:1; } 50% { opacity:0.3; } }

        .action-group { display: flex; gap: 5px; align-items: center; }

        .btn-icon {
            display: inline-flex; align-items: center; justify-content: center;
            width: 32px; height: 32px; border-radius: 7px; border: 1px solid transparent;
            font-size: 14px; cursor: pointer; text-decoration: none; transition: all 0.2s; background: transparent;
        }

        .btn-icon-edit { border-color: rgba(96,165,250,0.3); color: var(--neon-blue); background: rgba(96,165,250,0.08); }
        .btn-icon-edit:hover { background: rgba(96,165,250,0.2); box-shadow: 0 0 10px rgba(96,165,250,0.3); color: var(--neon-blue); }

        .btn-icon-delete { border-color: rgba(248,113,113,0.3); color: var(--neon-red); background: rgba(248,113,113,0.08); }
        .btn-icon-delete:hover { background: rgba(248,113,113,0.2); box-shadow: 0 0 10px rgba(248,113,113,0.3); color: var(--neon-red); }

        .btn-icon-complete { border-color: rgba(52,211,153,0.3); color: var(--neon-green); background: rgba(52,211,153,0.08); }
        .btn-icon-complete:hover { background: rgba(52,211,153,0.2); box-shadow: 0 0 10px rgba(52,211,153,0.3); color: var(--neon-green); }

    </style>
</head>
<body>
<div class="page-wrapper">

    <div class="page-header">
        <div class="page-title-group">
            <div class="page-icon"><i class="bi bi-tools"></i></div>
            <div>
                <h1 class="page-title">Maintenance Schedules</h1>
                <p class="page-subtitle">Manage planned and ongoing network maintenance tasks</p>
            </div>
        </div>
        <div class="header-actions">
            <a class="btn-dash btn-dash-ghost" href="staffDashboard.jsp">
                <i class="bi bi-arrow-left"></i> Dashboard
            </a>
            <a class="btn-dash btn-dash-primary" href="maintenance-form.jsp">
                <i class="bi bi-plus-lg"></i> Schedule Task
            </a>
        </div>
    </div>

    <div class="table-card">
        <div style="overflow-x:auto">
            <table>
                <thead>
                    <tr>
                        <th><i class="bi bi-hash me-1"></i>ID</th>
                        <th><i class="bi bi-card-text me-1"></i>Task Title</th>
                        <th><i class="bi bi-calendar-range me-1"></i>Start Time</th>
                        <th><i class="bi bi-calendar-check me-1"></i>End Time</th>
                        <th><i class="bi bi-activity me-1"></i>Status</th>
                        <th><i class="bi bi-three-dots me-1"></i>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty tasks}">
                            <c:forEach var="task" items="${tasks}">
                                <tr>
                                    <td><span class="id-badge">#${task.maintenanceId}</span></td>
                                    <td>
                                        <div style="font-weight:600;">${task.title}</div>
                                        <div style="font-size:0.75rem; color:var(--text-muted); margin-top:2px; max-width:250px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">
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
                                                <em>Not set</em>
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
                                        <div class="action-group">
                                            <c:if test="${task.status ne 'COMPLETED'}">
                                                <form action="MaintenanceServlet" method="post" style="margin:0;">
                                                    <input type="hidden" name="action" value="markComplete">
                                                    <input type="hidden" name="id" value="${task.maintenanceId}">
                                                    <button type="submit" class="btn-icon btn-icon-complete" title="Mark as Completed" onclick="return confirm('Complete this task?');">
                                                        <i class="bi bi-check-lg"></i>
                                                    </button>
                                                </form>
                                            </c:if>
                                            
                                            <a class="btn-icon btn-icon-edit" href="MaintenanceServlet?action=edit&id=${task.maintenanceId}" title="Edit task">
                                                <i class="bi bi-pencil-fill"></i>
                                            </a>
                                            
                                            <form action="MaintenanceServlet" method="post" style="margin:0;">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="id" value="${task.maintenanceId}">
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
                                <td colspan="6" class="text-center py-5 text-muted">
                                    <i class="bi bi-tools text-secondary" style="font-size:3rem;"></i>
                                    <p class="mt-3">No maintenance tasks scheduled.</p>
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>

</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
