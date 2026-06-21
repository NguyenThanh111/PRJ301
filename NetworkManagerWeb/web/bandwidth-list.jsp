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
    BandwidthUsageDAO dao = new BandwidthUsageDAO();
    ArrayList<BandwidthUsageDTO> usages = dao.ListAll();
    request.setAttribute("usages", usages);

    NetworkDeviceDAO deviceDAO = new NetworkDeviceDAO();
    HashMap<Integer, String> deviceNames = new HashMap<>();
    for (BandwidthUsageDTO usage : usages) {
        if (!deviceNames.containsKey(usage.getDeviceId())) {
            NetworkDeviceDTO dev = deviceDAO.searchById(usage.getDeviceId());
            if (dev != null) {
                deviceNames.put(usage.getDeviceId(), dev.getDeviceName());
            } else {
                deviceNames.put(usage.getDeviceId(), "Unknown Device");
            }
        }
    }
    request.setAttribute("deviceNames", deviceNames);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bandwidth Usage — Network Manager</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
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
            --neon-green: #34d399;
            --neon-red: #f87171;
            --neon-yellow: #fbbf24;
            --radius-md: 10px;
            --radius-lg: 14px;
            --glow-purple: 0 0 18px rgba(139, 92, 246, 0.30);
            --glow-blue: 0 0 18px rgba(96, 165, 250, 0.25);
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            background:
                linear-gradient(rgba(5, 8, 18, 0.88), rgba(6, 9, 20, 0.84)),
                radial-gradient(circle at 12% 12%, rgba(139, 92, 246, 0.16), transparent 28%),
                radial-gradient(circle at 85% 80%, rgba(34, 211, 238, 0.08), transparent 30%),
                url('theme/original-d5209459af4999984ad44693bbcb28f7.webp') center/cover fixed no-repeat;
            color: var(--text-primary);
            min-height: 100vh;
            font-family: "Segoe UI", Arial, sans-serif;
        }

        .page-wrapper {
            max-width: 1400px;
            margin: 0 auto;
            padding: 32px 24px;
            animation: fadeInUp 0.35s ease both;
        }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .page-header {
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 28px; gap: 16px; flex-wrap: wrap;
        }

        .page-title-group { display: flex; align-items: center; gap: 14px; }

        .page-icon {
            width: 48px; height: 48px;
            background: linear-gradient(135deg, var(--neon-purple), var(--neon-blue));
            border-radius: var(--radius-md);
            display: flex; align-items: center; justify-content: center;
            font-size: 22px; box-shadow: var(--glow-purple); flex-shrink: 0;
        }

        .page-title {
            font-size: 1.7rem; font-weight: 700; letter-spacing: -0.5px;
            background: linear-gradient(90deg, #f2f5ff 0%, var(--neon-cyan) 100%);
            -webkit-background-clip: text; -webkit-text-fill-color: transparent; margin: 0;
        }

        .page-subtitle { color: var(--text-muted); font-size: 0.82rem; margin: 2px 0 0; }

        .header-actions { display: flex; gap: 10px; align-items: center; }

        .btn-dash {
            display: inline-flex; align-items: center; gap: 7px; padding: 9px 18px;
            border-radius: var(--radius-md); font-size: 0.875rem; font-weight: 600;
            border: none; cursor: pointer; text-decoration: none; transition: all 0.2s; white-space: nowrap;
        }

        .btn-dash-ghost {
            background: rgba(42, 53, 85, 0.55); color: var(--text-muted); border: 1px solid var(--border);
        }
        .btn-dash-ghost:hover {
            background: rgba(42, 53, 85, 0.85); color: var(--text-primary); border-color: var(--neon-blue);
            box-shadow: 0 0 12px rgba(96,165,250,0.18);
        }

        .btn-dash-primary {
            background: linear-gradient(135deg, var(--neon-purple) 0%, #6d28d9 100%); color: #fff;
            box-shadow: 0 4px 14px rgba(139,92,246,0.35);
        }
        .btn-dash-primary:hover {
            background: linear-gradient(135deg, #a78bfa 0%, var(--neon-purple) 100%);
            transform: translateY(-1px); box-shadow: 0 6px 20px rgba(139,92,246,0.5); color: #fff;
        }

        .table-card {
            background: rgba(16, 23, 42, 0.82); border: 1px solid var(--border);
            border-radius: var(--radius-lg); overflow: hidden;
            box-shadow: 0 8px 40px rgba(0,0,0,0.45), var(--glow-purple); backdrop-filter: blur(12px);
        }

        .table-card table { width: 100%; border-collapse: collapse; font-size: 0.875rem; }
        .table-card thead tr { background: rgba(22, 31, 54, 0.95); border-bottom: 1px solid var(--border); }
        .table-card thead th {
            padding: 14px 16px; color: var(--text-muted); font-weight: 600; font-size: 0.75rem;
            letter-spacing: 0.08em; text-transform: uppercase; white-space: nowrap;
        }
        .table-card tbody tr { border-bottom: 1px solid rgba(42, 53, 85, 0.4); transition: background 0.18s; }
        .table-card tbody tr:last-child { border-bottom: none; }
        .table-card tbody tr:hover { background: rgba(139, 92, 246, 0.06); }
        .table-card tbody td { padding: 13px 16px; color: var(--text-primary); vertical-align: middle; }

        .id-badge {
            display: inline-flex; align-items: center; justify-content: center;
            background: rgba(96, 165, 250, 0.12); border: 1px solid rgba(96, 165, 250, 0.25);
            color: var(--neon-blue); border-radius: 6px; padding: 2px 10px;
            font-size: 0.78rem; font-weight: 700; font-family: monospace; min-width: 36px;
        }

        .mono {
            font-family: 'Courier New', monospace; font-size: 0.9rem; color: var(--neon-green);
            background: rgba(52,211,153,0.1); border-radius: 5px; padding: 2px 7px; display: inline-block;
        }
        
        .mono-down {
            color: var(--neon-cyan); background: rgba(34,211,238,0.1);
        }

        .action-group { display: flex; gap: 5px; align-items: center; }

        .btn-icon {
            display: inline-flex; align-items: center; justify-content: center;
            width: 32px; height: 32px; border-radius: 7px; border: 1px solid transparent;
            font-size: 14px; cursor: pointer; text-decoration: none; transition: all 0.2s; background: transparent;
        }

        .btn-icon-delete {
            border-color: rgba(248,113,113,0.3); color: var(--neon-red); background: rgba(248,113,113,0.08);
        }
        .btn-icon-delete:hover {
            background: rgba(248,113,113,0.2); box-shadow: 0 0 10px rgba(248,113,113,0.3); color: var(--neon-red);
        }

        .empty-state { padding: 64px 24px; text-align: center; }
        .empty-state i { font-size: 48px; color: var(--border); display: block; margin-bottom: 14px; }
        .empty-state p { color: var(--text-muted); margin: 0; font-size: 0.9rem; }
        
        .device-name {
            display: flex; align-items: center; gap: 9px;
        }
        .device-name .ri {
            width: 30px; height: 30px;
            background: linear-gradient(135deg, rgba(139,92,246,0.2), rgba(96,165,250,0.2));
            border: 1px solid rgba(139,92,246,0.3); border-radius: 7px;
            display: flex; align-items: center; justify-content: center;
            font-size: 14px; color: var(--neon-purple); flex-shrink: 0;
        }
    </style>
</head>
<body>
<div class="page-wrapper">

    <div class="page-header">
        <div class="page-title-group">
            <div class="page-icon"><i class="bi bi-speedometer"></i></div>
            <div>
                <h1 class="page-title">Bandwidth Usage</h1>
                <p class="page-subtitle">Monitor upload/download speeds of devices</p>
            </div>
        </div>
        <div class="header-actions">
            <a class="btn-dash btn-dash-ghost" href="staffDashboard.jsp">
                <i class="bi bi-arrow-left"></i> Dashboard
            </a>
            <a class="btn-dash btn-dash-primary" href="bandwidth-form.jsp">
                <i class="bi bi-plus-lg"></i> Run Speed Test
            </a>
        </div>
    </div>

    <div class="table-card">
        <div style="overflow-x:auto">
            <table>
                <thead>
                    <tr>
                        <th><i class="bi bi-hash me-1"></i>ID</th>
                        <th><i class="bi bi-laptop me-1"></i>Device</th>
                        <th><i class="bi bi-cloud-arrow-up me-1"></i>Upload Speed</th>
                        <th><i class="bi bi-cloud-arrow-down me-1"></i>Download Speed</th>
                        <th><i class="bi bi-clock me-1"></i>Record Time</th>
                        <th><i class="bi bi-three-dots me-1"></i>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty usages}">
                            <c:forEach var="item" items="${usages}">
                                <tr>
                                    <td><span class="id-badge">#${item.usageId}</span></td>
                                    <td>
                                        <div class="device-name">
                                            <div class="ri"><i class="bi bi-hdd-network-fill"></i></div>
                                            <span>
                                                <c:out value="${deviceNames[item.deviceId]}" default="Device ${item.deviceId}" />
                                                <span style="font-size:0.75rem; color:var(--text-muted); margin-left:5px;">(ID: ${item.deviceId})</span>
                                            </span>
                                        </div>
                                    </td>
                                    <td><span class="mono"><fmt:formatNumber value="${item.uploadSpeed}" maxFractionDigits="2"/> Mbps</span></td>
                                    <td><span class="mono mono-down"><fmt:formatNumber value="${item.downloadSpeed}" maxFractionDigits="2"/> Mbps</span></td>
                                    <td style="color:var(--text-muted)"><fmt:formatDate value="${item.recordTime}" pattern="yyyy-MM-dd HH:mm:ss" /></td>
                                    <td>
                                        <div class="action-group">
                                            <form action="BandwidthServlet" method="post" style="display:inline;">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="usageId" value="${item.usageId}">
                                                <button type="submit" class="btn-icon btn-icon-delete" title="Delete record" onclick="return confirm('Delete this record?')">
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
                                <td colspan="6">
                                    <div class="empty-state">
                                        <i class="bi bi-bar-chart-line"></i>
                                        <p>No bandwidth usage records found. Run a new speed test to get started.</p>
                                    </div>
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
