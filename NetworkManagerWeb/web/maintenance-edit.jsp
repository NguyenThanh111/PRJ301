<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@page import="Models.RouterDAO"%>
<%@page import="Models.RouterDTO"%>
<%@page import="Models.AccessPointDAO"%>
<%@page import="Models.AccessPointDTO"%>
<%@page import="Models.SwitchDAO"%>
<%@page import="Models.SwitchDTO"%>
<%@page import="java.util.ArrayList"%>
<%
    RouterDAO routerDAO = new RouterDAO();
    ArrayList<RouterDTO> routers = routerDAO.ListAll();
    request.setAttribute("routers", routers);

    AccessPointDAO apDAO = new AccessPointDAO();
    ArrayList<AccessPointDTO> aps = apDAO.ListAll();
    request.setAttribute("aps", aps);

    SwitchDAO switchDAO = new SwitchDAO();
    ArrayList<SwitchDTO> switches = switchDAO.ListAll();
    request.setAttribute("switches", switches);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Schedule Maintenance — Network Manager</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root {
            --bg-0: #05070d; --bg-1: #0b1020; --surface: #10172a; --surface-2: #161f36; --border: #2a3555;
            --text-primary: #f2f5ff; --text-muted: #9aa6c7;
            --neon-purple: #8b5cf6; --neon-pink: #d946ef; --neon-blue: #60a5fa; --neon-cyan: #22d3ee;
            --neon-green: #34d399; --neon-yellow: #fbbf24;
            --radius-md: 10px; --radius-lg: 14px;
            --glow-yellow: 0 0 18px rgba(251, 191, 36, 0.25);
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            background: linear-gradient(rgba(5, 8, 18, 0.88), rgba(6, 9, 20, 0.84)),
                        radial-gradient(circle at 12% 12%, rgba(251, 191, 36, 0.12), transparent 28%),
                        url('theme/original-d5209459af4999984ad44693bbcb28f7.webp') center/cover fixed no-repeat;
            color: var(--text-primary); min-height: 100vh; font-family: "Segoe UI", Arial, sans-serif;
        }

        .page-wrapper { max-width: 900px; margin: 0 auto; padding: 40px 24px; animation: fadeInUp 0.35s ease both; }

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

        .form-card {
            background: rgba(16, 23, 42, 0.82); border: 1px solid var(--border);
            border-radius: var(--radius-lg); padding: 32px;
            box-shadow: 0 8px 40px rgba(0,0,0,0.45), var(--glow-yellow); backdrop-filter: blur(12px);
        }

        .form-label { color: #d8c9ff; font-size: 0.85rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 8px; }

        .form-control, .form-select {
            background: rgba(11, 16, 32, 0.8); border: 1px solid var(--border);
            color: var(--text-primary); border-radius: 8px; padding: 12px 16px; font-size: 0.95rem;
        }
        .form-control:focus, .form-select:focus {
            background: rgba(16, 23, 42, 0.9); border-color: var(--neon-yellow);
            box-shadow: 0 0 0 3px rgba(251, 191, 36, 0.2); color: var(--text-primary);
        }
        .form-control::placeholder { color: #5a6b9a; }
        .form-select option { background: #0b1020; color: #fff; }

        .device-checkbox-grid {
            display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 12px;
            max-height: 250px; overflow-y: auto; padding-right: 10px;
        }

        .device-card {
            border: 1px solid var(--border); border-radius: 8px; padding: 10px 14px;
            background: rgba(22, 31, 54, 0.5); display: flex; align-items: center; gap: 10px;
            cursor: pointer; transition: all 0.2s;
        }
        .device-card:hover { border-color: var(--neon-yellow); background: rgba(251, 191, 36, 0.05); }

        .form-check-input {
            background-color: rgba(11, 16, 32, 0.8); border-color: var(--border); width: 1.2em; height: 1.2em;
        }
        .form-check-input:checked { background-color: var(--neon-yellow); border-color: var(--neon-yellow); }
        .form-check-input:focus { box-shadow: 0 0 0 0.25rem rgba(251, 191, 36, 0.25); border-color: var(--neon-yellow); }

        .form-actions {
            display: flex; gap: 14px; margin-top: 32px; padding-top: 24px; border-top: 1px solid var(--border); justify-content: flex-end;
        }

        .btn-dash {
            display: inline-flex; align-items: center; gap: 7px; padding: 10px 24px;
            border-radius: 8px; font-size: 0.95rem; font-weight: 600;
            border: none; cursor: pointer; text-decoration: none; transition: all 0.2s; white-space: nowrap;
        }
        .btn-dash-ghost { background: rgba(42, 53, 85, 0.55); color: var(--text-muted); border: 1px solid var(--border); }
        .btn-dash-ghost:hover { background: rgba(42, 53, 85, 0.85); color: var(--text-primary); border-color: var(--neon-yellow); }

        .btn-dash-primary { background: linear-gradient(135deg, #b45309 0%, #d97706 100%); color: #fff; box-shadow: 0 4px 14px rgba(217,119,6,0.35); }
        .btn-dash-primary:hover { background: linear-gradient(135deg, #d97706 0%, #f59e0b 100%); transform: translateY(-1px); box-shadow: 0 6px 20px rgba(245,158,11,0.5); color: #fff; }

        /* Custom Scrollbar */
        ::-webkit-scrollbar { width: 8px; }
        ::-webkit-scrollbar-track { background: rgba(16, 23, 42, 0.5); border-radius: 4px; }
        ::-webkit-scrollbar-thumb { background: rgba(85, 95, 125, 0.8); border-radius: 4px; }
        ::-webkit-scrollbar-thumb:hover { background: rgba(115, 125, 155, 1); }
    </style>
</head>
<body>
<div class="page-wrapper">

    <div class="page-header">
        <div class="page-title-group">
            <div class="page-icon"><i class="bi bi-tools"></i></div>
            <div>
                <h1 class="page-title">Edit Maintenance Task</h1>
                <p class="page-subtitle">Update an existing planned maintenance task</p>
            </div>
        </div>
    </div>

    <div class="form-card">
        <form action="MainController" method="post" id="maintenanceForm">
            <input type="hidden" name="action" value="maintenanceUpdate">
            <input type="hidden" name="maintenanceId" value="${schedule.maintenanceId}">
            
            <div class="mb-4">
                <label class="form-label">Task Title <span class="text-danger">*</span></label>
                <input type="text" class="form-control" name="title" value="${schedule.title}" placeholder="e.g., Firmware Upgrade Floor 2" required>
            </div>

            <div class="mb-4">
                <label class="form-label">Description</label>
                <textarea class="form-control" name="description" rows="3" placeholder="Provide details about the maintenance task...">${schedule.description}</textarea>
            </div>

            <div class="row mb-4">
                <div class="col-md-6">
                    <label class="form-label">Start Time <span class="text-danger">*</span></label>
                    <input type="datetime-local" class="form-control" name="startTime" id="startTime" value="<fmt:formatDate value='${schedule.startTime}' pattern='yyyy-MM-dd\'T\'HH:mm'/>" required>
                </div>
                <div class="col-md-6">
                    <label class="form-label">End Time (Estimated)</label>
                    <input type="datetime-local" class="form-control" name="endTime" id="endTime" value="<fmt:formatDate value='${schedule.endTime}' pattern='yyyy-MM-dd\'T\'HH:mm'/>">
                </div>
            </div>
            
            <div class="mb-4">
                <label class="form-label">Status</label>
                <select class="form-select" name="status">
                    <option value="PLANNED" ${schedule.status == 'PLANNED' ? 'selected' : ''}>Planned</option>
                    <option value="IN_PROGRESS" ${schedule.status == 'IN_PROGRESS' ? 'selected' : ''}>In Progress</option>
                    <option value="COMPLETED" ${schedule.status == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                    <option value="CANCELED" ${schedule.status == 'CANCELED' ? 'selected' : ''}>Canceled</option>
                </select>
            </div>

            <hr style="border-color: var(--border); margin: 30px 0;">

            <h5 style="color:var(--text-primary); font-weight:600; margin-bottom: 20px;">Target Devices</h5>
            
            <ul class="nav nav-tabs mb-3" style="border-bottom-color: var(--border);">
                <li class="nav-item"><a class="nav-link active" data-bs-toggle="tab" href="#routers" style="background:transparent; border-color:var(--border) var(--border) transparent; color:var(--neon-yellow); font-weight:600;"><i class="bi bi-router me-2"></i>Routers</a></li>
                <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#aps" style="color:var(--text-muted); border-color:transparent;"><i class="bi bi-reception-4 me-2"></i>Access Points</a></li>
                <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#switches" style="color:var(--text-muted); border-color:transparent;"><i class="bi bi-hdd-network me-2"></i>Switches</a></li>
            </ul>

            <div class="tab-content">
                <!-- Routers Tab -->
                <div class="tab-pane fade show active" id="routers">
                    <div class="device-checkbox-grid">
                        <c:forEach var="router" items="${routers}">
                            <label class="device-card">
                                <input class="form-check-input mt-0" type="checkbox" name="routerIds" value="${router.routerId}">
                                <div style="font-size:0.85rem;">
                                    <div style="font-weight:600; color:var(--text-primary);">${router.routerName}</div>
                                    <div style="color:var(--text-muted); font-size:0.75rem;">${router.ipAddress}</div>
                                </div>
                            </label>
                        </c:forEach>
                        <c:if test="${empty routers}">
                            <div class="text-muted p-3">No routers available.</div>
                        </c:if>
                    </div>
                </div>
                
                <!-- Access Points Tab -->
                <div class="tab-pane fade" id="aps">
                    <div class="device-checkbox-grid">
                        <c:forEach var="ap" items="${aps}">
                            <label class="device-card">
                                <input class="form-check-input mt-0" type="checkbox" name="apIds" value="${ap.apId}">
                                <div style="font-size:0.85rem;">
                                    <div style="font-weight:600; color:var(--text-primary);">${ap.apName}</div>
                                    <div style="color:var(--text-muted); font-size:0.75rem;">${ap.ipAddress}</div>
                                </div>
                            </label>
                        </c:forEach>
                        <c:if test="${empty aps}">
                            <div class="text-muted p-3">No access points available.</div>
                        </c:if>
                    </div>
                </div>

                <!-- Switches Tab -->
                <div class="tab-pane fade" id="switches">
                    <div class="device-checkbox-grid">
                        <c:forEach var="sw" items="${switches}">
                            <label class="device-card">
                                <input class="form-check-input mt-0" type="checkbox" name="switchIds" value="${sw.switchId}">
                                <div style="font-size:0.85rem;">
                                    <div style="font-weight:600; color:var(--text-primary);">${sw.switchName}</div>
                                    <div style="color:var(--text-muted); font-size:0.75rem;">${sw.ipAddress}</div>
                                </div>
                            </label>
                        </c:forEach>
                        <c:if test="${empty switches}">
                            <div class="text-muted p-3">No switches available.</div>
                        </c:if>
                    </div>
                </div>
            </div>

            <div class="form-actions">
                <a href="staffDashboard.jsp?page=maintenance" class="btn-dash btn-dash-ghost">Cancel</a>
                <button type="submit" class="btn-dash btn-dash-primary">
                    <i class="bi bi-save2"></i> Update Task
                </button>
            </div>
        </form>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Validation script
    document.getElementById('maintenanceForm').addEventListener('submit', function(e) {
        var start = document.getElementById('startTime').value;
        var end = document.getElementById('endTime').value;
        if(start && end) {
            if(new Date(end) < new Date(start)) {
                e.preventDefault();
                alert('Error: End Time cannot be earlier than Start Time!');
            }
        }
    });

    // Simple script to toggle colors on active tabs
    document.querySelectorAll('.nav-link').forEach(link => {
        link.addEventListener('click', function() {
            document.querySelectorAll('.nav-link').forEach(l => {
                l.style.color = 'var(--text-muted)';
                l.style.borderColor = 'transparent';
                l.style.background = 'transparent';
                l.style.fontWeight = 'normal';
            });
            this.style.color = 'var(--neon-yellow)';
            this.style.borderColor = 'var(--border) var(--border) transparent';
            this.style.fontWeight = '600';
        });
    });
</script>
</body>
</html>
