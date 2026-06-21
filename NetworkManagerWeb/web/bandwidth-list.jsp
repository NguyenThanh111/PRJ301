<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@page import="Models_DAO.BandwidthUsageDAO"%>
<%@page import="Models.BandwidthUsageDTO"%>
<%@page import="Models_DAO.NetworkDeviceDAO"%>
<%@page import="Models.NetworkDeviceDTO"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.HashMap"%>
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

    BandwidthUsageDAO dao = new BandwidthUsageDAO();
    ArrayList<BandwidthUsageDTO> usages = dao.ListAll();
    request.setAttribute("usages", usages);

    NetworkDeviceDAO deviceDAO = new NetworkDeviceDAO();
    HashMap<Integer, String> deviceNames = new HashMap<>();
    int totalDevices = 0;
    double totalDown = 0;
    double totalUp = 0;

    for (BandwidthUsageDTO usage : usages) {
        if (!deviceNames.containsKey(usage.getDeviceId())) {
            NetworkDeviceDTO dev = deviceDAO.searchById(usage.getDeviceId());
            if (dev != null) {
                deviceNames.put(usage.getDeviceId(), dev.getDeviceName());
            } else {
                deviceNames.put(usage.getDeviceId(), "Unknown Device");
            }
            totalDevices++;
        }
        totalDown += usage.getDownloadSpeed();
        totalUp += usage.getUploadSpeed();
    }
    
    int recordCount = usages.size();
    double avgDown = recordCount > 0 ? totalDown / recordCount : 0;
    double avgUp = recordCount > 0 ? totalUp / recordCount : 0;

    request.setAttribute("deviceNames", deviceNames);
    request.setAttribute("totalDevices", totalDevices);
    request.setAttribute("recordCount", recordCount);
    request.setAttribute("avgDown", avgDown);
    request.setAttribute("avgUp", avgUp);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bandwidth Usage — Network Manager</title>
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
            --glow: 0 0 18px rgba(139, 92, 246, .22);
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            background: linear-gradient(rgba(5, 8, 18, .88), rgba(6, 9, 20, .84)),
                        radial-gradient(circle at 12% 12%, rgba(139, 92, 246, .16), transparent 28%),
                        url('theme/original-d5209459af4999984ad44693bbcb28f7.webp') center/cover fixed no-repeat;
            color: var(--text-primary); min-height: 100vh; font-family: "Segoe UI", Arial, sans-serif;
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
        .stat-card:hover { border-color: rgba(139, 92, 246, .55); }
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

        .chart-wrap { position: relative; height: 300px; width: 100%; }

        .rt-table { width: 100%; border-collapse: collapse; font-size: .82rem; }
        .rt-table thead tr { background: rgba(22, 31, 54, .95); border-bottom: 1px solid var(--border); }
        .rt-table thead th {
            padding: 11px 14px; color: var(--text-muted); font-weight: 600; font-size: .7rem;
            letter-spacing: .08em; text-transform: uppercase; white-space: nowrap;
        }
        .rt-table tbody tr { border-bottom: 1px solid rgba(42, 53, 85, .35); transition: background .15s; }
        .rt-table tbody tr:hover { background: rgba(139, 92, 246, .06); }
        .rt-table tbody td { padding: 11px 14px; color: var(--text-primary); vertical-align: middle; }

        .rt-id {
            display: inline-flex; align-items: center; justify-content: center; background: rgba(96, 165, 250, .1);
            border: 1px solid rgba(96, 165, 250, .22); color: #60a5fa; border-radius: 5px; padding: 1px 8px;
            font-size: .72rem; font-weight: 700; font-family: monospace;
        }

        .mono-down { font-family: 'Courier New', monospace; font-size: .78rem; color: #22d3ee; background: rgba(34, 211, 238, .07); border-radius: 4px; padding: 1px 6px; display: inline-block; }
        .mono-up { font-family: 'Courier New', monospace; font-size: .78rem; color: #8b5cf6; background: rgba(139, 92, 246, .1); border-radius: 4px; padding: 1px 6px; display: inline-block; }

        .btn-theme {
            border: 1px solid rgba(139, 92, 246, .5); background: rgba(139, 92, 246, .2); color: #e8ddff;
            border-radius: 8px; padding: 7px 14px; font-size: 13px; font-weight: 600; cursor: pointer;
            transition: all .18s; display: inline-flex; align-items: center; gap: 6px; text-decoration: none;
        }
        .btn-theme:hover { background: rgba(139, 92, 246, .35); filter: brightness(1.1); color: #fff; }

        .btn-icon-delete {
            border: 1px solid rgba(248,113,113,0.3); color: var(--neon-red); background: rgba(248,113,113,0.08);
            border-radius: 6px; padding: 4px 8px; cursor: pointer; transition: 0.2s;
        }
        .btn-icon-delete:hover { background: rgba(248,113,113,0.2); box-shadow: 0 0 10px rgba(248,113,113,0.3); }

        @media (max-width: 900px) { .sidebar { display: none; } .main-content { margin-left: 0; } }
    </style>
</head>
<body>

    <c:set var="sidebarActive" value="bandwidth" scope="request" />
    <%@include file="sidebar.jsp" %>

    <div class="main-content">
        <div class="topbar">
            <div>
                <span class="topbar-title">Bandwidth Usage</span>
                <span class="topbar-breadcrumb">/ Monitoring</span>
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
                        <div class="stat-icon" style="background:rgba(139,92,246,.15);color:#8b5cf6;"><i class="bi bi-hdd-network"></i></div>
                        <div class="stat-value" style="color:#c4b5fd;">${totalDevices}</div>
                        <div class="stat-label">Total Devices Logged</div>
                        <div class="stat-delta" style="color:var(--text-muted);">Unique devices</div>
                    </div>
                </div>
                <div class="col-6 col-lg-3">
                    <div class="stat-card">
                        <div class="stat-icon" style="background:rgba(34,211,238,.12);color:#22d3ee;"><i class="bi bi-file-earmark-text"></i></div>
                        <div class="stat-value" style="color:#67e8f9;">${recordCount}</div>
                        <div class="stat-label">Total Speed Records</div>
                        <div class="stat-delta" style="color:var(--text-muted);">All time</div>
                    </div>
                </div>
                <div class="col-6 col-lg-3">
                    <div class="stat-card">
                        <div class="stat-icon" style="background:rgba(52,211,153,.12);color:#34d399;"><i class="bi bi-cloud-arrow-down"></i></div>
                        <div class="stat-value" style="color:#6ee7b7;"><fmt:formatNumber value="${avgDown}" maxFractionDigits="1"/></div>
                        <div class="stat-label">Avg Download (Mbps)</div>
                        <div class="stat-delta" style="color:var(--text-muted);">Across all records</div>
                    </div>
                </div>
                <div class="col-6 col-lg-3">
                    <div class="stat-card">
                        <div class="stat-icon" style="background:rgba(251,191,36,.12);color:#fbbf24;"><i class="bi bi-cloud-arrow-up"></i></div>
                        <div class="stat-value" style="color:#fde68a;"><fmt:formatNumber value="${avgUp}" maxFractionDigits="1"/></div>
                        <div class="stat-label">Avg Upload (Mbps)</div>
                        <div class="stat-delta" style="color:var(--text-muted);">Across all records</div>
                    </div>
                </div>
            </div>

            <!-- Chart Row -->
            <div class="row g-3 mb-3">
                <div class="col-12">
                    <div class="section-card h-100">
                        <div class="section-card-header">
                            <h6><i class="bi bi-graph-up me-2" style="color:var(--neon-cyan);"></i>Global Bandwidth Trend</h6>
                        </div>
                        <div class="section-card-body">
                            <div class="chart-wrap">
                                <canvas id="bandwidthChart"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Table Row -->
            <div class="section-card">
                <div class="section-card-header">
                    <h6><i class="bi bi-table me-2" style="color:var(--neon-purple);"></i>Detailed Speed Records</h6>
                    <a href="bandwidth-form.jsp" class="btn-theme"><i class="bi bi-plus-lg"></i> Run Test</a>
                </div>
                <div class="section-card-body p-0" style="overflow-x:auto;">
                    <table class="rt-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Device</th>
                                <th>Upload Speed</th>
                                <th>Download Speed</th>
                                <th>Record Time</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty usages}">
                                    <c:forEach var="item" items="${usages}">
                                        <tr>
                                            <td><span class="rt-id">#${item.usageId}</span></td>
                                            <td>
                                                <i class="bi bi-laptop me-2" style="color:var(--neon-purple);"></i>
                                                <c:out value="${deviceNames[item.deviceId]}" default="Device ${item.deviceId}" />
                                                <span style="font-size:0.75rem; color:var(--text-muted); margin-left:5px;">(ID: ${item.deviceId})</span>
                                            </td>
                                            <td><span class="mono-up"><fmt:formatNumber value="${item.uploadSpeed}" maxFractionDigits="2"/> Mbps</span></td>
                                            <td><span class="mono-down"><fmt:formatNumber value="${item.downloadSpeed}" maxFractionDigits="2"/> Mbps</span></td>
                                            <td style="color:var(--text-muted)"><fmt:formatDate value="${item.recordTime}" pattern="yyyy-MM-dd HH:mm:ss" /></td>
                                            <td>
                                                <form action="BandwidthServlet" method="post" style="display:inline;">
                                                    <input type="hidden" name="action" value="bandwidthDelete">
                                                    <input type="hidden" name="usageId" value="${item.usageId}">
                                                    <button type="submit" class="btn-icon-delete" title="Delete record" onclick="return confirm('Delete this record?')">
                                                        <i class="bi bi-trash3-fill"></i>
                                                    </button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="6" style="text-align:center; padding: 40px; color:var(--text-muted);">
                                            <i class="bi bi-inbox fs-1 mb-2 d-block"></i> No bandwidth usage records found.
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
        const chartLabels = [];
        const downloadData = [];
        const uploadData = [];
        
        <c:forEach var="item" items="${usages}" varStatus="status">
            // Reverse order to show oldest to newest left to right
            chartLabels.unshift('<fmt:formatDate value="${item.recordTime}" pattern="MM/dd HH:mm"/>');
            downloadData.unshift(${item.downloadSpeed});
            uploadData.unshift(${item.uploadSpeed});
        </c:forEach>

        // Initialize Chart.js
        const ctx = document.getElementById('bandwidthChart').getContext('2d');
        
        // Gradient for Download (Cyan)
        const gradDown = ctx.createLinearGradient(0, 0, 0, 300);
        gradDown.addColorStop(0, 'rgba(34, 211, 238, 0.4)');
        gradDown.addColorStop(1, 'rgba(34, 211, 238, 0.01)');
        
        // Gradient for Upload (Purple)
        const gradUp = ctx.createLinearGradient(0, 0, 0, 300);
        gradUp.addColorStop(0, 'rgba(139, 92, 246, 0.4)');
        gradUp.addColorStop(1, 'rgba(139, 92, 246, 0.01)');

        new Chart(ctx, {
            type: 'line',
            data: {
                labels: chartLabels,
                datasets: [
                    {
                        label: 'Download Speed (Mbps)',
                        data: downloadData,
                        borderColor: '#22d3ee',
                        backgroundColor: gradDown,
                        borderWidth: 2,
                        pointBackgroundColor: '#10172a',
                        pointBorderColor: '#22d3ee',
                        pointHoverBackgroundColor: '#22d3ee',
                        pointRadius: 3,
                        pointHoverRadius: 6,
                        fill: true,
                        tension: 0.4
                    },
                    {
                        label: 'Upload Speed (Mbps)',
                        data: uploadData,
                        borderColor: '#8b5cf6',
                        backgroundColor: gradUp,
                        borderWidth: 2,
                        pointBackgroundColor: '#10172a',
                        pointBorderColor: '#8b5cf6',
                        pointHoverBackgroundColor: '#8b5cf6',
                        pointRadius: 3,
                        pointHoverRadius: 6,
                        fill: true,
                        tension: 0.4
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                interaction: { mode: 'index', intersect: false },
                plugins: {
                    legend: { labels: { color: '#9aa6c7', font: { family: "'Segoe UI', sans-serif" } } },
                    tooltip: {
                        backgroundColor: 'rgba(15, 23, 42, 0.9)',
                        titleColor: '#fff',
                        bodyColor: '#e2e8f0',
                        borderColor: 'rgba(139, 92, 246, 0.3)',
                        borderWidth: 1,
                        padding: 10,
                        cornerRadius: 8
                    }
                },
                scales: {
                    x: {
                        grid: { color: 'rgba(42, 53, 85, 0.4)', drawBorder: false },
                        ticks: { color: '#7f8db4', maxTicksLimit: 12 }
                    },
                    y: {
                        grid: { color: 'rgba(42, 53, 85, 0.4)', drawBorder: false },
                        ticks: { color: '#7f8db4' },
                        beginAtZero: true
                    }
                }
            }
        });
    </script>
</body>
</html>
