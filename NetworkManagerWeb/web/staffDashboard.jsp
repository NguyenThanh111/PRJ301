<%-- staffDashboard.jsp - Dashboard for staff members --%>
    <%@page import="Models_DAO.VLANDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
    <%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
        <%@page import="Models_DAO.RouterDAO" %>
        <%@page import="Models.RouterDTO" %>
        <%@page import="Models_DAO.BandwidthUsageDAO" %>
        <%@page import="Models.BandwidthUsageDTO" %>
        <%@page import="Models_DAO.NetworkDeviceDAO" %>
        <%@page import="Models.NetworkDeviceDTO" %>
        <%@page import="Models_DAO.MaintenanceScheduleDAO" %>
        <%@page import="Models.MaintenanceScheduleDTO" %>
        <%@page import="Models_DAO.RoomDAO" %>
        <%@page import="Models.RoomDTO" %>
        <%@page import="Models_DAO.VLANDAO" %> 
        <%@page import="Models.VLANDTO" %>
        <%@page import="Models_DAO.SupportTicketDAO" %>
        <%@page import="Models.SupportTicketDTO" %>
        <%@page import="Models_DAO.IPAddressManagementDAO" %>
        <%@page import="Models.IPAddressManagementDTO" %>
        <%@page import="java.util.ArrayList" %>
        <%@page import="java.util.HashMap" %>
        <%@page import="java.text.SimpleDateFormat" %>
        <c:set var="currentUser" value="${sessionScope.user}" />
        <c:set var="role" value="${sessionScope.role}" />
        <c:set var="roleLower" value="${fn:toLowerCase(role)}" />
        <c:if test="${empty currentUser || empty role || (roleLower ne 'admin' && roleLower ne 'technician')}">
            <c:remove var="user" scope="session"/>
            <c:remove var="role" scope="session"/>
            <c:redirect url="login.jsp" />
        </c:if>
        <c:set var="displayName" value="${empty currentUser.fullName ? currentUser.userName : currentUser.fullName}" />
        <c:set var="isAdmin" value="${roleLower eq 'admin'}" />
        <%
            RouterDAO routerDAO = new RouterDAO();
            ArrayList<RouterDTO> routerList = routerDAO.ListAll();
            
            BandwidthUsageDAO bandwidthDAO = new BandwidthUsageDAO();
            ArrayList<BandwidthUsageDTO> bandwidthList = bandwidthDAO.ListAll();
            request.setAttribute("usages", bandwidthList);
            
            NetworkDeviceDAO deviceDAO = new NetworkDeviceDAO();
            HashMap<Integer, String> deviceNames = new HashMap<>();
            for (BandwidthUsageDTO usage : bandwidthList) {
                if (!deviceNames.containsKey(usage.getDeviceId())) {
                    NetworkDeviceDTO dev = deviceDAO.searchById(usage.getDeviceId());
                    deviceNames.put(usage.getDeviceId(), dev != null ? dev.getDeviceName() : "Unknown");
                }
            }
            request.setAttribute("deviceNames", deviceNames);
            
            MaintenanceScheduleDAO maintenanceDAO = new MaintenanceScheduleDAO();
            ArrayList<MaintenanceScheduleDTO> tasks = maintenanceDAO.ListAll();
            request.setAttribute("tasks", tasks);
        %>
        <%
            RoomDAO roomDAO = new RoomDAO();
            ArrayList<RoomDTO> roomList = roomDAO.ListAll();
        %>
        <% VLANDAO vlanDAO = new VLANDAO();
        ArrayList<VLANDTO> vlanList = vlanDAO.ListAll(); %>
        <% SupportTicketDAO ticketDAO = new SupportTicketDAO();
        ArrayList<SupportTicketDTO> ticketList = ticketDAO.ListAll();
        SimpleDateFormat ticketDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm"); %>
        <% IPAddressManagementDAO ipDAO = new IPAddressManagementDAO();
        ArrayList<IPAddressManagementDTO> ipList = ipDAO.ListAll();
        ArrayList<NetworkDeviceDTO> availableIpDevices = new ArrayList<>();
        ArrayList<NetworkDeviceDTO> allDevicesForIp = deviceDAO.ListAll();
        for (NetworkDeviceDTO device : allDevicesForIp) {
            if (device != null
                    && device.getDeviceId() > 0
                    && ipDAO.findByDevice(device.getDeviceId()) == null) {
                availableIpDevices.add(device);
            }
        } %>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Network Manager — Staff Dashboard</title>
                    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
                        rel="stylesheet">
                    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"
                        rel="stylesheet">
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
                            --sidebar-w: 260px;
                            --radius-md: 10px;
                            --radius-lg: 14px;
                            --glow: 0 0 18px rgba(139, 92, 246, 0.22);
                        }

                        * {
                            box-sizing: border-box;
                        }

                        html {
                            background-color: var(--bg-0);
                        }

                        body {
                            margin: 0;
                            background:
                                linear-gradient(rgba(5, 8, 18, 0.82), rgba(6, 9, 20, 0.78)),
                                radial-gradient(circle at 12% 12%, rgba(139, 92, 246, 0.16), transparent 28%),
                                url('theme/original-d5209459af4999984ad44693bbcb28f7.webp') center/cover fixed no-repeat;
                            background-color: var(--bg-0);
                            color: var(--text-primary);
                            min-height: 100vh;
                            font-family: "Segoe UI", Arial, sans-serif;
                        }

                        .sidebar {
                            position: fixed;
                            inset: 0 auto 0 0;
                            width: var(--sidebar-w);
                            background: linear-gradient(180deg, rgba(16, 23, 42, 0.96), rgba(10, 14, 28, 0.98));
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
                            line-height: 1.1;
                            font-size: 13px;
                            font-weight: 700;
                            letter-spacing: .04em;
                            text-transform: uppercase;
                            color: #d8c9ff;
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
                            background: rgba(139, 92, 246, 0.12);
                            color: #e5ddff;
                        }

                        .nav-item-link.active {
                            background: linear-gradient(90deg, rgba(139, 92, 246, 0.3), rgba(217, 70, 239, 0.08));
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
                            background: rgba(12, 17, 32, 0.9);
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
                            background: rgba(239, 68, 68, 0.16);
                            border: 1px solid rgba(239, 68, 68, 0.4);
                        }

                        .role-badge-tech {
                            color: #ddd6fe;
                            background: rgba(139, 92, 246, 0.16);
                            border: 1px solid rgba(139, 92, 246, 0.4);
                        }

                        .premium-btn {
                            display: inline-flex;
                            align-items: center;
                            gap: 7px;
                            padding: 8px 14px;
                            border-radius: 10px;
                            color: #fff;
                            text-decoration: none;
                            font-size: 13px;
                            font-weight: 800;
                            background: linear-gradient(135deg, #f59e0b, #d946ef 58%, #8b5cf6);
                            border: 1px solid rgba(253, 224, 71, 0.35);
                            box-shadow: 0 7px 22px rgba(217, 70, 239, 0.25);
                            transition: transform .18s ease, box-shadow .18s ease;
                        }

                        .premium-btn:hover {
                            color: #fff;
                            transform: translateY(-1px);
                            box-shadow: 0 10px 28px rgba(217, 70, 239, 0.38);
                        }

                        .page-body {
                            padding: 22px;
                        }

                        .stat-card,
                        .section-card {
                            background: linear-gradient(180deg, rgba(20, 28, 48, 0.92), rgba(15, 21, 38, 0.95));
                            border: 1px solid var(--border);
                            border-radius: var(--radius-lg);
                        }

                        .stat-card {
                            padding: 16px;
                            height: 100%;
                        }

                        .stat-card:hover {
                            border-color: rgba(139, 92, 246, 0.6);
                        }

                        .stat-icon {
                            width: 42px;
                            height: 42px;
                            border-radius: 12px;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            margin-bottom: 10px;
                            font-size: 18px;
                        }

                        .stat-value {
                            font-size: 26px;
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
                            margin-top: 4px;
                            color: #9fb0d9;
                        }

                        .section-card-header {
                            padding: 14px 16px;
                            border-bottom: 1px solid var(--border);
                            display: flex;
                            align-items: center;
                            justify-content: space-between;
                        }

                        .section-card-header h6 {
                            margin: 0;
                            font-size: 14px;
                            font-weight: 700;
                            color: #ebedff;
                        }

                        .section-card-body {
                            padding: 16px;
                        }

                        .placeholder-box {
                            background: rgba(139, 92, 246, 0.06);
                            border: 1px dashed rgba(139, 92, 246, 0.35);
                            border-radius: var(--radius-md);
                            padding: 34px 12px;
                            text-align: center;
                            color: #95a4cb;
                            font-size: 13px;
                        }

                        .alert-item {
                            display: flex;
                            align-items: center;
                            gap: 10px;
                            padding: 10px 0;
                            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
                        }

                        .alert-item:last-child {
                            border-bottom: none;
                        }

                        .severity-dot {
                            width: 9px;
                            height: 9px;
                            border-radius: 50%;
                        }

                        .severity-critical {
                            background: #ef4444;
                            box-shadow: 0 0 10px rgba(239, 68, 68, 0.7);
                        }

                        .severity-warning {
                            background: #f59e0b;
                            box-shadow: 0 0 10px rgba(245, 158, 11, 0.7);
                        }

                        .severity-info {
                            background: #60a5fa;
                            box-shadow: 0 0 10px rgba(96, 165, 250, 0.6);
                        }

                        .page-section {
                            display: none;
                        }

                        .page-section.active {
                            display: block;
                        }

                        .btn-theme {
                            border: 1px solid rgba(139, 92, 246, 0.5);
                            background: rgba(139, 92, 246, 0.2);
                            color: #e8ddff;
                            border-radius: 8px;
                            padding: 6px 10px;
                            font-size: 12px;
                            font-weight: 600;
                        }

                        .btn-theme:hover {
                            filter: brightness(1.1);
                        }

                        @media (max-width: 900px) {
                            .sidebar {
                                display: none;
                            }

                            .main-content {
                                margin-left: 0;
                            }
                        }

                        /* ── Router table (dashboard inline) ── */
                        .rt-table { width:100%; border-collapse:collapse; font-size:0.82rem; }
                        .rt-table thead tr { background:rgba(22,31,54,0.95); border-bottom:1px solid var(--border); }
                        .rt-table thead th { padding:11px 13px; color:var(--text-muted); font-weight:600; font-size:0.7rem; letter-spacing:.08em; text-transform:uppercase; white-space:nowrap; }
                        .rt-table tbody tr { border-bottom:1px solid rgba(42,53,85,0.35); transition:background .15s; }
                        .rt-table tbody tr:last-child { border-bottom:none; }
                        .rt-table tbody tr:hover { background:rgba(139,92,246,0.06); }
                        .rt-table tbody td { padding:11px 13px; color:var(--text-primary); vertical-align:middle; }
                        .rt-id { display:inline-flex; align-items:center; justify-content:center; background:rgba(96,165,250,0.1); border:1px solid rgba(96,165,250,0.22); color:#60a5fa; border-radius:5px; padding:1px 8px; font-size:.72rem; font-weight:700; font-family:monospace; }
                        .rt-name { display:flex; align-items:center; gap:8px; }
                        .rt-name-icon { width:27px; height:27px; background:linear-gradient(135deg,rgba(139,92,246,.18),rgba(96,165,250,.18)); border:1px solid rgba(139,92,246,.28); border-radius:6px; display:flex; align-items:center; justify-content:center; font-size:13px; color:#8b5cf6; flex-shrink:0; }
                        .rt-ip { font-family:'Courier New',monospace; font-size:.78rem; color:#22d3ee; background:rgba(34,211,238,.07); border-radius:4px; padding:1px 6px; display:inline-block; }
                        .rt-mac { font-family:'Courier New',monospace; font-size:.76rem; color:var(--text-muted); background:rgba(154,166,199,.07); border-radius:4px; padding:1px 6px; display:inline-block; }
                        .rt-status-form { display:flex; gap:5px; align-items:center; }
                        .rt-sel { background:rgba(22,31,54,.9); border:1px solid var(--border); color:var(--text-primary); border-radius:6px; padding:4px 8px; font-size:.72rem; outline:none; cursor:pointer; transition:border-color .2s; }
                        .rt-sel:focus { border-color:#8b5cf6; }
                        .rt-sel option { background:#0b1020; }
                        .rt-upd { background:rgba(52,211,153,.1); border:1px solid rgba(52,211,153,.28); color:#34d399; border-radius:6px; padding:4px 8px; font-size:.7rem; font-weight:600; cursor:pointer; transition:all .18s; white-space:nowrap; }
                        .rt-upd:hover { background:rgba(52,211,153,.22); }
                        .rt-actions { display:flex; gap:4px; align-items:center; }
                        .rt-btn { display:inline-flex; align-items:center; justify-content:center; width:29px; height:29px; border-radius:6px; border:1px solid transparent; font-size:13px; text-decoration:none; transition:all .18s; background:transparent; cursor:pointer; }
                        .rt-btn-edit { border-color:rgba(96,165,250,.28); color:#60a5fa; background:rgba(96,165,250,.07); }
                        .rt-btn-edit:hover { background:rgba(96,165,250,.2); box-shadow:0 0 8px rgba(96,165,250,.3); color:#60a5fa; }
                        .rt-btn-restart { border-color:rgba(251,191,36,.28); color:#fbbf24; background:rgba(251,191,36,.07); }
                        .rt-btn-restart:hover { background:rgba(251,191,36,.2); box-shadow:0 0 8px rgba(251,191,36,.3); color:#fbbf24; }
                        .rt-btn-del { border-color:rgba(248,113,113,.28); color:#f87171; background:rgba(248,113,113,.07); }
                        .rt-btn-del:hover { background:rgba(248,113,113,.2); box-shadow:0 0 8px rgba(248,113,113,.3); color:#f87171; }
                        .rt-empty { padding:48px 24px; text-align:center; color:var(--text-muted); }
                        .rt-empty i { font-size:40px; color:var(--border); display:block; margin-bottom:10px; }
                        .rt-room { display:inline-flex; align-items:center; justify-content:center; background:rgba(139,92,246,.08); border:1px solid rgba(139,92,246,.22); color:#8b5cf6; border-radius:5px; padding:1px 8px; font-size:.72rem; font-weight:700; font-family:monospace; }
                        .ipam-summary { display:grid; grid-template-columns:repeat(3,minmax(0,1fr)); gap:12px; padding:16px; border-bottom:1px solid var(--border); }
                        .ipam-card { background:rgba(16,23,42,.72); border:1px solid rgba(42,53,85,.75); border-radius:8px; padding:14px 15px; }
                        .ipam-card-label { color:var(--text-muted); font-size:.72rem; text-transform:uppercase; letter-spacing:.08em; }
                        .ipam-card-value { font-size:1.55rem; font-weight:800; margin-top:4px; }
                        .ipam-filterbar { display:flex; justify-content:space-between; align-items:center; gap:12px; padding:14px 16px; border-bottom:1px solid rgba(42,53,85,.55); flex-wrap:wrap; }
                        .ipam-filterbar .btn { border-radius:7px; font-size:.78rem; font-weight:700; }
                        .ipam-address { display:inline-flex; align-items:center; gap:7px; font-family:"Courier New",monospace; color:#22d3ee; background:rgba(34,211,238,.08); border:1px solid rgba(34,211,238,.23); border-radius:6px; padding:4px 9px; font-size:.82rem; font-weight:700; }
                        .ipam-device { color:#dbeafe; font-size:.78rem; }
                        .ipam-muted { color:var(--text-muted); font-size:.78rem; }
                        .ipam-assign { display:flex; gap:6px; align-items:center; flex-wrap:wrap; }
                        .ipam-input { width:112px; background:rgba(22,31,54,.9); border:1px solid var(--border); color:var(--text-primary); border-radius:6px; padding:4px 8px; font-size:.72rem; outline:none; }
                        .ipam-input:focus { border-color:#22d3ee; box-shadow:0 0 0 2px rgba(34,211,238,.12); }
                        .ipam-row[style*="display: none"] { display:none !important; }
                        .module-tools { display:flex; justify-content:space-between; align-items:center; gap:12px; padding:14px 16px; border-bottom:1px solid rgba(42,53,85,.55); flex-wrap:wrap; }
                        .module-search { min-width:260px; flex:1; background:#0f162b; border:1px solid var(--border); color:var(--text-primary); border-radius:7px; padding:8px 11px; font-size:.82rem; outline:none; }
                        .module-search:focus { border-color:#8b5cf6; box-shadow:0 0 0 .16rem rgba(139,92,246,.16); }
                        .module-search::placeholder { color:var(--text-muted); }
                        .module-pager { display:flex; align-items:center; gap:6px; flex-wrap:wrap; }
                        .module-page-btn { border:1px solid rgba(139,92,246,.42); background:rgba(139,92,246,.12); color:#d8b4fe; border-radius:7px; min-width:32px; height:32px; padding:0 9px; font-size:.78rem; font-weight:700; }
                        .module-page-btn.active { background:#8b5cf6; color:white; }
                        .module-page-btn:disabled { opacity:.42; cursor:not-allowed; }
                        .module-page-ellipsis { color:var(--text-muted); padding:0 2px; font-weight:700; }
                        .module-count { color:var(--text-muted); font-size:.78rem; white-space:nowrap; }
                        .ticket-title { font-weight:700; color:var(--text-primary); }
                        .ticket-desc { font-size:.75rem; color:var(--text-muted); margin-top:3px; max-width:360px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
                        .ticket-status { display:inline-flex; align-items:center; border-radius:999px; padding:4px 9px; font-size:.7rem; font-weight:800; border:1px solid rgba(148,163,184,.28); background:rgba(148,163,184,.12); color:#cbd5e1; }
                        .ticket-status.status-open { border-color:rgba(52,211,153,.32); background:rgba(52,211,153,.12); color:#86efac; }
                        .ticket-status.status-progress { border-color:rgba(96,165,250,.32); background:rgba(96,165,250,.12); color:#bfdbfe; }
                        .ticket-status.status-resolved { border-color:rgba(168,85,247,.32); background:rgba(168,85,247,.12); color:#d8b4fe; }
                        .room-name-cell { display:flex; align-items:center; gap:9px; font-weight:700; }
                        .room-icon { width:30px; height:30px; border-radius:8px; display:flex; align-items:center; justify-content:center; background:rgba(34,211,238,.1); color:#67e8f9; border:1px solid rgba(34,211,238,.24); }
                        .room-chip { display:inline-flex; align-items:center; border-radius:6px; padding:2px 8px; background:rgba(139,92,246,.08); color:#c4b5fd; border:1px solid rgba(139,92,246,.22); font-size:.74rem; font-weight:700; }
                        @media (max-width: 768px) { .ipam-summary { grid-template-columns:1fr; } }
                    </style>
                </head>

                <body>


                    <nav class="sidebar">
                        <div class="sidebar-brand">
                            <div class="sidebar-brand-icon"><i class="bi bi-diagram-3-fill"></i></div>
                            <div class="brand-title">Network<br>Manager</div>
                        </div>

                        <div class="sidebar-section-label">Overview</div>
                        <button class="nav-item-link active" onclick="showPage('dashboard', this)">
                            <i class="bi bi-speedometer2"></i> Dashboard
                        </button>

                        <div class="sidebar-section-label">Infrastructure</div>
                        <button class="nav-item-link" onclick="showPage('devices', this)">
                            <i class="bi bi-laptop"></i> Network Devices
                        </button>
                        <button class="nav-item-link" onclick="showPage('accesspoints', this)">
                            <i class="bi bi-reception-4"></i> Access Points
                        </button>
                        <button class="nav-item-link" onclick="showPage('routers', this)">
                            <i class="bi bi-router"></i> Routers
                        </button>
                        <button class="nav-item-link" onclick="showPage('switches', this)">
                            <i class="bi bi-hdd-network"></i> Switches
                        </button>
                        <button class="nav-item-link" onclick="showPage('vlan', this)">
                            <i class="bi bi-diagram-3"></i> VLAN
                        </button>
                        <a class="nav-item-link text-decoration-none"
                            href="${pageContext.request.contextPath}/MainController?action=ipList">

                             <i class="bi bi-globe"></i>
                             IP Management
                         </a>

                        <div class="sidebar-section-label">Monitoring</div>
                        <button class="nav-item-link" onclick="showPage('bandwidth', this)">
                            <i class="bi bi-bar-chart-line"></i> Bandwidth Usage
                        </button>
                        <button class="nav-item-link" onclick="showPage('wifianalytics', this)">
                            <i class="bi bi-graph-up"></i> WiFi Analytics
                        </button>
                        <button class="nav-item-link" onclick="showPage('alerts', this)">
                            <i class="bi bi-exclamation-triangle"></i> Network Alerts
                            <span class="ms-auto badge"
                                style="background:rgba(239,68,68,0.2);color:#fda4af;font-size:10px;">3</span>
                        </button>

                        <div class="sidebar-section-label">Management</div>
                        <button class="nav-item-link" onclick="showPage('tickets', this)">
                            <i class="bi bi-ticket-perforated"></i> Support Tickets
                        </button>
                        <button class="nav-item-link" onclick="showPage('maintenance', this)">
                            <i class="bi bi-tools"></i> Maintenance
                        </button>
                        <button class="nav-item-link" onclick="showPage('rooms', this)">
                            <i class="bi bi-building"></i> Rooms
                        </button>

                        <c:if test="${isAdmin}">
                            <div class="sidebar-section-label">Administration</div>
                            <a href="UserController?action=list" class="nav-item-link text-decoration-none">
                                <i class="bi bi-people"></i> Manage Users
                            </a>
                            <a href="AuthLogController" class="nav-item-link text-decoration-none">
                                <i class="bi bi-shield-check"></i> Auth Logs
                            </a>
                            <a href="SystemLogController" class="nav-item-link text-decoration-none">
                                <i class="bi bi-journal-text"></i> System Logs
                            </a>
                        </c:if>

                                <div class="sidebar-footer">
                                    <div class="d-flex align-items-center gap-2 mb-2">
                                        <div class="user-avatar ${isAdmin ? 'admin-avatar' : 'tech-avatar'}">
                                            ${fn:substring(displayName, 0, 1)}
                                        </div>
                                        <div>
                                            <div style="font-size:13px;font-weight:600;color:#e8ecff;">
                                                ${displayName}
                                            </div>
                                            <div style="font-size:11px;color:#8ea0cb;">
                                                ${role}
                                            </div>
                                        </div>
                                    </div>
                                    <a href="LoginController?action=logout" class="nav-item-link text-danger"
                                        style="padding-left:0;">
                                        <i class="bi bi-box-arrow-left"></i> Sign Out
                                    </a>
                                </div>
                    </nav>

<c:set var="sidebarActive" value="${empty param.page ? 'dashboard' : param.page}" scope="request" />
<%@include file="sidebar.jsp" %>

                    <div class="main-content">
                        <div class="topbar">
                            <div>
                                <span class="topbar-title" id="pageTitle">Dashboard</span>
                                <span class="topbar-breadcrumb" id="pageBreadcrumb">/ Overview</span>
                            </div>
                            <div class="d-flex align-items-center gap-2">
                                <a class="premium-btn" href="${pageContext.request.contextPath}/payment/checkout">
                                    <i class="bi bi-gem"></i> Premium
                                </a>
                                <span class="${isAdmin ? 'role-badge-admin' : 'role-badge-tech'}">${role}
                                </span>
                                <span style="font-size:13px;color:#9db0db;">Welcome, <strong style="color:#f2f5ff;">
                                        ${displayName}
                                    </strong></span>
                            </div>
                        </div>

                        <div class="page-body">
                            <div class="page-section active" id="page-dashboard">
                                <div class="row g-3 mb-4">
                                    <div class="col-6 col-md-3">
                                        <div class="stat-card">
                                            <div class="stat-icon"
                                                style="background:rgba(34,197,94,0.16);color:#4ade80;"><i
                                                    class="bi bi-laptop"></i></div>
                                            <div class="stat-value" style="color:#4ade80;">142</div>
                                            <div class="stat-label">Devices Online</div>
                                            <div class="stat-delta">/ 200 registered</div>
                                        </div>
                                    </div>
                                    <div class="col-6 col-md-3">
                                        <div class="stat-card">
                                            <div class="stat-icon"
                                                style="background:rgba(96,165,250,0.16);color:#60a5fa;"><i
                                                    class="bi bi-reception-4"></i></div>
                                            <div class="stat-value">7<span
                                                    style="font-size:16px;color:#97a8d0;">/8</span></div>
                                            <div class="stat-label">Access Points</div>
                                            <div class="stat-delta">1 offline</div>
                                        </div>
                                    </div>
                                    <div class="col-6 col-md-3">
                                        <div class="stat-card">
                                            <div class="stat-icon"
                                                style="background:rgba(245,158,11,0.16);color:#f59e0b;"><i
                                                    class="bi bi-bar-chart-line"></i></div>
                                            <div class="stat-value">74<span
                                                    style="font-size:14px;color:#97a8d0;">Mbps</span></div>
                                            <div class="stat-label">Current Bandwidth</div>
                                            <div class="stat-delta">/ 100 Mbps capacity</div>
                                        </div>
                                    </div>
                                    <div class="col-6 col-md-3">
                                        <div class="stat-card">
                                            <div class="stat-icon"
                                                style="background:rgba(239,68,68,0.16);color:#ef4444;"><i
                                                    class="bi bi-exclamation-triangle"></i></div>
                                            <div class="stat-value" style="color:#f87171;">3</div>
                                            <div class="stat-label">Active Alerts</div>
                                            <div class="stat-delta">Needs attention</div>
                                        </div>
                                    </div>
                                </div>

                                <div class="row g-3 mb-4">
                                    <div class="col-md-6">
                                        <div class="section-card">
                                            <div class="section-card-header">
                                                <h6><i class="bi bi-exclamation-triangle me-2 text-warning"></i>Recent
                                                    Alerts</h6>
                                                <button class="btn-theme" onclick="showPage('alerts',null)">View
                                                    All</button>
                                            </div>
                                            <div class="section-card-body">
                                                <div class="alert-item">
                                                    <div class="severity-dot severity-critical"></div>
                                                    <div>
                                                        <div style="font-weight:600;font-size:13px;">AP-Floor2 went
                                                            offline</div>
                                                        <div style="font-size:11px;color:#95a3c8;">OUTAGE · CRITICAL ·
                                                            just now</div>
                                                    </div>
                                                </div>
                                                <div class="alert-item">
                                                    <div class="severity-dot severity-warning"></div>
                                                    <div>
                                                        <div style="font-weight:600;font-size:13px;">High bandwidth on
                                                            Switch-A1</div>
                                                        <div style="font-size:11px;color:#95a3c8;">PERFORMANCE · WARNING
                                                            · 5m ago</div>
                                                    </div>
                                                </div>
                                                <div class="alert-item">
                                                    <div class="severity-dot severity-info"></div>
                                                    <div>
                                                        <div style="font-weight:600;font-size:13px;">Maintenance
                                                            scheduled tonight</div>
                                                        <div style="font-size:11px;color:#95a3c8;">INFO · 22:00</div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="col-md-6">
                                        <div class="section-card">
                                            <div class="section-card-header">
                                                <h6><i class="bi bi-reception-4 me-2"></i>Access Point Load</h6>
                                                <button class="btn-theme"
                                                    onclick="showPage('accesspoints',null)">Details</button>
                                            </div>
                                            <div class="section-card-body">
                                                <% String[][] aps={ {"AP_Toa_A_T2","38","66","#4ade80"},
                                                    {"AP_Toa_B_T1","45","78","#f59e0b"},
                                                    {"AP_Lab_CNTT","22","38","#4ade80"},
                                                    {"AP_Thu_Vien","37","64","#4ade80"},
                                                    {"AP_Canteen","0","0","#64748b"} }; %>
                                                    <% for (String[] ap : aps) { %>
                                                        <div class="d-flex align-items-center gap-2 mb-2"
                                                            style="font-size:13px;">
                                                            <div
                                                                style="width:112px;color:#dce4ff;font-size:12px;flex-shrink:0;">
                                                                <%= ap[0] %>
                                                            </div>
                                                            <div class="flex-grow-1"
                                                                style="height:6px;background:rgba(255,255,255,0.08);border-radius:999px;overflow:hidden;">
                                                                <div
                                                                    style="width:<%= ap[2] %>%;height:100%;background:<%= ap[3] %>;border-radius:999px;">
                                                                </div>
                                                            </div>
                                                            <div
                                                                style="width:42px;text-align:right;color:<%= ap[3] %>;font-size:12px;">
                                                                <%= ap[1] %>
                                                            </div>
                                                        </div>
                                                        <% } %>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <div class="section-card">
                                            <div class="section-card-header">
                                                <h6><i class="bi bi-ticket-perforated me-2"></i>Open Support Tickets
                                                </h6>
                                                <button class="btn-theme" onclick="showPage('tickets',null)">View
                                                    All</button>
                                            </div>
                                            <div class="section-card-body">
                                                <%
                                                    int openTicketShown = 0;
                                                    if (ticketList != null) {
                                                        for (SupportTicketDTO ticket : ticketList) {
                                                            if (ticket == null || ticket.getStatus() == null) {
                                                                continue;
                                                            }

                                                            if (!"OPEN".equals(ticket.getStatus())
                                                                    && !"IN_PROGRESS".equals(ticket.getStatus())) {
                                                                continue;
                                                            }

                                                            if (openTicketShown >= 3) {
                                                                break;
                                                            }

                                                            openTicketShown++;
                                                %>
                                                <div class="alert-item">
                                                    <div class="severity-dot <%= "OPEN".equals(ticket.getStatus())
                                                            ? "severity-critical"
                                                            : "severity-warning" %>"></div>
                                                    <div class="flex-grow-1">
                                                        <div class="d-flex justify-content-between gap-2">
                                                            <div style="font-weight:600;font-size:13px;">
                                                                <%= ticket.getTitle() %>
                                                            </div>
                                                            <span class="badge text-bg-secondary"
                                                                  style="font-size:10px;">
                                                                <%= ticket.getStatus() %>
                                                            </span>
                                                        </div>
                                                        <div style="font-size:11px;color:#95a3c8;">
                                                            User #<%= ticket.getCreatedBy() %>
                                                            <% if (ticket.getDeviceId() != null) { %>
                                                            &middot; Device #<%= ticket.getDeviceId() %>
                                                            <% } else { %>
                                                            &middot; No device
                                                            <% } %>
                                                        </div>
                                                    </div>
                                                </div>
                                                <%
                                                        }
                                                    }

                                                    if (openTicketShown == 0) {
                                                %>
                                                <div class="placeholder-box">
                                                    <i class="bi bi-ticket-perforated" style="font-size:26px;"></i><br>
                                                    No open support tickets.
                                                </div>
                                                <%
                                                    }
                                                %>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="section-card">
                                            <div class="section-card-header">
                                                <h6><i class="bi bi-tools me-2"></i>Upcoming Maintenance</h6>
                                                <button class="btn-theme" onclick="showPage('maintenance',null)">View
                                                    All</button>
                                            </div>
                                            <div class="section-card-body">
                                                <div class="alert-item">
                                                    <div class="severity-dot severity-info"></div>
                                                    <div>
                                                        <div style="font-weight:600;font-size:13px;">Router firmware
                                                            upgrade</div>
                                                        <div style="font-size:11px;color:#95a3c8;">2026-06-01 22:00 →
                                                            02:00 · PLANNED</div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <% String[][] infraPages={ {"devices","bi-laptop","Network Devices","Device name, MAC address, IP, owner, type, status"}, {"accesspoints","bi-reception-4","Access Points","AP name, SSID, IP, connected users, status, room"}, {"switches","bi-hdd-network","Switches","Switch name, total/used ports, IP, status"} }; %>
                                <% for (String[] p : infraPages) { %>
                                    <div class="page-section" id="page-<%= p[0] %>">
                                        <div class="section-card">
                                            <div class="section-card-header">
                                                <h6><i class="bi <%= p[1] %> me-2"></i>
                                                    <%= p[2] %>
                                                </h6>
                                                <button class="btn-theme"><i class="bi bi-plus-lg me-1"></i>Add
                                                    New</button>
                                            </div>
                                            <div class="section-card-body">
                                                <div class="placeholder-box">
                                                    <i class="bi <%= p[1] %>" style="font-size:26px;"></i><br>
                                                    <%= p[2] %> list will appear here<br>
                                                        <small>
                                                            <%= p[3] %>
                                                        </small>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <% } %>

                                        <div class="page-section" id="page-ipmanage">
                                            <div class="section-card">
                                                <div class="section-card-header">
                                                    <h6><i class="bi bi-globe me-2"></i>IP Address Management</h6>
                                                    <a class="btn-theme text-decoration-none"
                                                       href="MainController?action=ipList">
                                                        <i class="bi bi-box-arrow-up-right me-1"></i>
                                                        Full View
                                                    </a>
                                                </div>
                                                <div class="section-card-body" style="padding:0;">
                                                    <%
                                                        int totalIpCount = ipList == null ? 0 : ipList.size();
                                                        int availableIpCount = 0;
                                                        int assignedIpCount = 0;

                                                        if (ipList != null) {
                                                            for (IPAddressManagementDTO ip : ipList) {
                                                                String ipStatus = ip.getStatus() == null
                                                                        ? ""
                                                                        : ip.getStatus().toUpperCase();

                                                                if ("AVAILABLE".equals(ipStatus)
                                                                        && ip.getDeviceId() == null) {
                                                                    availableIpCount++;
                                                                } else if ("ASSIGNED".equals(ipStatus)
                                                                        || ip.getDeviceId() != null) {
                                                                    assignedIpCount++;
                                                                }
                                                            }
                                                        }
                                                    %>
                                                    <div class="ipam-summary">
                                                        <div class="ipam-card">
                                                            <div class="ipam-card-label">Total IPs</div>
                                                            <div class="ipam-card-value" style="color:#e0f2fe;">
                                                                <%= totalIpCount %>
                                                            </div>
                                                        </div>
                                                        <div class="ipam-card">
                                                            <div class="ipam-card-label">Available</div>
                                                            <div class="ipam-card-value" style="color:#4ade80;">
                                                                <%= availableIpCount %>
                                                            </div>
                                                        </div>
                                                        <div class="ipam-card">
                                                            <div class="ipam-card-label">Assigned</div>
                                                            <div class="ipam-card-value" style="color:#60a5fa;">
                                                                <%= assignedIpCount %>
                                                            </div>
                                                        </div>
                                                    </div>

                                                    <div class="ipam-filterbar">
                                                        <div class="ipam-muted">
                                                            IPs are managed as assignable network resources.
                                                        </div>
                                                        <div class="btn-group" role="group" aria-label="IP filter">
                                                            <button class="btn btn-sm btn-outline-light"
                                                                    type="button"
                                                                    onclick="filterIpam('ALL')">
                                                                All
                                                            </button>
                                                            <button class="btn btn-sm btn-outline-success"
                                                                    type="button"
                                                                    onclick="filterIpam('AVAILABLE')">
                                                                Available
                                                            </button>
                                                            <button class="btn btn-sm btn-outline-info"
                                                                    type="button"
                                                                    onclick="filterIpam('ASSIGNED')">
                                                                Assigned
                                                            </button>
                                                        </div>
                                                    </div>

                                                    <div class="module-tools"
                                                         data-module-tools="ipmanage">
                                                        <input class="module-search"
                                                               type="search"
                                                               data-module-search="ipmanage"
                                                               placeholder="Search by IP address, status, IP ID, or device ID">
                                                        <span class="module-count"
                                                              data-module-count="ipmanage"></span>
                                                        <div class="module-pager"
                                                             data-module-pager="ipmanage"></div>
                                                    </div>

                                                    <div style="overflow-x:auto;">
                                                        <table class="rt-table">
                                                            <thead>
                                                                <tr>
                                                                    <th><i class="bi bi-globe2 me-1"></i>IP Address</th>
                                                                    <th><i class="bi bi-activity me-1"></i>Status</th>
                                                                    <th><i class="bi bi-cpu me-1"></i>Device</th>
                                                                    <th><i class="bi bi-sliders me-1"></i>Actions</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                                <% if (ipList != null && !ipList.isEmpty()) {
                                                                    for (IPAddressManagementDTO ip : ipList) {
                                                                        String status = ip.getStatus() == null
                                                                                ? ""
                                                                                : ip.getStatus().toUpperCase();
                                                                        String filterStatus = ip.getDeviceId() == null
                                                                                && "AVAILABLE".equals(status)
                                                                                ? "AVAILABLE"
                                                                                : "ASSIGNED";
                                                                %>
                                                                <tr class="ipam-row"
                                                                    data-module-row="ipmanage"
                                                                    data-ip-status="<%= filterStatus %>"
                                                                    data-search="<%= ip.getIpId() %> <%= ip.getIpAddress() %> <%= ip.getStatus() %> <%= ip.getDeviceId() == null ? "" : ip.getDeviceId() %>">
                                                                    <td>
                                                                        <span class="ipam-address">
                                                                            <i class="bi bi-router"></i>
                                                                            <%= ip.getIpAddress() %>
                                                                        </span>
                                                                        <div class="ipam-muted mt-1">
                                                                            Resource #<%= ip.getIpId() %>
                                                                        </div>
                                                                    </td>
                                                                    <td>
                                                                        <span class="rt-status <%= "AVAILABLE".equals(ip.getStatus())
                                                                                ? "status-online"
                                                                                : "status-maint" %>">
                                                                            <%= ip.getStatus() %>
                                                                        </span>
                                                                    </td>
                                                                    <td>
                                                                        <% if (ip.getDeviceId() == null) { %>
                                                                        <span class="ipam-muted">Not assigned</span>
                                                                        <% } else { %>
                                                                        <span class="ipam-device">
                                                                            Device #<%= ip.getDeviceId() %>
                                                                        </span>
                                                                        <% } %>
                                                                    </td>
                                                                    <td>
                                                                        <% if (ip.getDeviceId() == null) { %>
                                                                        <form action="MainController"
                                                                              method="post"
                                                                              class="ipam-assign">
                                                                            <input type="hidden"
                                                                                   name="action"
                                                                                   value="ipAssign">
                                                                            <input type="hidden"
                                                                                   name="ipId"
                                                                                   value="<%= ip.getIpId() %>">
                                                                            <input type="hidden"
                                                                                   name="returnTo"
                                                                                   value="dashboard">
                                                                            <select class="ipam-input"
                                                                                    name="deviceId"
                                                                                    required>
                                                                                <option value="">
                                                                                    Select device
                                                                                </option>
                                                                                <% for (NetworkDeviceDTO device : availableIpDevices) { %>
                                                                                <option value="<%= device.getDeviceId() %>">
                                                                                    #<%= device.getDeviceId() %>
                                                                                    -
                                                                                    <%= device.getDeviceName() %>
                                                                                </option>
                                                                                <% } %>
                                                                            </select>
                                                                            <button class="rt-upd"
                                                                                    type="submit">
                                                                                Assign
                                                                            </button>
                                                                        </form>
                                                                        <% } else { %>
                                                                        <button class="btn btn-sm btn-outline-warning dashboard-release-ip"
                                                                                type="button"
                                                                                data-bs-toggle="modal"
                                                                                data-bs-target="#dashboardReleaseIpModal"
                                                                                data-ip-id="<%= ip.getIpId() %>"
                                                                                data-ip-address="<%= ip.getIpAddress() %>">
                                                                            <i class="bi bi-unlink me-1"></i>
                                                                            Release
                                                                        </button>
                                                                        <% } %>
                                                                    </td>
                                                                </tr>
                                                                <%
                                                                    }
                                                                } else {
                                                                %>
                                                                <tr>
                                                                    <td colspan="5">
                                                                        <div class="rt-empty">
                                                                            <i class="bi bi-globe"></i>
                                                                            No IP addresses found.
                                                                        </div>
                                                                    </td>
                                                                </tr>
                                                                <% } %>
                                                            </tbody>
                                                        </table>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="page-section" id="page-routers">
                                            <div class="section-card">
                                                <div class="section-card-header">
                                                    <h6><i class="bi bi-router me-2"></i>Routers</h6>
                                                    <a class="btn-theme text-decoration-none" href="MainController?action=routerList">
                                                        <i class="bi bi-box-arrow-up-right me-1"></i>Full View
                                                    </a>
                                                    <a class="btn-theme text-decoration-none ms-1" href="MainController?action=routerAdd&returnTo=dashboard">
                                                        <i class="bi bi-plus-lg me-1"></i>Add New
                                                    </a>
                                                </div>
                                                <div class="section-card-body" style="padding:0;">
                                                    <div style="overflow-x:auto;">
                                                        <table class="rt-table">
                                                            <thead>
                                                                <tr>
                                                                    <th><i class="bi bi-hash me-1"></i>ID</th>
                                                                    <th><i class="bi bi-router me-1"></i>Name</th>
                                                                    <th><i class="bi bi-globe me-1"></i>IP Address</th>
                                                                    <th><i class="bi bi-ethernet me-1"></i>MAC</th>
                                                                    <th><i class="bi bi-cpu me-1"></i>Model</th>
                                                                    <th><i class="bi bi-code-slash me-1"></i>Firmware</th>
                                                                    <th><i class="bi bi-activity me-1"></i>Status</th>
                                                                    <th><i class="bi bi-geo-alt me-1"></i>Location</th>
                                                                    <th><i class="bi bi-door-open me-1"></i>Room</th>
                                                                    <th><i class="bi bi-three-dots me-1"></i>Actions</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                                <% if (routerList != null && !routerList.isEmpty()) {
                                                                    for (RouterDTO router : routerList) { %>
                                                                        <tr>
                                                                            <td><span class="rt-id">#<%= router.getRouterId() %></span></td>
                                                                            <td>
                                                                                <div class="rt-name">
                                                                                    <div class="rt-name-icon"><i class="bi bi-router-fill"></i></div>
                                                                                    <span style="font-weight:600;"><%= router.getRouterName() %></span>
                                                                                </div>
                                                                            </td>
                                                                            <td><span class="rt-ip"><%= router.getIpAddress() %></span></td>
                                                                            <td><span class="rt-mac"><%= router.getMacAddress() %></span></td>
                                                                            <td style="color:var(--text-muted);font-size:.78rem;"><%= router.getModel() %></td>
                                                                            <td style="color:var(--text-muted);font-size:.76rem;"><%= router.getFirmware() %></td>
                                                                            <td>
                                                                                <form action="MainController" method="post" class="rt-status-form">
                                                                                    <input type="hidden" name="action" value="routerUpdateStatus">
                                                                                    <input type="hidden" name="id" value="<%= router.getRouterId() %>">
                                                                                    <input type="hidden" name="returnTo" value="dashboard">
                                                                                    <select class="rt-sel" name="status">
                                                                                        <option value="ONLINE" <%= "ONLINE".equalsIgnoreCase(router.getStatus()) ? "selected" : "" %>>🟢 ONLINE</option>
                                                                                        <option value="OFFLINE" <%= "OFFLINE".equalsIgnoreCase(router.getStatus()) ? "selected" : "" %>>🔴 OFFLINE</option>
                                                                                        <option value="MAINTENANCE" <%= "MAINTENANCE".equalsIgnoreCase(router.getStatus()) ? "selected" : "" %>>🟡 MAINTENANCE</option>
                                                                                    </select>
                                                                                    <button class="rt-upd" type="submit" title="Update status"><i class="bi bi-check2"></i></button>
                                                                                </form>
                                                                            </td>
                                                                            <td style="color:var(--text-muted);font-size:.78rem;">
                                                                                <i class="bi bi-geo-alt-fill" style="color:#d946ef;margin-right:3px;"></i><%= router.getLocation() %>
                                                                            </td>
                                                                            <td><span class="rt-room"><%= router.getRoomId() %></span></td>
                                                                            <td>
                                                                                <div class="rt-actions">
                                                                                    <a class="rt-btn rt-btn-edit" href="MainController?action=routerEdit&id=<%= router.getRouterId() %>&returnTo=dashboard" title="Edit"><i class="bi bi-pencil-fill"></i></a>
                                                                                    <a class="rt-btn rt-btn-restart" href="MainController?action=routerRestart&id=<%= router.getRouterId() %>&returnTo=dashboard" title="Restart"><i class="bi bi-arrow-clockwise"></i></a>
                                                                                    <a class="rt-btn rt-btn-del" href="MainController?action=routerDelete&routerId=<%= router.getRouterId() %>&returnTo=dashboard" title="Delete" onclick="return confirm('Delete router &lt;<%= router.getRouterName() %>&gt;?')"><i class="bi bi-trash3-fill"></i></a>
                                                                                </div>
                                                                            </td>
                                                                        </tr>
                                                                <%  }
                                                                } else { %>
                                                                    <tr>
                                                                        <td colspan="10">
                                                                            <div class="rt-empty">
                                                                                <i class="bi bi-router"></i>
                                                                                No routers found. Add your first router.
                                                                            </div>
                                                                        </td>
                                                                    </tr>
                                                                <% } %>
                                                            </tbody>
                                                        </table>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                         
                                         <div class="page-section" id="page-vlan">
                                             <div class="section-card">

                                                 <div class="section-card-header">
                                                     <h6>
                                                         <i class="bi bi-diagram-3 me-2"></i>
                                                         VLAN Management
                                                     </h6>

                                                     <div>
                                                         <a class="btn-theme text-decoration-none"
                                                            href="MainController?action=vlanList">
                                                             <i class="bi bi-box-arrow-up-right me-1"></i>
                                                             Full View
                                                         </a>

                                                         <a class="btn-theme text-decoration-none ms-1"
                                                            href="MainController?action=vlanAdd&returnTo=dashboard">
                                                             <i class="bi bi-plus-lg me-1"></i>
                                                             Add VLAN
                                                         </a>
                                                     </div>
                                                 </div>

                                                 <div class="section-card-body" style="padding:0;">

                                                     <div class="module-tools"
                                                          data-module-tools="vlan">
                                                         <input class="module-search"
                                                                type="search"
                                                                data-module-search="vlan"
                                                                placeholder="Search by VLAN name, subnet, purpose, or room">
                                                         <span class="module-count"
                                                               data-module-count="vlan"></span>
                                                         <div class="module-pager"
                                                              data-module-pager="vlan"></div>
                                                     </div>

                                                     <div style="overflow-x:auto;">

                                                         <table class="rt-table">

                                                             <thead>
                                                                 <tr>
                                                                     <th>
                                                                         <i class="bi bi-hash me-1"></i>
                                                                         ID
                                                                     </th>

                                                                     <th>
                                                                         <i class="bi bi-diagram-3 me-1"></i>
                                                                         VLAN Name
                                                                     </th>

                                                                     <th>
                                                                         <i class="bi bi-globe me-1"></i>
                                                                         Subnet
                                                                     </th>

                                                                     <th>
                                                                         <i class="bi bi-card-text me-1"></i>
                                                                         Purpose
                                                                     </th>

                                                                     <th>
                                                                         <i class="bi bi-door-open me-1"></i>
                                                                         Room
                                                                     </th>

                                                                     <th>
                                                                         <i class="bi bi-three-dots me-1"></i>
                                                                         Actions
                                                                     </th>
                                                                 </tr>
                                                             </thead>

                                                             <tbody>

                                                                 <%
                                                                     if (vlanList != null
                                                                             && !vlanList.isEmpty()) {

                                                                         for (VLANDTO vlan : vlanList) {
                                                                 %>

                                                                 <tr data-module-row="vlan"
                                                                     data-search="<%= vlan.getVlanId() %> <%= vlan.getVlanName() %> <%= vlan.getSubnet() == null ? "" : vlan.getSubnet() %> <%= vlan.getPurpose() == null ? "" : vlan.getPurpose() %> <%= vlan.getRoomId() == null ? "" : vlan.getRoomId() %>">
                                                                     <td>
                                                                         <span class="rt-id">
                                                                             #<%= vlan.getVlanId() %>
                                                                         </span>
                                                                     </td>

                                                                     <td>
                                                                         <div class="rt-name">

                                                                             <div class="rt-name-icon">
                                                                                 <i class="bi bi-diagram-3-fill"></i>
                                                                             </div>

                                                                             <span style="font-weight:600;">
                                                                                 <%= vlan.getVlanName() %>
                                                                             </span>

                                                                         </div>
                                                                     </td>

                                                                     <td>
                                                                         <% if (vlan.getSubnet() != null) { %>

                                                                         <span class="rt-ip">
                                                                             <%= vlan.getSubnet() %>
                                                                         </span>

                                                                         <% } else { %>

                                                                         <span style="color:var(--text-muted);">
                                                                             Not specified
                                                                         </span>

                                                                         <% } %>
                                                                     </td>

                                                                     <td style="color:var(--text-muted);font-size:.78rem;">

                                                                         <%= vlan.getPurpose() == null
                                                                                 ? "Not specified"
                                                                                 : vlan.getPurpose() %>

                                                                     </td>

                                                                     <td>
                                                                         <% if (vlan.getRoomId() != null) { %>

                                                                         <span class="rt-room">
                                                                             Room #<%= vlan.getRoomId() %>
                                                                         </span>

                                                                         <% } else { %>

                                                                         <span style="color:var(--text-muted);">
                                                                             No room
                                                                         </span>

                                                                         <% } %>
                                                                     </td>

                                                                     <td>
                                                                         <div class="rt-actions">

                                                                             <a class="rt-btn rt-btn-edit"
                                                                                href="MainController?action=vlanEdit&id=<%= vlan.getVlanId() %>&returnTo=dashboard"
                                                                                title="Edit VLAN">

                                                                                 <i class="bi bi-pencil-fill"></i>
                                                                             </a>

                                                                             <form action="MainController"
                                                                                   method="post"
                                                                                   style="display:inline;"
                                                                                   onsubmit="return confirm('Are you sure you want to delete VLAN <%= vlan.getVlanName() %>?');">

                                                                                 <input type="hidden"
                                                                                        name="action"
                                                                                        value="vlanDelete">

                                                                                 <input type="hidden"
                                                                                        name="vlanId"
                                                                                        value="<%= vlan.getVlanId() %>">

                                                                                 <input type="hidden"
                                                                                        name="returnTo"
                                                                                        value="dashboard">

                                                                                 <button class="rt-btn rt-btn-del"
                                                                                         type="submit"
                                                                                         title="Delete VLAN">

                                                                                     <i class="bi bi-trash3-fill"></i>
                                                                                 </button>

                                                                             </form>

                                                                         </div>
                                                                     </td>
                                                                 </tr>

                                                                 <%
                                                                         }
                                                                     } else {
                                                                 %>

                                                                 <tr>
                                                                     <td colspan="6">

                                                                         <div class="rt-empty">
                                                                             <i class="bi bi-diagram-3"></i>

                                                                             No VLANs found.

                                                                             <div class="mt-3">
                                                                                 <a class="btn-theme text-decoration-none"
                                                                                    href="MainController?action=vlanAdd&returnTo=dashboard">

                                                                                     <i class="bi bi-plus-lg me-1"></i>
                                                                                     Add the first VLAN
                                                                                 </a>
                                                                             </div>
                                                                         </div>

                                                                     </td>
                                                                 </tr>

                                                                 <%
                                                                     }
                                                                 %>

                                                             </tbody>
                                                         </table>

                                                     </div>
                                                 </div>
                                             </div>
                                         </div>


                                        <div class="page-section" id="page-bandwidth">
                                            <div class="section-card">
                                                <div class="section-card-header">
                                                    <h6><i class="bi bi-bar-chart-line me-2"></i>Bandwidth Usage</h6>
                                                    <div class="d-flex gap-2 align-items-center" style="flex-wrap:wrap;">
                                                        <div class="pagination-controls">
                                                            <button class="page-btn" onclick="prevPage('dash-bandwidth-table')" id="dash-bandwidth-table-prev"><i class="bi bi-chevron-left"></i></button>
                                                            <span class="page-info" id="dash-bandwidth-table-page-info">Page 1 of 1</span>
                                                            <button class="page-btn" onclick="nextPage('dash-bandwidth-table')" id="dash-bandwidth-table-next"><i class="bi bi-chevron-right"></i></button>
                                                        </div>
                                                        <a class="btn-theme text-decoration-none" href="MainController?action=bandwidthAdd&returnTo=dashboard">
                                                            <i class="bi bi-plus-lg me-1"></i>Run Speed Test
                                                        </a>
                                                        <a class="btn-theme text-decoration-none" href="bandwidth-list.jsp">
                                                            <i class="bi bi-box-arrow-up-right me-1"></i>Full View
                                                        </a>
                                                    </div>
                                                </div>
                                                <div class="section-card-body" style="padding:0;">
                                                    <div style="overflow-x:auto;">
                                                        <table class="rt-table" id="dash-bandwidth-table">
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
                                                                                        <form action="MainController" method="post" style="display:inline;">
                                                                                            <input type="hidden" name="action" value="bandwidthDelete">
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
                                                                                <div class="rt-empty">
                                                                                    <i class="bi bi-bar-chart-line"></i>
                                                                                    No bandwidth usage records found.
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
                                        </div>

                                        <div class="page-section" id="page-wifianalytics">
                                            <div class="section-card">
                                                <div class="section-card-header">
                                                    <h6><i class="bi bi-graph-up me-2"></i>WiFi Analytics</h6>
                                                </div>
                                                <div class="section-card-body">
                                                    <div class="placeholder-box">WiFi analytics dashboard will appear
                                                        here</div>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="page-section" id="page-alerts">
                                            <div class="section-card">
                                                <div class="section-card-header">
                                                    <h6><i
                                                            class="bi bi-exclamation-triangle me-2 text-warning"></i>Network
                                                        Alerts</h6>
                                                    <select class="form-select form-select-sm"
                                                        style="width:130px;background:#0f162b;border-color:var(--border);color:#dbe3ff;font-size:12px;">
                                                        <option>All Severity</option>
                                                        <option>CRITICAL</option>
                                                        <option>WARNING</option>
                                                        <option>INFO</option>
                                                    </select>
                                                </div>
                                                <div class="section-card-body">
                                                    <div class="placeholder-box">All network alerts will appear here
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="page-section" id="page-tickets">
                                            <div class="section-card">
                                                <div class="section-card-header">
                                                    <h6><i class="bi bi-ticket-perforated me-2"></i>Support Tickets</h6>
                                                    <a class="btn-theme text-decoration-none"
                                                       href="MainController?action=ticketAdd&returnTo=dashboard">
                                                        <i class="bi bi-plus-lg me-1"></i>
                                                        Add Ticket
                                                    </a>
                                                </div>
                                                <div class="section-card-body" style="padding:0;">
                                                    <div class="module-tools"
                                                         data-module-tools="tickets">
                                                        <input class="module-search"
                                                               type="search"
                                                               data-module-search="tickets"
                                                               placeholder="Search by title, status, user id, or device id">
                                                        <span class="module-count"
                                                              data-module-count="tickets"></span>
                                                        <div class="module-pager"
                                                             data-module-pager="tickets"></div>
                                                    </div>
                                                    <div style="overflow-x:auto;">
                                                        <table class="rt-table">
                                                            <thead>
                                                                <tr>
                                                                    <th><i class="bi bi-hash me-1"></i>ID</th>
                                                                    <th><i class="bi bi-ticket-perforated me-1"></i>Title</th>
                                                                    <th><i class="bi bi-activity me-1"></i>Status</th>
                                                                    <th><i class="bi bi-calendar3 me-1"></i>Created Date</th>
                                                                    <th><i class="bi bi-person me-1"></i>Created By</th>
                                                                    <th><i class="bi bi-cpu me-1"></i>Device</th>
                                                                    <th><i class="bi bi-three-dots me-1"></i>Actions</th>
                                                                </tr>
                                                            </thead>

                                                            <tbody>
                                                                <% if (ticketList != null && !ticketList.isEmpty()) {
                                                                    for (SupportTicketDTO ticket : ticketList) {
                                                                %>

                                                                <tr data-module-row="tickets"
                                                                    data-search="<%= ticket.getTicketId() %> <%= ticket.getTitle() %> <%= ticket.getDescription() == null ? "" : ticket.getDescription() %> <%= ticket.getStatus() %> <%= ticket.getCreatedBy() %> <%= ticket.getDeviceId() == null ? "" : ticket.getDeviceId() %>">
                                                                    <td>
                                                                        <span class="rt-id">
                                                                            #<%= ticket.getTicketId() %>
                                                                        </span>
                                                                    </td>
                                                                    <td>
                                                                        <div class="ticket-title">
                                                                            <%= ticket.getTitle() %>
                                                                        </div>
                                                                        <% if (ticket.getDescription() != null
                                                                                && !ticket.getDescription().trim().isEmpty()) { %>
                                                                        <div class="ticket-desc">
                                                                            <%= ticket.getDescription() %>
                                                                        </div>
                                                                        <% } %>
                                                                    </td>
                                                                    <td>
                                                                        <span class="ticket-status <%= "OPEN".equals(ticket.getStatus())
                                                                                ? "status-open"
                                                                                : ("IN_PROGRESS".equals(ticket.getStatus())
                                                                                        ? "status-progress"
                                                                                        : ("RESOLVED".equals(ticket.getStatus())
                                                                                                ? "status-resolved"
                                                                                                : "")) %>">
                                                                            <%= ticket.getStatus() %>
                                                                        </span>
                                                                    </td>
                                                                    <td>
                                                                        <%= ticket.getCreatedDate() == null
                                                                                ? "Not set"
                                                                                : ticketDateFormat.format(ticket.getCreatedDate()) %>
                                                                    </td>
                                                                    <td>
                                                                        <span class="room-chip">
                                                                            User #<%= ticket.getCreatedBy() %>
                                                                        </span>
                                                                    </td>
                                                                    <td>
                                                                        <% if (ticket.getDeviceId() == null) { %>
                                                                        <span style="color:var(--text-muted);">Not assigned</span>
                                                                        <% } else { %>
                                                                        <span class="room-chip">
                                                                            Device #<%= ticket.getDeviceId() %>
                                                                        </span>
                                                                        <% } %>
                                                                    </td>
                                                                    <td>
                                                                        <div class="rt-actions">
                                                                            <a class="rt-btn rt-btn-edit"
                                                                               href="MainController?action=ticketEdit&id=<%= ticket.getTicketId() %>&returnTo=dashboard"
                                                                               title="Edit Ticket">
                                                                                <i class="bi bi-pencil-fill"></i>
                                                                            </a>

                                                                            <form action="MainController"
                                                                                  method="post">
                                                                                <input type="hidden"
                                                                                       name="action"
                                                                                       value="ticketUpdateStatus">
                                                                                <input type="hidden"
                                                                                       name="ticketId"
                                                                                       value="<%= ticket.getTicketId() %>">
                                                                                <input type="hidden"
                                                                                       name="returnTo"
                                                                                       value="dashboard">
                                                                                <select class="form-select form-select-sm"
                                                                                        name="status"
                                                                                        style="width:128px;background:#0f162b;border-color:var(--border);color:#dbe3ff;font-size:12px;"
                                                                                        onchange="this.form.submit()">
                                                                                    <option value="OPEN"
                                                                                            <%= "OPEN".equals(ticket.getStatus()) ? "selected" : "" %>>
                                                                                        OPEN
                                                                                    </option>
                                                                                    <option value="IN_PROGRESS"
                                                                                            <%= "IN_PROGRESS".equals(ticket.getStatus()) ? "selected" : "" %>>
                                                                                        IN_PROGRESS
                                                                                    </option>
                                                                                    <option value="RESOLVED"
                                                                                            <%= "RESOLVED".equals(ticket.getStatus()) ? "selected" : "" %>>
                                                                                        RESOLVED
                                                                                    </option>
                                                                                    <option value="CLOSED"
                                                                                            <%= "CLOSED".equals(ticket.getStatus()) ? "selected" : "" %>>
                                                                                        CLOSED
                                                                                    </option>
                                                                                </select>
                                                                            </form>

                                                                            <form action="MainController"
                                                                                  method="post"
                                                                                  onsubmit="return confirm('Are you sure you want to delete this ticket?');">
                                                                                <input type="hidden"
                                                                                       name="action"
                                                                                       value="ticketDelete">
                                                                                <input type="hidden"
                                                                                       name="ticketId"
                                                                                       value="<%= ticket.getTicketId() %>">
                                                                                <input type="hidden"
                                                                                       name="returnTo"
                                                                                       value="dashboard">
                                                                                <button class="btn btn-sm btn-outline-danger"
                                                                                        type="submit"
                                                                                        title="Delete Ticket">
                                                                                    <i class="bi bi-trash3-fill"></i>
                                                                                </button>
                                                                            </form>
                                                                        </div>
                                                                    </td>
                                                                </tr>

                                                                <%
                                                                    }
                                                                } else {
                                                                %>

                                                                <tr>
                                                                    <td colspan="7">
                                                                        <div class="placeholder-box my-0">
                                                                            <i class="bi bi-ticket-perforated"
                                                                               style="font-size:26px;"></i>
                                                                            <br>
                                                                            No support tickets found.
                                                                        </div>
                                                                    </td>
                                                                </tr>

                                                                <%
                                                                }
                                                                %>
                                                            </tbody>
                                                        </table>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="page-section" id="page-maintenance">
                                            <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
                                            
                                            <!-- KPI Row -->
                                            <div class="row g-3 mb-3">
                                                <div class="col-6 col-lg-3">
                                                    <div class="stat-card">
                                                        <div class="stat-icon" style="background:rgba(251,191,36,.15);color:#fbbf24;"><i class="bi bi-tools"></i></div>
                                                        <div class="stat-value" style="color:#fde68a;" id="kpi-total">0</div>
                                                        <div class="stat-label">Total Schedules</div>
                                                        <div class="stat-delta" style="color:var(--text-muted);">All time tasks</div>
                                                    </div>
                                                </div>
                                                <div class="col-6 col-lg-3">
                                                    <div class="stat-card">
                                                        <div class="stat-icon" style="background:rgba(96,165,250,.12);color:#60a5fa;"><i class="bi bi-calendar-event"></i></div>
                                                        <div class="stat-value" style="color:#bfdbfe;" id="kpi-planned">0</div>
                                                        <div class="stat-label">Planned</div>
                                                        <div class="stat-delta" style="color:var(--text-muted);">Upcoming tasks</div>
                                                    </div>
                                                </div>
                                                <div class="col-6 col-lg-3">
                                                    <div class="stat-card">
                                                        <div class="stat-icon" style="background:rgba(245,158,11,.12);color:#f59e0b;"><i class="bi bi-gear-wide-connected"></i></div>
                                                        <div class="stat-value" style="color:#fde68a;" id="kpi-inprogress">0</div>
                                                        <div class="stat-label">In Progress</div>
                                                        <div class="stat-delta" style="color:var(--text-muted);">Currently executing</div>
                                                    </div>
                                                </div>
                                                <div class="col-6 col-lg-3">
                                                    <div class="stat-card">
                                                        <div class="stat-icon" style="background:rgba(52,211,153,.12);color:#34d399;"><i class="bi bi-check2-circle"></i></div>
                                                        <div class="stat-value" style="color:#6ee7b7;" id="kpi-completed">0</div>
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
                                                            <div class="chart-wrap" style="position: relative; height: 300px;">
                                                                <canvas id="dashMaintenanceChart"></canvas>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <style>
                                                .sev-tabs { display: flex; gap: 8px; flex-wrap: wrap; padding: 14px 18px; border-bottom: 1px solid var(--border); }
                                                .sev-tab { border-radius: 8px; padding: 6px 14px; font-size: 12px; font-weight: 700; cursor: pointer; transition: .18s; display: inline-flex; align-items: center; gap: 7px; border: 1px solid var(--border); background: rgba(22, 31, 54, .6); color: var(--text-muted); text-decoration: none; user-select: none; }
                                                .sev-tab:hover { color: #e5ddff; filter: brightness(1.1); }
                                                .sev-tab.tab-all.active { background: rgba(139, 92, 246, .25); border-color: rgba(139, 92, 246, .6); color: #f0ebff; }
                                                .sev-tab.tab-planned.active { background: rgba(96, 165, 250, .2); border-color: rgba(96, 165, 250, .6); color: #bae6fd; }
                                                .sev-tab.tab-inprogress.active { background: rgba(251, 191, 36, .18); border-color: rgba(251, 191, 36, .6); color: #fde68a; }
                                                .sev-tab.tab-completed.active { background: rgba(52, 211, 153, .18); border-color: rgba(52, 211, 153, .6); color: #a7f3d0; }
                                                .sev-count { display: inline-flex; align-items: center; justify-content: center; min-width: 20px; height: 20px; border-radius: 10px; font-size: 10px; padding: 0 6px; font-weight: 800; }
                                                .sev-count-all { background: rgba(139, 92, 246, .3); color: #e0d6ff; }
                                                .sev-count-planned { background: rgba(96, 165, 250, .3); color: #bae6fd; }
                                                .sev-count-inprogress { background: rgba(251, 191, 36, .3); color: #fde68a; }
                                                .sev-count-completed { background: rgba(52, 211, 153, .3); color: #a7f3d0; }
                                                .dot { width: 8px; height: 8px; border-radius: 50%; display: inline-block; }
                                                .dot-planned { background: var(--neon-blue); box-shadow: 0 0 6px var(--neon-blue); }
                                                .dot-inprogress { background: var(--neon-amber); box-shadow: 0 0 6px var(--neon-amber); animation: blink 1.4s infinite; }
                                                .dot-completed { background: var(--neon-emerald); }
                                                @keyframes blink { 0% { opacity: 1; } 50% { opacity: 0.4; } 100% { opacity: 1; } }
                                                .desc-box { font-size:0.75rem; color:var(--text-muted); margin-top:6px; line-height:1.5; white-space:pre-wrap; word-wrap:break-word; background:rgba(15,23,42,0.6); padding:8px 12px; border-radius:6px; border-left: 2px solid rgba(139,92,246,0.4); }
                                                .btn-icon { display:inline-flex; align-items:center; justify-content:center; width:32px; height:32px; border-radius:8px; border:1px solid transparent; transition:all .2s; background:transparent; cursor:pointer; }
                                                .btn-icon:hover { filter: brightness(1.2); }
                                                .page-btn { background:rgba(15,23,42,0.6); border:1px solid var(--border); color:#fff; padding:5px 10px; border-radius:6px; cursor:pointer; }
                                                .page-btn:disabled { opacity:0.5; cursor:not-allowed; }
                                                .page-info { color:var(--text-muted); font-size:0.85rem; padding:0 10px; }
                                            </style>
                                            <div class="section-card">
                                                <div class="section-card-header" style="flex-wrap: wrap; gap: 15px;">
                                                    <h6><i class="bi bi-tools me-2"></i>Maintenance Schedule</h6>
                                                    <div class="d-flex gap-2 ms-auto align-items-center" style="flex-wrap: wrap;">
                                                        <div class="search-wrap" style="position:relative; width: 220px;">
                                                            <i class="bi bi-search" style="position:absolute; left:12px; top:50%; transform:translateY(-50%); color:var(--text-muted); font-size:14px;"></i>
                                                            <input type="text" id="dash-maintenance-search" class="form-control" placeholder="Search tasks..." style="background:rgba(15,23,42,0.6); border:1px solid var(--border); color:#fff; border-radius:8px; padding-left:36px; height:36px; font-size:0.85rem;" onkeyup="applyMaintenanceFilter()">
                                                        </div>
                                                        <div class="pagination-controls">
                                                            <button class="page-btn" onclick="prevPage('dash-maintenance-table')" id="dash-maintenance-table-prev"><i class="bi bi-chevron-left"></i></button>
                                                            <span class="page-info" id="dash-maintenance-table-page-info">Page 1 of 1</span>
                                                            <button class="page-btn" onclick="nextPage('dash-maintenance-table')" id="dash-maintenance-table-next"><i class="bi bi-chevron-right"></i></button>
                                                        </div>
                                                        <a class="btn-theme text-decoration-none" href="MainController?action=maintenanceAdd&returnTo=dashboard">
                                                            <i class="bi bi-plus-lg me-1"></i>Schedule
                                                        </a>
                                                        <a class="btn-theme text-decoration-none" href="maintenance-list.jsp">
                                                            <i class="bi bi-box-arrow-up-right me-1"></i>Full View
                                                        </a>
                                                    </div>
                                                </div>

                                                <div class="sev-tabs" id="dash-maintenance-tabs">
                                                    <div class="sev-tab tab-all active" onclick="filterDashTasks('ALL', this)">
                                                        <i class="bi bi-grid-fill"></i> All <span class="sev-count sev-count-all" id="cnt-all">0</span>
                                                    </div>
                                                    <div class="sev-tab tab-planned" onclick="filterDashTasks('PLANNED', this)">
                                                        <span class="dot dot-planned"></span> Planned <span class="sev-count sev-count-planned" id="cnt-planned">0</span>
                                                    </div>
                                                    <div class="sev-tab tab-inprogress" onclick="filterDashTasks('IN_PROGRESS', this)">
                                                        <span class="dot dot-inprogress"></span> In Progress <span class="sev-count sev-count-inprogress" id="cnt-inprogress">0</span>
                                                    </div>
                                                    <div class="sev-tab tab-completed" onclick="filterDashTasks('COMPLETED', this)">
                                                        <span class="dot dot-completed"></span> Completed <span class="sev-count sev-count-completed" id="cnt-completed">0</span>
                                                    </div>
                                                </div>

                                                <div class="section-card-body" style="padding:0;">
                                                    <div style="overflow-x:auto;">
                                                        <table class="rt-table" id="dash-maintenance-table">
                                                            <thead>
                                                                <tr>
                                                                    <th><i class="bi bi-hash me-1"></i>ID</th>
                                                                    <th><i class="bi bi-card-text me-1"></i>Task Title</th>
                                                                    <th><i class="bi bi-calendar-event me-1"></i>Start Time</th>
                                                                    <th><i class="bi bi-calendar-check me-1"></i>End Time</th>
                                                                    <th><i class="bi bi-activity me-1"></i>Status</th>
                                                                    <th><i class="bi bi-three-dots me-1"></i>Actions</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                                <c:choose>
                                                                    <c:when test="${not empty tasks}">
                                                                        <c:forEach var="item" items="${tasks}">
                                                                            <jsp:useBean id="now" class="java.util.Date" />
                                                                            <c:set var="displayStatus" value="${item.status}" />
                                                                            <c:if test="${item.status eq 'PLANNED' or item.status eq 'IN_PROGRESS'}">
                                                                                <c:choose>
                                                                                    <c:when test="${not empty item.endTime and item.endTime.time < now.time}">
                                                                                        <c:set var="displayStatus" value="OVERDUE" />
                                                                                    </c:when>
                                                                                    <c:when test="${item.startTime.time < now.time and (empty item.endTime or item.endTime.time > now.time)}">
                                                                                        <c:set var="displayStatus" value="IN_PROGRESS" />
                                                                                    </c:when>
                                                                                </c:choose>
                                                                            </c:if>

                                                                            <tr class="task-row" data-status="${displayStatus}">
                                                                                <td><span class="rt-id" style="font-size:0.8rem; background:rgba(96,165,250,0.1); border:1px solid rgba(96,165,250,0.22); color:#60a5fa; border-radius:5px; padding:2px 8px; font-weight:700; font-family:monospace;">#${item.maintenanceId}</span></td>
                                                                                <td style="max-width:350px;">
                                                                                    <div style="font-weight:600; color:#fff; display:flex; align-items:center; gap:8px;">
                                                                                        <i class="bi bi-tools" style="color:var(--neon-purple);"></i> ${item.title}
                                                                                    </div>
                                                                                    <div class="desc-box">${item.description}</div>
                                                                                </td>
                                                                                <td style="color:var(--text-muted); font-size:0.85rem;"><fmt:formatDate value="${item.startTime}" pattern="yyyy-MM-dd HH:mm" /></td>
                                                                                <td style="color:var(--text-muted); font-size:0.85rem;">
                                                                                    <c:if test="${not empty item.endTime}"><fmt:formatDate value="${item.endTime}" pattern="yyyy-MM-dd HH:mm" /></c:if>
                                                                                    <c:if test="${empty item.endTime}">--</c:if>
                                                                                </td>
                                                                                <td>
                                                                                    <c:choose>
                                                                                        <c:when test="${displayStatus eq 'PLANNED'}"><span class="badge" style="background: rgba(96,165,250,0.15); color: #60a5fa; border: 1px solid rgba(96,165,250,0.3); padding:6px 10px; font-size:0.7rem;"><i class="bi bi-calendar-event me-1"></i> PLANNED</span></c:when>
                                                                                        <c:when test="${displayStatus eq 'IN_PROGRESS'}"><span class="badge" style="background: rgba(250,204,21,0.15); color: #facc15; border: 1px solid rgba(250,204,21,0.3); padding:6px 10px; font-size:0.7rem; animation:blink 1.5s infinite;"><i class="bi bi-gear-wide-connected me-1"></i> IN PROGRESS</span></c:when>
                                                                                        <c:when test="${displayStatus eq 'COMPLETED'}"><span class="badge" style="background: rgba(52,211,153,0.15); color: #34d399; border: 1px solid rgba(52,211,153,0.3); padding:6px 10px; font-size:0.7rem;"><i class="bi bi-check2-all me-1"></i> COMPLETED</span></c:when>
                                                                                        <c:when test="${displayStatus eq 'CANCELED'}"><span class="badge bg-secondary" style="padding:6px 10px; font-size:0.7rem;">CANCELED</span></c:when>
                                                                                        <c:when test="${displayStatus eq 'OVERDUE'}"><span class="badge" style="background: rgba(248,113,113,0.15); color: #f87171; border: 1px solid rgba(248,113,113,0.3); padding:6px 10px; font-size:0.7rem;"><i class="bi bi-exclamation-triangle-fill me-1"></i> OVERDUE</span></c:when>
                                                                                        <c:otherwise><span class="badge bg-secondary">${displayStatus}</span></c:otherwise>
                                                                                    </c:choose>
                                                                                </td>
                                                                                <td>
                                                                                    <div class="action-group d-flex gap-2">
                                                                                        <c:if test="${item.status ne 'COMPLETED' && item.status ne 'CANCELED'}">
                                                                                            <form action="MainController" method="post" style="display:inline;">
                                                                                                <input type="hidden" name="action" value="maintenanceComplete">
                                                                                                <input type="hidden" name="maintenanceId" value="${item.maintenanceId}">
                                                                                                <input type="hidden" name="returnTo" value="dashboard">
                                                                                                <button type="submit" class="btn-icon" style="color:#34d399; border-color:rgba(52,211,153,0.3); background:rgba(52,211,153,0.1);" title="Mark as Completed" onclick="return confirm('Mark this task as completed?')">
                                                                                                    <i class="bi bi-check-circle-fill"></i>
                                                                                                </button>
                                                                                            </form>
                                                                                        </c:if>
                                                                                        <a class="btn-icon" style="color:#60a5fa; border-color:rgba(96,165,250,0.3); background:rgba(96,165,250,0.1);" href="MainController?action=maintenanceEdit&maintenanceId=${item.maintenanceId}&returnTo=dashboard" title="Edit Task">
                                                                                            <i class="bi bi-pencil-fill"></i>
                                                                                        </a>
                                                                                        <form action="MainController" method="post" style="display:inline;">
                                                                                            <input type="hidden" name="action" value="maintenanceDelete">
                                                                                            <input type="hidden" name="maintenanceId" value="${item.maintenanceId}">
                                                                                            <input type="hidden" name="returnTo" value="dashboard">
                                                                                            <button type="submit" class="btn-icon" style="color:#f87171; border-color:rgba(248,113,113,0.3); background:rgba(248,113,113,0.1);" title="Delete Task" onclick="return confirm('Delete this task?')">
                                                                                                <i class="bi bi-trash3-fill"></i>
                                                                                            </button>
                                                                                        </form>
                                                                                    </div>
                                                                                </td>
                                                                            </tr>
                                                                            <c:remove var="now" />
                                                                        </c:forEach>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <tr>
                                                                            <td colspan="6">
                                                                                <div class="rt-empty" style="padding:40px; text-align:center; color:var(--text-muted);">
                                                                                    <i class="bi bi-tools" style="font-size:30px; display:block; margin-bottom:10px;"></i>
                                                                                    No maintenance tasks scheduled.
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
                                            
                                            <script>
                                                document.addEventListener("DOMContentLoaded", function() {
                                                    const rows = document.querySelectorAll('#dash-maintenance-table .task-row');
                                                    let total = rows.length;
                                                    let planned = 0, inprogress = 0, completed = 0;
                                                    
                                                    rows.forEach(row => {
                                                        let status = row.getAttribute('data-status');
                                                        if(status === 'PLANNED') planned++;
                                                        else if(status === 'IN_PROGRESS' || status === 'OVERDUE') inprogress++;
                                                        else if(status === 'COMPLETED') completed++;
                                                    });
                                                    
                                                    if(document.getElementById('cnt-all')) {
                                                        document.getElementById('cnt-all').innerText = total;
                                                        document.getElementById('cnt-planned').innerText = planned;
                                                        document.getElementById('cnt-inprogress').innerText = inprogress;
                                                        document.getElementById('cnt-completed').innerText = completed;
                                                        
                                                        // Update KPI Cards
                                                        document.getElementById('kpi-total').innerText = total;
                                                        document.getElementById('kpi-planned').innerText = planned;
                                                        document.getElementById('kpi-inprogress').innerText = inprogress;
                                                        document.getElementById('kpi-completed').innerText = completed;
                                                    }
                                                    
                                                    // Initialize Chart
                                                    if(planned > 0 || inprogress > 0 || completed > 0) {
                                                        const ctx = document.getElementById('dashMaintenanceChart').getContext('2d');
                                                        new Chart(ctx, {
                                                            type: 'doughnut',
                                                            data: {
                                                                labels: ['Planned', 'In Progress', 'Completed'],
                                                                datasets: [{
                                                                    data: [planned, inprogress, completed],
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
                                                        document.getElementById('dashMaintenanceChart').style.display = 'none';
                                                    }
                                                });

                                                function filterDashTasks(status, element) {
                                                    const tabsContainer = element.closest('.sev-tabs');
                                                    if(tabsContainer && element) {
                                                        tabsContainer.querySelectorAll('.sev-tab').forEach(tab => tab.classList.remove('active'));
                                                        element.classList.add('active');
                                                    }
                                                    applyMaintenanceFilter();
                                                }

                                                function applyMaintenanceFilter() {
                                                    let activeTab = document.querySelector('#dash-maintenance-tabs .sev-tab.active');
                                                    let status = 'ALL';
                                                    if(activeTab) {
                                                        if(activeTab.classList.contains('tab-planned')) status = 'PLANNED';
                                                        else if(activeTab.classList.contains('tab-inprogress')) status = 'IN_PROGRESS';
                                                        else if(activeTab.classList.contains('tab-completed')) status = 'COMPLETED';
                                                    }

                                                    const allRows = Array.from(document.querySelectorAll('#dash-maintenance-table .task-row'));
                                                    const searchInput = document.getElementById('dash-maintenance-search');
                                                    const searchQuery = searchInput ? searchInput.value.toLowerCase().trim() : '';
                                                    let matchingRows = [];
                                                    
                                                    allRows.forEach(row => {
                                                        row.style.display = 'none'; // hide initially
                                                        let rowStatus = row.getAttribute('data-status');
                                                        let textContent = row.innerText.toLowerCase();
                                                        
                                                        let statusMatch = false;
                                                        // Group OVERDUE into IN_PROGRESS for filtering
                                                        if(status === 'IN_PROGRESS' && rowStatus === 'OVERDUE') statusMatch = true;
                                                        else if (status === 'ALL' || rowStatus === status) statusMatch = true;

                                                        let searchMatch = searchQuery === '' || textContent.includes(searchQuery);

                                                        if (statusMatch && searchMatch) {
                                                            matchingRows.push(row);
                                                        }
                                                    });

                                                    let emptyMsg = document.getElementById('empty-dash-msg');
                                                    if(matchingRows.length === 0) {
                                                        if(!emptyMsg) {
                                                            const tbody = document.querySelector('#dash-maintenance-table tbody');
                                                            const tr = document.createElement('tr');
                                                            tr.id = 'empty-dash-msg';
                                                            tr.innerHTML = `<td colspan="6" style="text-align:center; padding: 40px; color:var(--text-muted);"><i class="bi bi-search fs-1 mb-2 d-block text-secondary" style="opacity:0.5;"></i> No tasks match your search or filter.</td>`;
                                                            if(tbody) tbody.appendChild(tr);
                                                        }
                                                        let pag = document.querySelector('#dash-maintenance-table').closest('.section-card').querySelector('.pagination-controls');
                                                        if(pag) pag.style.display = 'none';
                                                    } else {
                                                        if(emptyMsg) emptyMsg.remove();
                                                        let pag = document.querySelector('#dash-maintenance-table').closest('.section-card').querySelector('.pagination-controls');
                                                        if(pag) pag.style.display = 'flex';
                                                        initPagination('dash-maintenance-table', matchingRows);
                                                    }
                                                }

                                            </script>
                                        </div>

                                        <div class="page-section" id="page-rooms">
                                            <div class="section-card">

                                                <div class="section-card-header">
                                                    <h6>
                                                        <i class="bi bi-building me-2"></i>
                                                        Room Management
                                                    </h6>

                                                    <a class="btn-theme text-decoration-none"
                                                       href="MainController?action=roomAdd&returnTo=dashboard">
                                                        <i class="bi bi-plus-lg me-1"></i>
                                                        Add Room
                                                    </a>
                                                </div>

                                                <div class="section-card-body" style="padding:0;">
                                                    <div class="module-tools"
                                                         data-module-tools="rooms">
                                                        <input class="module-search"
                                                               type="search"
                                                               data-module-search="rooms"
                                                               placeholder="Search by room name or building">
                                                        <span class="module-count"
                                                              data-module-count="rooms"></span>
                                                        <div class="module-pager"
                                                             data-module-pager="rooms"></div>
                                                    </div>
                                                    <div style="overflow-x:auto;">

                                                        <table class="rt-table">
                                                            <thead>
                                                                <tr>
                                                                    <th><i class="bi bi-hash me-1"></i>ID</th>
                                                                    <th><i class="bi bi-building me-1"></i>Room Name</th>
                                                                    <th><i class="bi bi-bank me-1"></i>Building</th>
                                                                    <th><i class="bi bi-layers me-1"></i>Floor</th>
                                                                    <th><i class="bi bi-people me-1"></i>Capacity</th>
                                                                    <th><i class="bi bi-three-dots me-1"></i>Actions</th>
                                                                </tr>
                                                            </thead>

                                                            <tbody>
                                                                <% if (roomList != null && !roomList.isEmpty()) {
                                                                    for (RoomDTO room : roomList) {
                                                                %>

                                                                <tr data-module-row="rooms"
                                                                    data-search="<%= room.getRoomId() %> <%= room.getRoomName() %> <%= room.getBuilding() == null ? "" : room.getBuilding() %> <%= room.getFloor() %> <%= room.getCapacity() %>">
                                                                    <td>
                                                                        <span class="rt-id">
                                                                            #<%= room.getRoomId() %>
                                                                        </span>
                                                                    </td>
                                                                    <td>
                                                                        <div class="room-name-cell">
                                                                            <span class="room-icon">
                                                                                <i class="bi bi-door-open"></i>
                                                                            </span>
                                                                            <span><%= room.getRoomName() %></span>
                                                                        </div>
                                                                    </td>
                                                                    <td>
                                                                        <% if (room.getBuilding() == null
                                                                                || room.getBuilding().trim().isEmpty()) { %>
                                                                        <span style="color:var(--text-muted);">
                                                                            Not specified
                                                                        </span>
                                                                        <% } else { %>
                                                                        <span class="room-chip">
                                                                            <%= room.getBuilding() %>
                                                                        </span>
                                                                        <% } %>
                                                                    </td>
                                                                    <td>
                                                                        <span class="room-chip">
                                                                            Floor <%= room.getFloor() %>
                                                                        </span>
                                                                    </td>
                                                                    <td>
                                                                        <span class="room-chip">
                                                                            <%= room.getCapacity() %> seats
                                                                        </span>
                                                                    </td>

                                                                    <td>
                                                                        <div class="rt-actions">

                                                                            <a class="rt-btn rt-btn-edit"
                                                                               href="MainController?action=roomEdit&id=<%= room.getRoomId() %>&returnTo=dashboard"
                                                                               title="Edit Room">
                                                                                <i class="bi bi-pencil-fill"></i>
                                                                            </a>

                                                                            <form action="MainController"
                                                                                  method="post"
                                                                                  onsubmit="return confirm('Are you sure you want to delete this room?');">

                                                                                <input type="hidden"
                                                                                       name="action"
                                                                                       value="roomDelete">

                                                                                <input type="hidden"
                                                                                       name="roomId"
                                                                                       value="<%= room.getRoomId() %>">

                                                                                <input type="hidden"
                                                                                       name="returnTo"
                                                                                       value="dashboard">

                                                                                <button class="rt-btn rt-btn-del"
                                                                                        type="submit"
                                                                                        title="Delete Room">
                                                                                    <i class="bi bi-trash3-fill"></i>
                                                                                </button>
                                                                            </form>

                                                                        </div>
                                                                    </td>
                                                                </tr>

                                                                <%
                                                                    }
                                                                } else {
                                                                %>

                                                                <tr>
                                                                    <td colspan="6">
                                                                        <div class="placeholder-box my-0">
                                                                            <i class="bi bi-building"
                                                                               style="font-size:26px;"></i>
                                                                            <br>
                                                                            No rooms found.
                                                                        </div>
                                                                    </td>
                                                                </tr>

                                                                <%
                                                                }
                                                                %>
                                                            </tbody>
                                                        </table>

                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <c:if test="${isAdmin}">
                                            <div class="page-section" id="page-users">
                                                <div class="section-card">
                                                    <div class="section-card-header">
                                                        <h6><i class="bi bi-people me-2"></i>User Management</h6><button
                                                            class="btn-theme"><i class="bi bi-person-plus me-1"></i>Add
                                                            User</button>
                                                    </div>
                                                    <div class="section-card-body">
                                                        <div class="placeholder-box">All system users will appear here
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="page-section" id="page-authlogs">
                                                <div class="section-card">
                                                    <div class="section-card-header">
                                                        <h6><i class="bi bi-shield-check me-2"></i>Authentication Logs
                                                        </h6>
                                                    </div>
                                                    <div class="section-card-body">
                                                        <div class="placeholder-box">Login history will appear here
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="page-section" id="page-systemlogs">
                                                <div class="section-card">
                                                    <div class="section-card-header">
                                                        <h6><i class="bi bi-journal-text me-2"></i>System Logs</h6>
                                                    </div>
                                                    <div class="section-card-body">
                                                        <div class="placeholder-box">System action logs will appear here
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:if>
                        </div>
                    </div>

                    <div class="modal fade"
                         id="dashboardReleaseIpModal"
                         tabindex="-1"
                         aria-labelledby="dashboardReleaseIpModalLabel"
                         aria-hidden="true">
                        <div class="modal-dialog modal-dialog-centered">
                            <div class="modal-content"
                                 style="background:#10172a;border:1px solid var(--border);color:var(--text-primary);">
                                <form action="MainController"
                                      method="post">
                                    <div class="modal-header"
                                         style="border-color:var(--border);">
                                        <h5 class="modal-title"
                                            id="dashboardReleaseIpModalLabel">
                                            Release IP address?
                                        </h5>
                                        <button type="button"
                                                class="btn-close btn-close-white"
                                                data-bs-dismiss="modal"
                                                aria-label="Close"></button>
                                    </div>
                                    <div class="modal-body">
                                        <input type="hidden"
                                               name="action"
                                               value="ipRelease">
                                        <input type="hidden"
                                               name="ipId"
                                               id="dashboardReleaseIpId">
                                        <input type="hidden"
                                               name="returnTo"
                                               value="dashboard">

                                        <p class="mb-2">
                                            Are you sure you want to release
                                            <strong id="dashboardReleaseIpAddress"></strong>?
                                        </p>
                                        <p class="text-secondary mb-0">
                                            The device will no longer keep this assigned IP.
                                        </p>
                                    </div>
                                    <div class="modal-footer"
                                         style="border-color:var(--border);">
                                        <button type="button"
                                                class="btn btn-outline-light"
                                                data-bs-dismiss="modal">
                                            Cancel
                                        </button>
                                        <button type="submit"
                                                class="btn btn-warning">
                                            <i class="bi bi-unlink me-1"></i>
                                            Release
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
                    <script>
                        const pageTitles = {
                            dashboard:     { title: 'Dashboard',             breadcrumb: '/ Overview' },
                            devices:       { title: 'Network Devices',       breadcrumb: '/ Infrastructure' },
                            accesspoints:  { title: 'Access Points',         breadcrumb: '/ Infrastructure' },
                            routers:       { title: 'Routers',               breadcrumb: '/ Infrastructure' },
                            switches:      { title: 'Switches',              breadcrumb: '/ Infrastructure' },
                            vlan:          { title: 'VLAN Management',       breadcrumb: '/ Infrastructure' },
                            ipmanage:      { title: 'IP Address Management', breadcrumb: '/ Infrastructure' },
                            bandwidth:     { title: 'Bandwidth Usage',       breadcrumb: '/ Monitoring' },
                            wifianalytics: { title: 'WiFi Analytics',        breadcrumb: '/ Monitoring' },
                            alerts:        { title: 'Network Alerts',        breadcrumb: '/ Monitoring' },
                            tickets:       { title: 'Support Tickets',       breadcrumb: '/ Support' },
                            maintenance:   { title: 'Maintenance Schedule',  breadcrumb: '/ Support' },
                            rooms:         { title: 'Room / Area Map',       breadcrumb: '/ Facilities' },
                            users:         { title: 'Manage Users',          breadcrumb: '/ Administration' },
                            authlogs:      { title: 'Authentication Logs',   breadcrumb: '/ Administration' },
                            systemlogs:    { title: 'System Logs',           breadcrumb: '/ Administration' }
                        };

                        function showPage(pageKey, clickedBtn) {
                            // Hide all page sections
                            document.querySelectorAll('.page-section').forEach(function(sec) {
                                sec.classList.remove('active');
                            });

                            // Show the target section
                            var target = document.getElementById('page-' + pageKey);
                            if (target) {
                                target.classList.add('active');
                            }

                            // Update active state on sidebar buttons
                            document.querySelectorAll('.nav-item-link').forEach(function(btn) {
                                btn.classList.remove('active');
                            });
                            if (clickedBtn) {
                                clickedBtn.classList.add('active');
                            }

                            // Update topbar title and breadcrumb
                            var info = pageTitles[pageKey] || { title: pageKey, breadcrumb: '' };
                            var titleEl = document.getElementById('pageTitle');
                            var breadEl = document.getElementById('pageBreadcrumb');
                            if (titleEl) titleEl.textContent = info.title;
                            if (breadEl) breadEl.textContent = info.breadcrumb;
                        }

                        var modulePageSize = 9;
                        var moduleState = {
                            ipmanage: { page: 1, keyword: '', status: 'ALL' },
                            vlan: { page: 1, keyword: '', status: 'ALL' },
                            tickets: { page: 1, keyword: '', status: 'ALL' },
                            rooms: { page: 1, keyword: '', status: 'ALL' }
                        };

                        function getModuleRows(moduleKey) {
                            return Array.prototype.slice.call(
                                    document.querySelectorAll('[data-module-row="' + moduleKey + '"]')
                            );
                        }

                        function rowMatchesModule(row, state) {
                            var text = (row.getAttribute('data-search') || row.textContent || '').toLowerCase();
                            var keywordOk = !state.keyword || text.indexOf(state.keyword) >= 0;
                            var statusOk = state.status === 'ALL'
                                    || row.getAttribute('data-ip-status') === state.status;
                            return keywordOk && statusOk;
                        }

                        function renderModuleTable(moduleKey) {
                            var state = moduleState[moduleKey];
                            if (!state) return;

                            var rows = getModuleRows(moduleKey);
                            var matchedRows = rows.filter(function(row) {
                                return rowMatchesModule(row, state);
                            });

                            var totalPages = Math.ceil(matchedRows.length / modulePageSize);
                            var start = (state.page - 1) * modulePageSize;
                            var end = start + modulePageSize;

                            rows.forEach(function(row) {
                                row.style.display = 'none';
                            });

                            matchedRows.slice(start, end).forEach(function(row) {
                                row.style.display = '';
                            });

                            var countEl = document.querySelector('[data-module-count="' + moduleKey + '"]');
                            if (countEl) {
                                countEl.textContent = matchedRows.length + ' records';
                            }

                            renderModulePager(moduleKey, totalPages);
                        }

                        function renderModulePager(moduleKey, totalPages) {
                            var state = moduleState[moduleKey];
                            var pager = document.querySelector('[data-module-pager="' + moduleKey + '"]');
                            if (!pager) return;

                            pager.innerHTML = '';

                            if (totalPages <= 0) {
                                return;
                            }

                            var prev = createModulePageButton('Prev', state.page - 1, moduleKey);
                            prev.disabled = state.page <= 1;
                            pager.appendChild(prev);

                            getVisibleModulePages(state.page, totalPages).forEach(function(page) {
                                if (page === '...') {
                                    var ellipsis = document.createElement('span');
                                    ellipsis.className = 'module-page-ellipsis';
                                    ellipsis.textContent = '...';
                                    pager.appendChild(ellipsis);
                                    return;
                                }

                                var btn = createModulePageButton(page, page, moduleKey);
                                if (page === state.page) {
                                    btn.classList.add('active');
                                }
                                pager.appendChild(btn);
                            });

                            var next = createModulePageButton('Next', state.page + 1, moduleKey);
                            next.disabled = state.page >= totalPages;
                            pager.appendChild(next);
                        }

                        function getVisibleModulePages(currentPage, totalPages) {
                            if (totalPages <= 5) {
                                var allPages = [];
                                for (var i = 1; i <= totalPages; i++) {
                                    allPages.push(i);
                                }
                                return allPages;
                            }

                            if (currentPage <= 3) {
                                return [1, 2, 3, '...', totalPages];
                            }

                            if (currentPage >= totalPages - 2) {
                                return [1, '...', totalPages - 2, totalPages - 1, totalPages];
                            }

                            return [1, '...', currentPage - 1, currentPage, currentPage + 1, '...', totalPages];
                        }

                        function createModulePageButton(label, page, moduleKey) {
                            var button = document.createElement('button');
                            button.type = 'button';
                            button.className = 'module-page-btn';
                            button.textContent = label;
                            button.addEventListener('click', function() {
                                moduleState[moduleKey].page = page;
                                renderModuleTable(moduleKey);
                            });
                            return button;
                        }

                        function filterIpam(status) {
                            moduleState.ipmanage.status = status;
                            moduleState.ipmanage.page = 1;
                            renderModuleTable('ipmanage');
                        }

                        document.addEventListener('DOMContentLoaded', function() {
                            Object.keys(moduleState).forEach(function(moduleKey) {
                                var input = document.querySelector('[data-module-search="' + moduleKey + '"]');
                                if (input) {
                                    input.addEventListener('input', function() {
                                        moduleState[moduleKey].keyword = input.value.trim().toLowerCase();
                                        moduleState[moduleKey].page = 1;
                                        renderModuleTable(moduleKey);
                                    });
                                }
                                renderModuleTable(moduleKey);
                            });

                            document.querySelectorAll('.dashboard-release-ip').forEach(function(button) {
                                button.addEventListener('click', function() {
                                    var ipId = button.getAttribute('data-ip-id');
                                    var ipAddress = button.getAttribute('data-ip-address');
                                    document.getElementById('dashboardReleaseIpId').value = ipId;
                                    document.getElementById('dashboardReleaseIpAddress').textContent = ipAddress;
                                });
                            });

                            var params = new URLSearchParams(window.location.search);
                            var page = params.get('page');
                            if (page && pageTitles[page]) {
                                var target = document.getElementById('page-' + page);
                                if (target) {
                                    document.querySelectorAll('.page-section').forEach(function(s) {
                                        s.classList.remove('active');
                                    });
                                    target.classList.add('active');
                                }
                                var info = pageTitles[page];
                                var titleEl = document.getElementById('pageTitle');
                                var breadEl = document.getElementById('pageBreadcrumb');
                                if (titleEl) titleEl.textContent = info.title;
                                if (breadEl) breadEl.textContent = info.breadcrumb;
                            }
                        });

                        // Pagination
                        const PAGE_SIZE = 10;
                        const paginationState = {};

                        function initPagination(tableId, rowsArray) {
                            let rows = rowsArray;
                            if (!rows) {
                                const tbody = document.querySelector('#' + tableId + ' tbody');
                                if (!tbody) return;
                                // skip empty message rows
                                rows = Array.from(tbody.querySelectorAll('tr')).filter(r => !r.id || !r.id.startsWith('empty'));
                            }
                            const total = Math.max(1, Math.ceil(rows.length / PAGE_SIZE));
                            paginationState[tableId] = { current: 1, total: total, rows: rows };
                            showPageForTable(tableId);
                        }

                        function showPageForTable(tableId) {
                            const state = paginationState[tableId];
                            if (!state) return;
                            
                            // First hide all rows
                            const tbody = document.querySelector('#' + tableId + ' tbody');
                            if (tbody) {
                                Array.from(tbody.querySelectorAll('tr')).filter(r => !r.id || !r.id.startsWith('empty')).forEach(r => r.style.display = 'none');
                            }

                            const start = (state.current - 1) * PAGE_SIZE;
                            const end = start + PAGE_SIZE;
                            state.rows.forEach(function(r, i) {
                                r.style.display = (i >= start && i < end) ? '' : 'none';
                            });
                            const infoEl = document.getElementById(tableId + '-page-info');
                            if(infoEl) infoEl.textContent = 'Page ' + state.current + ' of ' + state.total;
                            const prevBtn = document.getElementById(tableId + '-prev');
                            if(prevBtn) prevBtn.disabled = state.current <= 1;
                            const nextBtn = document.getElementById(tableId + '-next');
                            if(nextBtn) nextBtn.disabled = state.current >= state.total;
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
                            initPagination('dash-bandwidth-table');
                            applyMaintenanceFilter(); // This will init dash-maintenance-table pagination
                        });
                    </script>
                    <style>
                        /* Pagination Controls */
                        .pagination-controls { display: flex; align-items: center; gap: 8px; }
                        .pagination-controls .page-btn { width: 32px; height: 32px; border-radius: 8px; border: 1px solid var(--border); background: rgba(139, 92, 246, 0.15); color: #e8ddff; display: flex; align-items: center; justify-content: center; cursor: pointer; transition: 0.15s ease; font-size: 14px; }
                        .pagination-controls .page-btn:hover { background: rgba(139, 92, 246, 0.3); border-color: rgba(139, 92, 246, 0.6); }
                        .pagination-controls .page-btn:disabled { opacity: 0.35; cursor: not-allowed; }
                        .pagination-controls .page-info { font-size: 12px; color: var(--text-muted); min-width: 70px; text-align: center; }
                    </style>
                </body>

                </html>
