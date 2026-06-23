<%-- staffDashboard.jsp - Dashboard for staff members --%>
    <%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
    <%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
        <%@page import="Models.UserDTO" %>
            <% UserDTO currentUser=(UserDTO) session.getAttribute("user"); String role=(String)
                session.getAttribute("role"); if (currentUser==null || role==null || (!role.equalsIgnoreCase("Admin") &&
                !role.equalsIgnoreCase("Technician"))) { response.sendRedirect("login.jsp"); return; } String
                displayName=currentUser.getFullName() !=null ? currentUser.getFullName() : currentUser.getUserName();
                boolean isAdmin=role.equalsIgnoreCase("Admin"); %>
                <c:set var="displayName" value="${empty sessionScope.user.fullName ? sessionScope.user.userName : sessionScope.user.fullName}" />
                <c:set var="isAdmin" value="${fn:toLowerCase(sessionScope.role) eq 'admin'}" />
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>User Management — Network Manager</title>
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

                        body {
                            margin: 0;
                            background:
                                linear-gradient(rgba(5, 8, 18, 0.82), rgba(6, 9, 20, 0.78)),
                                radial-gradient(circle at 12% 12%, rgba(139, 92, 246, 0.16), transparent 28%),
                                url('theme/original-d5209459af4999984ad44693bbcb28f7.webp') center/cover fixed no-repeat;
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

                        /* Custom User Management Styles */
                        .table-dark-custom {
                            width: 100%;
                            color: var(--text-primary);
                            border-collapse: collapse;
                            margin-top: 15px;
                        }
                        .table-dark-custom th, .table-dark-custom td {
                            padding: 12px 15px;
                            border: 1px solid var(--border);
                            text-align: left;
                        }
                        .table-dark-custom th {
                            background-color: var(--surface-2);
                            color: #a5b2d8;
                            font-weight: 600;
                        }
                        .table-dark-custom tr:hover {
                            background-color: rgba(139, 92, 246, 0.05);
                        }
                        .form-control-dark {
                            background-color: #0f162b;
                            border: 1px solid var(--border);
                            color: var(--text-primary);
                            border-radius: 6px;
                            padding: 6px 12px;
                        }
                        .form-control-dark:focus {
                            outline: none;
                            border-color: var(--neon-purple);
                            box-shadow: 0 0 0 2px rgba(139, 92, 246, 0.25);
                        }
                        .modal-content-dark {
                            background-color: var(--surface);
                            border: 1px solid var(--border);
                            color: var(--text-primary);
                            border-radius: var(--radius-lg);
                        }
                        .modal-header-dark {
                            border-bottom: 1px solid var(--border);
                            padding: 15px 20px;
                        }
                        .modal-footer-dark {
                            border-top: 1px solid var(--border);
                            padding: 15px 20px;
                        }
                        .badge-status-active { background: rgba(74, 222, 128, 0.16); color: #4ade80; padding: 4px 10px; border-radius: 999px; font-size: 11px; font-weight: 700; border: 1px solid rgba(74, 222, 128, 0.4); display: inline-block; }
                        .badge-status-inactive { background: rgba(239, 68, 68, 0.16); color: #f87171; padding: 4px 10px; border-radius: 999px; font-size: 11px; font-weight: 700; border: 1px solid rgba(239, 68, 68, 0.4); display: inline-block; }
                        .pagination-controls { display: flex; align-items: center; gap: 8px; }
                        .pagination-controls .page-btn { width: 32px; height: 32px; border-radius: 8px; border: 1px solid var(--border); background: rgba(139, 92, 246, 0.15); color: #e8ddff; display: flex; align-items: center; justify-content: center; cursor: pointer; transition: 0.15s ease; font-size: 14px; }
                        .pagination-controls .page-btn:hover { background: rgba(139, 92, 246, 0.3); border-color: rgba(139, 92, 246, 0.6); }
                        .pagination-controls .page-btn:disabled { opacity: 0.35; cursor: not-allowed; }
                        .pagination-controls .page-info { font-size: 12px; color: var(--text-muted); min-width: 70px; text-align: center; }

                        /* ══════════════ NEW TABLE DESIGN ══════════════ */
                        .page-manage-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:20px; gap:12px; flex-wrap:wrap; }
                        .page-header-left { display:flex; align-items:center; gap:12px; }
                        .page-header-icon { width:44px; height:44px; background:linear-gradient(135deg,var(--neon-purple),var(--neon-blue)); border-radius:var(--radius-md); display:flex; align-items:center; justify-content:center; font-size:20px; box-shadow:var(--glow); flex-shrink:0; }
                        .page-header-title { font-size:20px; font-weight:700; letter-spacing:-0.3px; background:linear-gradient(90deg,#f2f5ff 0%,var(--neon-cyan) 100%); -webkit-background-clip:text; -webkit-text-fill-color:transparent; background-clip:text; margin:0; line-height:1.2; }
                        .page-header-subtitle { color:var(--text-muted); font-size:13px; margin:0; }
                        .page-header-right { display:flex; align-items:center; gap:8px; flex-wrap:wrap; }

                        .btn-dash { display:inline-flex; align-items:center; gap:6px; padding:8px 16px; border-radius:var(--radius-md); font-size:13px; font-weight:600; border:none; cursor:pointer; text-decoration:none; transition:all .2s; white-space:nowrap; }
                        .btn-dash-ghost { background:rgba(42,53,85,0.55); color:var(--text-muted); border:1px solid var(--border); }
                        .btn-dash-ghost:hover { background:rgba(42,53,85,0.85); color:var(--text-primary); border-color:var(--neon-blue); box-shadow:0 0 12px rgba(96,165,250,0.18); }
                        .btn-dash-primary { background:linear-gradient(135deg,var(--neon-purple),#6d28d9); color:#fff; box-shadow:0 4px 14px rgba(139,92,246,0.35); }
                        .btn-dash-primary:hover { background:linear-gradient(135deg,#a78bfa,var(--neon-purple)); transform:translateY(-1px); box-shadow:0 6px 20px rgba(139,92,246,0.5); color:#fff; }
                        .btn-dash-cyan { background:rgba(34,211,238,0.12); color:var(--neon-cyan); border:1px solid rgba(34,211,238,0.3); }
                        .btn-dash-cyan:hover { background:rgba(34,211,238,0.22); box-shadow:0 0 12px rgba(34,211,238,0.2); }
                        .btn-dash-cyan.active { background:rgba(34,211,238,0.28); border-color:var(--neon-cyan); box-shadow:0 0 14px rgba(34,211,238,0.3); }

                        .stats-bar { display:flex; gap:10px; margin-bottom:18px; flex-wrap:wrap; }
                        .stat-chip { display:flex; align-items:center; gap:7px; background:rgba(16,23,42,0.8); border:1px solid var(--border); border-radius:8px; padding:7px 14px; font-size:12px; color:var(--text-muted); }
                        .stat-chip strong { color:var(--text-primary); }

                        .manage-table-card { background:rgba(16,23,42,0.82); border:1px solid var(--border); border-radius:var(--radius-lg); overflow:hidden; box-shadow:0 8px 40px rgba(0,0,0,0.45); backdrop-filter:blur(12px); }
                        .manage-table-card table { width:100%; border-collapse:collapse; font-size:13px; }
                        .manage-table-card thead tr { background:rgba(22,31,54,0.95); border-bottom:1px solid var(--border); }
                        .manage-table-card thead th { padding:11px 14px; color:var(--text-muted); font-weight:600; font-size:11px; letter-spacing:.08em; text-transform:uppercase; white-space:nowrap; }
                        .manage-table-card tbody tr { border-bottom:1px solid rgba(42,53,85,0.4); transition:background .18s; }
                        .manage-table-card tbody tr:last-child { border-bottom:none; }
                        .manage-table-card tbody tr:hover { background:rgba(139,92,246,0.06); }
                        .manage-table-card tbody td { padding:10px 14px; vertical-align:middle; }

                        .id-badge { display:inline-flex; background:rgba(96,165,250,0.12); border:1px solid rgba(96,165,250,0.25); color:var(--neon-blue); border-radius:5px; padding:1px 8px; font-size:11px; font-weight:700; font-family:monospace; }
                        .role-badge { padding:2px 9px; border-radius:999px; font-size:10px; font-weight:700; display:inline-block; }
                        .role-admin { background:rgba(239,68,68,0.16); border:1px solid rgba(239,68,68,0.4); color:#fecaca; }
                        .role-tech { background:rgba(139,92,246,0.16); border:1px solid rgba(139,92,246,0.4); color:#ddd6fe; }
                        .role-viewer { background:rgba(96,165,250,0.16); border:1px solid rgba(96,165,250,0.4); color:#93c5fd; }
                        .status-badge { padding:2px 9px; border-radius:999px; font-size:10px; font-weight:700; display:inline-flex; align-items:center; gap:4px; white-space:nowrap; }
                        .status-active { background:rgba(74,222,128,0.16); border:1px solid rgba(74,222,128,0.4); color:#4ade80; }
                        .status-inactive { background:rgba(239,68,68,0.16); border:1px solid rgba(239,68,68,0.4); color:#f87171; }
                        .status-dot { width:5px; height:5px; border-radius:50%; display:inline-block; }
                        .status-dot-green { background:#4ade80; box-shadow:0 0 6px #4ade80; }
                        .status-dot-red { background:#f87171; }
                        .username-cell { font-weight:600; }

                        .action-group { display:flex; gap:3px; justify-content:center; }
                        .btn-icon { width:26px; height:26px; border-radius:5px; display:inline-flex; align-items:center; justify-content:center; font-size:11px; cursor:pointer; text-decoration:none; border:1px solid transparent; transition:all .2s; }
                        .btn-icon-view { border-color:rgba(139,92,246,0.3); color:var(--neon-purple); background:rgba(139,92,246,0.08); }
                        .btn-icon-view:hover { background:rgba(139,92,246,0.2); box-shadow:0 0 8px rgba(139,92,246,0.3); }
                        .btn-icon-edit { border-color:rgba(96,165,250,0.3); color:var(--neon-blue); background:rgba(96,165,250,0.08); }
                        .btn-icon-edit:hover { background:rgba(96,165,250,0.2); box-shadow:0 0 8px rgba(96,165,250,0.3); }
                        .btn-icon-delete { border-color:rgba(248,113,113,0.3); color:#f87171; background:rgba(248,113,113,0.08); }
                        .btn-icon-delete:hover { background:rgba(248,113,113,0.2); box-shadow:0 0 8px rgba(248,113,113,0.3); }

                        .pagination-bar { display:flex; align-items:center; justify-content:space-between; margin-bottom:10px; }
                        .pagination-controls-new { display:flex; align-items:center; gap:6px; }

                        .fullview-info { display:flex; align-items:center; justify-content:space-between; margin-bottom:10px; }
                        .fullview-info .fv-label { font-size:12px; color:var(--neon-cyan); font-weight:600; }
                        .fullview-info .fv-hint { font-size:11px; color:var(--text-muted); }
                        .table-wrap { max-height:420px; overflow-y:auto; }
                        .table-wrap thead th { position:sticky; top:0; z-index:2; }

                        .detail-overlay { display:none; position:fixed; inset:0; background:rgba(5,7,13,0.75); backdrop-filter:blur(6px); z-index:1000; align-items:center; justify-content:center; }
                        .detail-overlay.show { display:flex; }
                        .detail-panel { background:linear-gradient(180deg,rgba(20,28,48,0.98),rgba(15,21,38,0.99)); border:1px solid var(--border); border-radius:16px; width:90%; max-width:520px; padding:28px; box-shadow:0 24px 80px rgba(0,0,0,0.6); position:relative; animation:fadeInUp .2s ease; }
                        .detail-close { position:absolute; top:16px; right:18px; width:28px; height:28px; border-radius:50%; border:1px solid var(--border); display:flex; align-items:center; justify-content:center; color:var(--text-muted); font-size:14px; cursor:pointer; background:transparent; transition:.15s; }
                        .detail-close:hover { background:rgba(239,68,68,0.15); border-color:rgba(239,68,68,0.4); color:#f87171; }
                        .detail-avatar { width:52px; height:52px; border-radius:13px; display:flex; align-items:center; justify-content:center; color:#fff; font-weight:700; font-size:20px; flex-shrink:0; }
                        .detail-section-label { font-size:10px; text-transform:uppercase; letter-spacing:.1em; color:#7f8db4; margin-bottom:3px; }
                        .detail-value { font-size:13px; color:var(--text-primary); word-break:break-all; }
                        .detail-grid { display:grid; grid-template-columns:1fr 1fr; gap:16px; }

                        .empty-state { padding:48px 16px; text-align:center; }
                        .empty-state i { font-size:40px; color:var(--border); display:block; margin-bottom:10px; }
                        .empty-state p { color:var(--text-muted); margin:0; font-size:13px; }

                        .search-wrap { position:relative; display:inline-block; }
                        .search-wrap i { position:absolute; left:11px; top:50%; transform:translateY(-50%); color:var(--text-muted); font-size:14px; }
                        .search-input { background:rgba(15,22,43,0.9); border:1px solid var(--border); color:var(--text-primary); border-radius:8px; padding:8px 12px 8px 34px; font-size:13px; width:100%; max-width:280px; outline:none; transition:border-color .2s; }
                        .search-input:focus { border-color:var(--neon-purple); box-shadow:0 0 0 2px rgba(139,92,246,0.2); }

                        /* ── FullView page mode ── */
                        body.fullview-mode .sidebar { display:none; }
                        body.fullview-mode .main-content { margin-left:0; }
                        body.fullview-mode .topbar { display:none; }
                        body.fullview-mode .page-body { max-width:1400px; margin:0 auto; padding:32px 24px; }
                        body.fullview-mode .page-manage-header { display:none; }
                        body.fullview-mode .stats-bar { display:none; }
                        body.fullview-mode .manage-table-card { background:rgba(16,23,42,0.82); border:1px solid var(--border); border-radius:var(--radius-lg); box-shadow:0 8px 40px rgba(0,0,0,0.45); backdrop-filter:blur(12px); overflow:hidden; }
                        body.fullview-mode .table-wrap { max-height:none; overflow-y:visible; }
                        body.fullview-mode .page-section { padding:0; }

                        .fv-page-wrap { display:none; }
                        body.fullview-mode .fv-page-wrap { display:block; }

                        .fv-page-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:28px; gap:16px; flex-wrap:wrap; }
                        .fv-page-title-group { display:flex; align-items:center; gap:16px; }
                        .fv-page-title-group .page-title { font-size:1.7rem; font-weight:700; letter-spacing:-0.5px; background:linear-gradient(90deg,#f2f5ff 0%,var(--neon-cyan) 100%); -webkit-background-clip:text; -webkit-text-fill-color:transparent; background-clip:text; margin:0; }
                        .fv-page-title-group .page-subtitle { color:var(--text-muted); font-size:0.82rem; margin:2px 0 0; }

                        @keyframes fadeInUp { from { opacity:0; transform:translateY(16px); } to { opacity:1; transform:translateY(0); } }
                    </style>
                </head>

                <body>

                    <c:set var="sidebarActive" value="users" scope="request" />
                    <%@include file="sidebar.jsp" %>

                    <div class="main-content">
                        <div class="topbar">
                            <div>
                                <span class="topbar-title" id="pageTitle">Dashboard</span>
                                <span class="topbar-breadcrumb" id="pageBreadcrumb">/ Overview</span>
                            </div>
                            <div class="d-flex align-items-center gap-2">
                                <span class="<%= isAdmin ? " role-badge-admin" : "role-badge-tech" %>"><%= role %>
                                </span>
                                <span style="font-size:13px;color:#9db0db;">Welcome, <strong style="color:#f2f5ff;">
                                        <%= displayName %>
                                    </strong></span>
                            </div>
                        </div>

                        <div class="page-body">
                            <!-- FullView page header -->
                            <div class="fv-page-wrap" id="fvPageWrap">
                                <div class="fv-page-header">
                                    <div class="fv-page-title-group">
                                        <button class="btn-dash btn-dash-ghost" onclick="toggleFullView()"><i class="bi bi-arrow-left"></i> Back</button>
                                        <div>
                                            <div class="page-title">User Management</div>
                                            <div class="page-subtitle">/ Administration</div>
                                        </div>
                                    </div>
                                    <div class="stat-chip" style="background:rgba(16,23,42,0.8);border:1px solid var(--border);border-radius:8px;padding:8px 16px;font-size:0.8rem;color:var(--text-muted);display:flex;align-items:center;gap:8px;">
                                        <i class="bi bi-people" style="color:var(--neon-blue)"></i>
                                        Total: <strong style="color:var(--text-primary);font-size:1rem;" id="fvPageTotal">0</strong> users
                                    </div>
                                </div>
                            </div>
                                        <% if (isAdmin) { %>
                                            <div class="page-section active" id="page-users">

                                                <div class="page-manage-header">
                                                    <div class="page-header-left">
                                                        <div class="page-header-icon"><i class="bi bi-people-fill"></i></div>
                                                        <div>
                                                            <div class="page-header-title">User Management</div>
                                                            <div class="page-header-subtitle">/ Administration</div>
                                                        </div>
                                                    </div>
                                                    <div class="page-header-right">
                                                        <form action="UserController" method="GET" class="search-wrap" style="margin:0;">
                                                            <input type="hidden" name="action" value="search">
                                                            <i class="bi bi-search"></i>
                                                            <input type="text" name="keyword" class="search-input" placeholder="Search by name, email..." value="${keyword}">
                                                        </form>
                                                        <c:if test="${not empty keyword}">
                                                            <a href="UserController?action=list" class="btn-dash btn-dash-ghost" style="font-size:12px;padding:6px 10px;">Clear</a>
                                                        </c:if>
                                                        <button class="btn-dash btn-dash-cyan" id="fullviewToggle" onclick="toggleFullView()"><i class="bi bi-list-ul"></i> <span id="fullviewLabel">FullView</span></button>
                                                        <button class="btn-dash btn-dash-primary" data-bs-toggle="modal" data-bs-target="#addUserModal"><i class="bi bi-person-plus"></i> Add User</button>
                                                    </div>
                                                </div>

                                                <div class="stats-bar" id="statsBar"></div>

                                                <div class="manage-table-card">
                                                    <div style="padding:12px 16px 0;" id="paginationBar">
                                                        <div class="pagination-bar">
                                                            <span class="pagination-info" id="tableInfo">Showing <strong style="color:#f2f5ff;">0</strong> users</span>
                                                            <div class="pagination-controls-new">
                                                                <button class="page-btn" onclick="prevPage()" id="prevBtn"><i class="bi bi-chevron-left"></i></button>
                                                                <span class="page-label" id="pageLabel">Page 1 of 1</span>
                                                                <button class="page-btn" onclick="nextPage()" id="nextBtn"><i class="bi bi-chevron-right"></i></button>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div style="padding:12px 16px 0;display:none;" id="fullviewBar">
                                                        <div class="fullview-info">
                                                            <span class="fv-label"><i class="bi bi-list-ul"></i> FullView — Showing all <strong style="color:#f2f5ff;" id="fvTotalCount">0</strong> users</span>
                                                            <span class="fv-hint">Showing everything in a single scrollable list</span>
                                                        </div>
                                                    </div>

                                                    <div id="tableContainer">
                                                        <table>
                                                            <thead>
                                                                <tr>
                                                                    <th><i class="bi bi-hash"></i> ID</th>
                                                                    <th>Username</th>
                                                                    <th>Full Name</th>
                                                                    <th>Email</th>
                                                                    <th>Role</th>
                                                                    <th>Status</th>
                                                                    <th class="text-center">Actions</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody id="usersTableBody">
                                                                <c:choose>
                                                                    <c:when test="${not empty userList}">
                                                                        <c:forEach var="user" items="${userList}">
                                                                            <tr data-id="${user.userId}" data-username="${user.userName}" data-fullname="${user.fullName}" data-email="${user.email}" data-role="${roleMap[user.userId]}" data-status="${user.active}" data-statustext="${user.status}">
                                                                                <td><span class="id-badge">#${user.userId}</span></td>
                                                                                <td class="username-cell"><c:out value="${user.userName}" /></td>
                                                                                <td><c:out value="${user.fullName}" /></td>
                                                                                <td style="color:var(--text-muted)"><c:out value="${user.email}" /></td>
                                                                                <td>
                                                                                    <c:choose>
                                                                                        <c:when test="${roleMap[user.userId] eq 'Admin'}"><span class="role-badge role-admin">ADMIN</span></c:when>
                                                                                        <c:when test="${roleMap[user.userId] eq 'Technician'}"><span class="role-badge role-tech">TECH</span></c:when>
                                                                                        <c:otherwise><span class="role-badge role-viewer">VIEWER</span></c:otherwise>
                                                                                    </c:choose>
                                                                                </td>
                                                                                <td>
                                                                                    <span class="status-badge ${user.active ? 'status-active' : 'status-inactive'}">
                                                                                        <span class="status-dot ${user.active ? 'status-dot-green' : 'status-dot-red'}"></span>
                                                                                        ${user.active ? 'ACTIVE' : 'INACTIVE'}
                                                                                    </span>
                                                                                </td>
                                                                                <td>
                                                                                    <div class="action-group">
                                                                                        <span class="btn-icon btn-icon-view" onclick="openDetail(this)" title="View"><i class="bi bi-eye"></i></span>
                                                                                        <c:if test="${roleMap[user.userId] ne 'Admin'}">
                                                                                            <span class="btn-icon btn-icon-edit" data-bs-toggle="modal" data-bs-target="#editUserModal"
                                                                                                data-id="${user.userId}" data-username="${user.userName}" data-fullname="${user.fullName}"
                                                                                                data-email="${user.email}" data-password="${user.password}" data-status="${user.active}" data-role="${roleMap[user.userId]}" title="Edit"><i class="bi bi-pencil"></i></span>
                                                                                            <form action="UserController" method="POST" style="display:inline;margin:0;" onsubmit="return confirm('Are you sure you want to delete this user?');">
                                                                                                <input type="hidden" name="action" value="delete">
                                                                                                <input type="hidden" name="userId" value="${user.userId}">
                                                                                                <button type="submit" class="btn-icon btn-icon-delete" title="Delete"><i class="bi bi-trash3"></i></button>
                                                                                            </form>
                                                                                        </c:if>
                                                                                    </div>
                                                                                </td>
                                                                            </tr>
                                                                        </c:forEach>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <tr><td colspan="7"><div class="empty-state"><i class="bi bi-people"></i><p>No users found. Use the Add User button above to create one.</p></div></td></tr>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </tbody>
                                                        </table>
                                                    </div>
                                                </div>

                                            </div>
                                            <% } %>
                                        </div>
                                    </div>

    <!-- Detail Modal (FullView overlay) -->
    <div class="detail-overlay" id="detailOverlay" onclick="if(event.target===this)closeDetail()">
        <div class="detail-panel">
            <button class="detail-close" onclick="closeDetail()"><i class="bi bi-x"></i></button>
            <div style="display:flex;align-items:center;gap:16px;margin-bottom:24px;">
                <div class="detail-avatar" id="detailAvatar" style="background:linear-gradient(135deg,#8b5cf6,#60a5fa);">U</div>
                <div>
                    <div style="font-size:18px;font-weight:700;color:#f2f5ff;" id="detailName">-</div>
                    <div style="font-size:13px;color:#9aa6c7;" id="detailUsername">@-</div>
                </div>
            </div>
            <div class="detail-grid">
                <div>
                    <div class="detail-section-label">Email</div>
                    <div class="detail-value" id="detailEmail">-</div>
                </div>
                <div>
                    <div class="detail-section-label">Role</div>
                    <div class="detail-value" id="detailRole">-</div>
                </div>
                <div>
                    <div class="detail-section-label">Status</div>
                    <div class="detail-value" id="detailStatus">-</div>
                </div>
                <div>
                    <div class="detail-section-label">User ID</div>
                    <div class="detail-value" id="detailId" style="font-family:monospace;color:#60a5fa;">-</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Add User Modal -->
    <div class="modal fade" id="addUserModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content" style="background:linear-gradient(180deg,rgba(16,23,42,0.98),rgba(10,14,28,0.99));border:1px solid var(--border);border-radius:var(--radius-lg);color:var(--text-primary);">
                <form action="UserController" method="POST">
                    <input type="hidden" name="action" value="add">
                    <div style="padding:15px 20px;border-bottom:1px solid var(--border);display:flex;align-items:center;justify-content:space-between;">
                        <h5 style="margin:0;font-weight:700;"><i class="bi bi-person-plus me-2" style="color:var(--neon-purple);"></i>Add New User</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div style="padding:20px;">
                        <div class="mb-3">
                            <label style="color:var(--text-muted);font-size:12px;margin-bottom:4px;display:block;">Username</label>
                            <input type="text" name="username" style="width:100%;background:#0f162b;border:1px solid var(--border);color:var(--text-primary);border-radius:7px;padding:7px 11px;font-size:13px;outline:none;" required>
                        </div>
                        <div class="mb-3">
                            <label style="color:var(--text-muted);font-size:12px;margin-bottom:4px;display:block;">Password</label>
                            <input type="password" name="password" style="width:100%;background:#0f162b;border:1px solid var(--border);color:var(--text-primary);border-radius:7px;padding:7px 11px;font-size:13px;outline:none;" required>
                        </div>
                        <div class="mb-3">
                            <label style="color:var(--text-muted);font-size:12px;margin-bottom:4px;display:block;">Full Name</label>
                            <input type="text" name="fullName" style="width:100%;background:#0f162b;border:1px solid var(--border);color:var(--text-primary);border-radius:7px;padding:7px 11px;font-size:13px;outline:none;" required>
                        </div>
                        <div class="mb-3">
                            <label style="color:var(--text-muted);font-size:12px;margin-bottom:4px;display:block;">Email</label>
                            <input type="email" name="email" style="width:100%;background:#0f162b;border:1px solid var(--border);color:var(--text-primary);border-radius:7px;padding:7px 11px;font-size:13px;outline:none;" required>
                        </div>
                        <div class="mb-3">
                            <label style="color:var(--text-muted);font-size:12px;margin-bottom:4px;display:block;">Role</label>
                            <select name="roleId" style="width:100%;background:#0f162b;border:1px solid var(--border);color:var(--text-primary);border-radius:7px;padding:7px 11px;font-size:13px;outline:none;" required>
                                <option value="">-- Select Role --</option>
                                <c:forEach var="role" items="${roleList}">
                                    <option value="${role.roleId}">${role.roleName}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                    <div style="padding:12px 20px;border-top:1px solid var(--border);display:flex;justify-content:flex-end;gap:8px;">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal" style="background:rgba(42,53,85,0.5);border:1px solid var(--border);color:var(--text-muted);border-radius:7px;padding:6px 14px;font-size:12px;">Cancel</button>
                        <button type="submit" style="background:linear-gradient(135deg,var(--neon-purple),#6d28d9);border:none;color:#fff;border-radius:7px;padding:6px 14px;font-size:12px;font-weight:600;cursor:pointer;"><i class="bi bi-check2 me-1"></i>Save User</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Edit User Modal -->
    <div class="modal fade" id="editUserModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content" style="background:linear-gradient(180deg,rgba(16,23,42,0.98),rgba(10,14,28,0.99));border:1px solid var(--border);border-radius:var(--radius-lg);color:var(--text-primary);">
                <form action="UserController" method="POST">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="userId" id="edit-id">
                    <div style="padding:15px 20px;border-bottom:1px solid var(--border);display:flex;align-items:center;justify-content:space-between;">
                        <h5 style="margin:0;font-weight:700;"><i class="bi bi-pencil-square me-2" style="color:var(--neon-blue);"></i>Edit User</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div style="padding:20px;">
                        <div class="mb-3">
                            <label style="color:var(--text-muted);font-size:12px;margin-bottom:4px;display:block;">Username</label>
                            <input type="text" name="username" id="edit-username" style="width:100%;background:#0f162b;border:1px solid var(--border);color:var(--text-primary);border-radius:7px;padding:7px 11px;font-size:13px;outline:none;" required>
                        </div>
                        <div class="mb-3">
                            <label style="color:var(--text-muted);font-size:12px;margin-bottom:4px;display:block;">Password</label>
                            <input type="text" name="password" id="edit-password" style="width:100%;background:#0f162b;border:1px solid var(--border);color:var(--text-primary);border-radius:7px;padding:7px 11px;font-size:13px;outline:none;" required>
                        </div>
                        <div class="mb-3">
                            <label style="color:var(--text-muted);font-size:12px;margin-bottom:4px;display:block;">Full Name</label>
                            <input type="text" name="fullName" id="edit-fullname" style="width:100%;background:#0f162b;border:1px solid var(--border);color:var(--text-primary);border-radius:7px;padding:7px 11px;font-size:13px;outline:none;" required>
                        </div>
                        <div class="mb-3">
                            <label style="color:var(--text-muted);font-size:12px;margin-bottom:4px;display:block;">Email</label>
                            <input type="email" name="email" id="edit-email" style="width:100%;background:#0f162b;border:1px solid var(--border);color:var(--text-primary);border-radius:7px;padding:7px 11px;font-size:13px;outline:none;" required>
                        </div>
                        <div class="mb-3">
                            <label style="color:var(--text-muted);font-size:12px;margin-bottom:4px;display:block;">Role</label>
                            <select name="roleId" id="edit-role" style="width:100%;background:#0f162b;border:1px solid var(--border);color:var(--text-primary);border-radius:7px;padding:7px 11px;font-size:13px;outline:none;">
                                <option value="">-- Select Role --</option>
                                <c:forEach var="role" items="${roleList}">
                                    <option value="${role.roleId}">${role.roleName}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div style="margin-top:12px;">
                            <label style="display:inline-flex;align-items:center;gap:7px;cursor:pointer;">
                                <input type="checkbox" name="status" id="edit-status" value="true" style="accent-color:var(--neon-purple);">
                                <span style="font-size:13px;color:var(--text-primary);">Active Status</span>
                            </label>
                        </div>
                    </div>
                    <div style="padding:12px 20px;border-top:1px solid var(--border);display:flex;justify-content:flex-end;gap:8px;">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal" style="background:rgba(42,53,85,0.5);border:1px solid var(--border);color:var(--text-muted);border-radius:7px;padding:6px 14px;font-size:12px;">Cancel</button>
                        <button type="submit" style="background:rgba(245,158,11,0.2);border:1px solid rgba(245,158,11,0.5);color:#fde68a;border-radius:7px;padding:6px 14px;font-size:12px;font-weight:600;cursor:pointer;"><i class="bi bi-check2 me-1"></i>Update User</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

                    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
                    <script>
                        const pageTitles = {
                            'dashboard': ['Dashboard', '/ Overview'],
                            'devices': ['Network Devices', '/ Infrastructure'],
                            'accesspoints': ['Access Points', '/ Infrastructure'],
                            'routers': ['Routers', '/ Infrastructure'],
                            'switches': ['Switches', '/ Infrastructure'],
                            'vlan': ['VLAN', '/ Infrastructure'],
                            'ipmanage': ['IP Management', '/ Infrastructure'],
                            'bandwidth': ['Bandwidth Usage', '/ Monitoring'],
                            'wifianalytics': ['WiFi Analytics', '/ Monitoring'],
                            'alerts': ['Network Alerts', '/ Monitoring'],
                            'tickets': ['Support Tickets', '/ Management'],
                            'maintenance': ['Maintenance Schedule', '/ Management'],
                            'rooms': ['Rooms', '/ Management'],
                            'users': ['User Management', '/ Administration'],
                            'authlogs': ['Auth Logs', '/ Administration'],
                            'systemlogs': ['System Logs', '/ Administration']
                        };

                        function showPage(pageId, triggerEl) {
                            window.location.href = 'staffDashboard.jsp';
                        }

                        // ── Pagination + FullView ──
                        const PAGE_SIZE = 10;
                        let isFullView = false;
                        let allRows = [];
                        let currentPage = 1;
                        let totalPages = 1;

                        function initTable() {
                            const tbody = document.getElementById('usersTableBody');
                            if (!tbody) return;
                            const rows = Array.from(tbody.querySelectorAll('tr'));
                            allRows = rows.filter(function(r) { return r.style.display !== 'none' || !r.style.display; });
                            totalPages = Math.max(1, Math.ceil(allRows.length / PAGE_SIZE));
                            currentPage = 1;
                            renderView();
                            computeStats();
                        }

                        function renderView() {
                            if (isFullView) {
                                document.body.classList.add('fullview-mode');
                                document.getElementById('paginationBar').style.display = 'none';
                                document.getElementById('fullviewBar').style.display = 'block';
                                document.getElementById('fullviewToggle').className = 'btn-dash btn-dash-cyan active';
                                document.getElementById('fullviewLabel').textContent = 'Back';
                                document.getElementById('tableContainer').className = 'table-wrap';
                                document.getElementById('fvTotalCount').textContent = allRows.length;
                                document.getElementById('fvPageTotal').textContent = allRows.length;
                                allRows.forEach(function(r) { r.style.display = ''; });
                            } else {
                                document.body.classList.remove('fullview-mode');
                                document.getElementById('paginationBar').style.display = 'block';
                                document.getElementById('fullviewBar').style.display = 'none';
                                document.getElementById('fullviewToggle').className = 'btn-dash btn-dash-cyan';
                                document.getElementById('fullviewLabel').textContent = 'FullView';
                                document.getElementById('tableContainer').className = '';
                                showPageForTable();
                            }
                        }

                        function showPageForTable() {
                            const start = (currentPage - 1) * PAGE_SIZE;
                            const end = start + PAGE_SIZE;
                            allRows.forEach(function(r, i) {
                                r.style.display = (i >= start && i < end) ? '' : 'none';
                            });
                            document.getElementById('pageLabel').textContent = 'Page ' + currentPage + ' of ' + totalPages;
                            document.getElementById('prevBtn').disabled = currentPage <= 1;
                            document.getElementById('nextBtn').disabled = currentPage >= totalPages;
                            document.getElementById('tableInfo').innerHTML = 'Showing <strong style="color:#f2f5ff;">' + (Math.min(end, allRows.length) - start) + '</strong> of ' + allRows.length + ' users';
                        }

                        function prevPage() {
                            if (currentPage > 1) { currentPage--; showPageForTable(); }
                        }

                        function nextPage() {
                            if (currentPage < totalPages) { currentPage++; showPageForTable(); }
                        }

                        function toggleFullView() {
                            isFullView = !isFullView;
                            renderView();
                        }

                        function computeStats() {
                            var total = allRows.length;
                            var active = 0, inactive = 0, admin = 0, tech = 0, viewer = 0;
                            allRows.forEach(function(r) {
                                var status = r.getAttribute('data-status');
                                var role = r.getAttribute('data-role');
                                if (status === 'true') active++; else inactive++;
                                if (role === 'Admin') admin++;
                                else if (role === 'Technician') tech++;
                                else viewer++;
                            });
                            document.getElementById('statsBar').innerHTML =
                                '<div class="stat-chip"><i class="bi bi-people" style="color:#60a5fa"></i> Total: <strong>' + total + '</strong></div>' +
                                '<div class="stat-chip"><span class="status-dot status-dot-green" style="width:7px;height:7px;"></span> Active: <strong>' + active + '</strong></div>' +
                                '<div class="stat-chip"><span class="status-dot status-dot-red" style="width:7px;height:7px;"></span> Inactive: <strong>' + inactive + '</strong></div>' +
                                '<div class="stat-chip"><span style="color:#f87171;font-size:13px;">&#x1F451;</span> Admin: <strong>' + admin + '</strong></div>' +
                                '<div class="stat-chip"><span style="color:#8b5cf6;font-size:13px;">&#x1F527;</span> Tech: <strong>' + tech + '</strong></div>' +
                                '<div class="stat-chip"><span style="color:#60a5fa;font-size:13px;">&#x1F441;</span> Viewer: <strong>' + viewer + '</strong></div>';
                        }

                        // ── Detail Modal ──
                        function openDetail(btn) {
                            var row = btn.closest('tr');
                            document.getElementById('detailId').textContent = '#' + row.getAttribute('data-id');
                            document.getElementById('detailName').textContent = row.getAttribute('data-fullname');
                            document.getElementById('detailUsername').textContent = '@' + row.getAttribute('data-username');
                            document.getElementById('detailEmail').textContent = row.getAttribute('data-email');
                            var role = row.getAttribute('data-role');
                            var roleBadge = role;
                            if (role === 'Admin') roleBadge = '<span class="role-badge role-admin">ADMIN</span>';
                            else if (role === 'Technician') roleBadge = '<span class="role-badge role-tech">TECH</span>';
                            else roleBadge = '<span class="role-badge role-viewer">VIEWER</span>';
                            document.getElementById('detailRole').innerHTML = roleBadge;
                            var isActive = row.getAttribute('data-status') === 'true';
                            document.getElementById('detailStatus').innerHTML =
                                '<span class="status-badge ' + (isActive ? 'status-active' : 'status-inactive') + '">' +
                                '<span class="status-dot ' + (isActive ? 'status-dot-green' : 'status-dot-red') + '"></span> ' +
                                (isActive ? 'ACTIVE' : 'INACTIVE') + '</span>';
                            var avatar = document.getElementById('detailAvatar');
                            var name = row.getAttribute('data-fullname') || row.getAttribute('data-username') || 'U';
                            var initials = name.split(' ').map(function(s) { return s.charAt(0); }).join('').substring(0,2).toUpperCase();
                            avatar.textContent = initials;
                            document.getElementById('detailOverlay').classList.add('show');
                        }

                        function closeDetail() {
                            document.getElementById('detailOverlay').classList.remove('show');
                        }

                        document.addEventListener('keydown', function(e) {
                            if (e.key === 'Escape') closeDetail();
                        });

                        // ── Init ──
                        document.addEventListener('DOMContentLoaded', function() {
                            initTable();
                            var editUserModal = document.getElementById('editUserModal');
                            if (editUserModal) {
                                editUserModal.addEventListener('show.bs.modal', function (event) {
                                    var button = event.relatedTarget;
                                    var id = button.getAttribute('data-id');
                                    var username = button.getAttribute('data-username');
                                    var fullname = button.getAttribute('data-fullname');
                                    var email = button.getAttribute('data-email');
                                    var password = button.getAttribute('data-password');
                                    var status = button.getAttribute('data-status');
                                    var role = button.getAttribute('data-role');
                                    
                                    var modal = this;
                                    modal.querySelector('#edit-id').value = id;
                                    modal.querySelector('#edit-username').value = username;
                                    modal.querySelector('#edit-fullname').value = fullname;
                                    modal.querySelector('#edit-email').value = email;
                                    modal.querySelector('#edit-password').value = password;
                                    modal.querySelector('#edit-status').checked = (status === 'true');
                                    
                                    var roleSelect = modal.querySelector('#edit-role');
                                    if (role) {
                                        for (var i = 0; i < roleSelect.options.length; i++) {
                                            if (roleSelect.options[i].text === role) {
                                                roleSelect.selectedIndex = i;
                                                break;
                                            }
                                        }
                                    }
                                });
                            }
                        });
                    </script>
                </body>

                </html>