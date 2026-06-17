<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Routers — Network Manager</title>
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
        }

        /* ── Header ── */
        .page-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 28px;
            gap: 16px;
            flex-wrap: wrap;
        }

        .page-title-group {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .page-icon {
            width: 48px; height: 48px;
            background: linear-gradient(135deg, var(--neon-purple), var(--neon-blue));
            border-radius: var(--radius-md);
            display: flex; align-items: center; justify-content: center;
            font-size: 22px;
            box-shadow: var(--glow-purple);
            flex-shrink: 0;
        }

        .page-title {
            font-size: 1.7rem;
            font-weight: 700;
            letter-spacing: -0.5px;
            background: linear-gradient(90deg, #f2f5ff 0%, var(--neon-cyan) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin: 0;
        }

        .page-subtitle {
            color: var(--text-muted);
            font-size: 0.82rem;
            margin: 2px 0 0;
        }

        .header-actions {
            display: flex;
            gap: 10px;
            align-items: center;
        }

        /* ── Buttons ── */
        .btn-dash {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            padding: 9px 18px;
            border-radius: var(--radius-md);
            font-size: 0.875rem;
            font-weight: 600;
            border: none;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.2s;
            white-space: nowrap;
        }

        .btn-dash-ghost {
            background: rgba(42, 53, 85, 0.55);
            color: var(--text-muted);
            border: 1px solid var(--border);
        }
        .btn-dash-ghost:hover {
            background: rgba(42, 53, 85, 0.85);
            color: var(--text-primary);
            border-color: var(--neon-blue);
            box-shadow: 0 0 12px rgba(96,165,250,0.18);
        }

        .btn-dash-primary {
            background: linear-gradient(135deg, var(--neon-purple) 0%, #6d28d9 100%);
            color: #fff;
            box-shadow: 0 4px 14px rgba(139,92,246,0.35);
        }
        .btn-dash-primary:hover {
            background: linear-gradient(135deg, #a78bfa 0%, var(--neon-purple) 100%);
            transform: translateY(-1px);
            box-shadow: 0 6px 20px rgba(139,92,246,0.5);
            color: #fff;
        }

        /* ── Stats bar ── */
        .stats-bar {
            display: flex;
            gap: 12px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }

        .stat-chip {
            display: flex;
            align-items: center;
            gap: 8px;
            background: rgba(16, 23, 42, 0.8);
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 8px 16px;
            font-size: 0.8rem;
            color: var(--text-muted);
        }

        .stat-chip .dot {
            width: 8px; height: 8px;
            border-radius: 50%;
        }

        .stat-chip strong {
            color: var(--text-primary);
            font-size: 1rem;
        }

        /* ── Table card ── */
        .table-card {
            background: rgba(16, 23, 42, 0.82);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            overflow: hidden;
            box-shadow: 0 8px 40px rgba(0,0,0,0.45), var(--glow-purple);
            backdrop-filter: blur(12px);
        }

        .table-card table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.875rem;
        }

        .table-card thead tr {
            background: rgba(22, 31, 54, 0.95);
            border-bottom: 1px solid var(--border);
        }

        .table-card thead th {
            padding: 14px 16px;
            color: var(--text-muted);
            font-weight: 600;
            font-size: 0.75rem;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            white-space: nowrap;
        }

        .table-card tbody tr {
            border-bottom: 1px solid rgba(42, 53, 85, 0.4);
            transition: background 0.18s;
        }

        .table-card tbody tr:last-child { border-bottom: none; }

        .table-card tbody tr:hover {
            background: rgba(139, 92, 246, 0.06);
        }

        .table-card tbody td {
            padding: 13px 16px;
            color: var(--text-primary);
            vertical-align: middle;
        }

        /* ── ID badge ── */
        .id-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: rgba(96, 165, 250, 0.12);
            border: 1px solid rgba(96, 165, 250, 0.25);
            color: var(--neon-blue);
            border-radius: 6px;
            padding: 2px 10px;
            font-size: 0.78rem;
            font-weight: 700;
            font-family: monospace;
            min-width: 36px;
        }

        /* ── Router name ── */
        .router-name {
            display: flex;
            align-items: center;
            gap: 9px;
        }
        .router-name .ri {
            width: 30px; height: 30px;
            background: linear-gradient(135deg, rgba(139,92,246,0.2), rgba(96,165,250,0.2));
            border: 1px solid rgba(139,92,246,0.3);
            border-radius: 7px;
            display: flex; align-items: center; justify-content: center;
            font-size: 14px;
            color: var(--neon-purple);
            flex-shrink: 0;
        }
        .router-name span {
            font-weight: 600;
            color: var(--text-primary);
        }

        /* ── Monospace fields ── */
        .mono {
            font-family: 'Courier New', monospace;
            font-size: 0.8rem;
            color: var(--neon-cyan);
            background: rgba(34,211,238,0.07);
            border-radius: 5px;
            padding: 2px 7px;
            display: inline-block;
        }

        .mono-mac {
            color: var(--text-muted);
            background: rgba(154,166,199,0.08);
        }

        /* ── Status badge ── */
        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 4px 11px;
            border-radius: 20px;
            font-size: 0.72rem;
            font-weight: 700;
            letter-spacing: 0.05em;
            text-transform: uppercase;
            white-space: nowrap;
        }
        .status-badge::before {
            content: '';
            width: 6px; height: 6px;
            border-radius: 50%;
            display: inline-block;
        }
        .status-online {
            background: rgba(52, 211, 153, 0.12);
            border: 1px solid rgba(52, 211, 153, 0.3);
            color: var(--neon-green);
        }
        .status-online::before { background: var(--neon-green); box-shadow: 0 0 6px var(--neon-green); }

        .status-offline {
            background: rgba(248, 113, 113, 0.12);
            border: 1px solid rgba(248, 113, 113, 0.3);
            color: var(--neon-red);
        }
        .status-offline::before { background: var(--neon-red); }

        .status-maintenance {
            background: rgba(251, 191, 36, 0.12);
            border: 1px solid rgba(251, 191, 36, 0.3);
            color: var(--neon-yellow);
        }
        .status-maintenance::before { background: var(--neon-yellow); box-shadow: 0 0 6px var(--neon-yellow); animation: blink 1.4s infinite; }

        @keyframes blink { 0%,100% { opacity:1; } 50% { opacity:0.3; } }

        /* ── Status inline form ── */
        .status-form {
            display: flex;
            gap: 6px;
            align-items: center;
        }

        .status-select {
            background: rgba(22, 31, 54, 0.9);
            border: 1px solid var(--border);
            color: var(--text-primary);
            border-radius: 7px;
            padding: 5px 10px;
            font-size: 0.78rem;
            outline: none;
            cursor: pointer;
            transition: border-color 0.2s;
        }
        .status-select:focus { border-color: var(--neon-purple); }
        .status-select option { background: #0b1020; }

        .btn-update {
            background: rgba(52, 211, 153, 0.12);
            border: 1px solid rgba(52, 211, 153, 0.3);
            color: var(--neon-green);
            border-radius: 7px;
            padding: 5px 10px;
            font-size: 0.75rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            white-space: nowrap;
        }
        .btn-update:hover {
            background: rgba(52, 211, 153, 0.22);
            box-shadow: 0 0 10px rgba(52,211,153,0.25);
        }

        /* ── Action buttons ── */
        .action-group {
            display: flex;
            gap: 5px;
            align-items: center;
        }

        .btn-icon {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 32px; height: 32px;
            border-radius: 7px;
            border: 1px solid transparent;
            font-size: 14px;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.2s;
            background: transparent;
        }

        .btn-icon-edit {
            border-color: rgba(96,165,250,0.3);
            color: var(--neon-blue);
            background: rgba(96,165,250,0.08);
        }
        .btn-icon-edit:hover {
            background: rgba(96,165,250,0.2);
            box-shadow: 0 0 10px rgba(96,165,250,0.3);
            color: var(--neon-blue);
        }

        .btn-icon-restart {
            border-color: rgba(251,191,36,0.3);
            color: var(--neon-yellow);
            background: rgba(251,191,36,0.08);
        }
        .btn-icon-restart:hover {
            background: rgba(251,191,36,0.2);
            box-shadow: 0 0 10px rgba(251,191,36,0.3);
            color: var(--neon-yellow);
        }

        .btn-icon-delete {
            border-color: rgba(248,113,113,0.3);
            color: var(--neon-red);
            background: rgba(248,113,113,0.08);
        }
        .btn-icon-delete:hover {
            background: rgba(248,113,113,0.2);
            box-shadow: 0 0 10px rgba(248,113,113,0.3);
            color: var(--neon-red);
        }

        /* ── Empty state ── */
        .empty-state {
            padding: 64px 24px;
            text-align: center;
        }
        .empty-state i {
            font-size: 48px;
            color: var(--border);
            display: block;
            margin-bottom: 14px;
        }
        .empty-state p {
            color: var(--text-muted);
            margin: 0;
            font-size: 0.9rem;
        }

        /* ── Tooltip ── */
        [title] { cursor: pointer; }

        /* ── Fade in animation ── */
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .page-wrapper { animation: fadeInUp 0.35s ease both; }
    </style>
</head>
<body>
<div class="page-wrapper">

    <!-- Header -->
    <div class="page-header">
        <div class="page-title-group">
            <div class="page-icon"><i class="bi bi-router"></i></div>
            <div>
                <h1 class="page-title">Routers</h1>
                <p class="page-subtitle">Manage and monitor all network routers</p>
            </div>
        </div>
        <div class="header-actions">
            <a class="btn-dash btn-dash-ghost" href="staffDashboard.jsp">
                <i class="bi bi-arrow-left"></i> Dashboard
            </a>
            <a class="btn-dash btn-dash-primary" href="MainController?action=routerAdd">
                <i class="bi bi-plus-lg"></i> Add Router
            </a>
        </div>
    </div>

    <!-- Stats bar -->
    <c:if test="${not empty routers}">
        <div class="stats-bar">
            <div class="stat-chip">
                <i class="bi bi-hdd-network" style="color:var(--neon-blue)"></i>
                Total: <strong>${fn:length(routers)}</strong> routers
            </div>
            <div class="stat-chip">
                <span class="dot" style="background:var(--neon-green);box-shadow:0 0 5px var(--neon-green)"></span>
                Online devices
            </div>
            <div class="stat-chip">
                <span class="dot" style="background:var(--neon-yellow);box-shadow:0 0 5px var(--neon-yellow)"></span>
                Maintenance
            </div>
            <div class="stat-chip">
                <span class="dot" style="background:var(--neon-red)"></span>
                Offline
            </div>
        </div>
    </c:if>

    <!-- Table card -->
    <div class="table-card">
        <div style="overflow-x:auto">
            <table>
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
                    <c:choose>
                        <c:when test="${not empty routers}">
                            <c:forEach var="router" items="${routers}">
                                <tr>
                                    <td><span class="id-badge">#${router.routerId}</span></td>
                                    <td>
                                        <div class="router-name">
                                            <div class="ri"><i class="bi bi-router-fill"></i></div>
                                            <span><c:out value="${router.routerName}" /></span>
                                        </div>
                                    </td>
                                    <td><span class="mono"><c:out value="${router.ipAddress}" /></span></td>
                                    <td><span class="mono mono-mac"><c:out value="${router.macAddress}" /></span></td>
                                    <td style="color:var(--text-muted)"><c:out value="${router.model}" /></td>
                                    <td style="color:var(--text-muted);font-size:0.8rem"><c:out value="${router.firmware}" /></td>
                                    <td>
                                        <form action="MainController" method="post" class="status-form">
                                            <input type="hidden" name="action" value="routerUpdateStatus">
                                            <input type="hidden" name="id" value="${router.routerId}">
                                            <select class="status-select" name="status">
                                                <option value="ONLINE"       ${router.status eq 'ONLINE'       ? 'selected' : ''}>🟢 ONLINE</option>
                                                <option value="OFFLINE"      ${router.status eq 'OFFLINE'      ? 'selected' : ''}>🔴 OFFLINE</option>
                                                <option value="MAINTENANCE"  ${router.status eq 'MAINTENANCE'  ? 'selected' : ''}>🟡 MAINTENANCE</option>
                                            </select>
                                            <button class="btn-update" type="submit" title="Update status">
                                                <i class="bi bi-check2"></i>
                                            </button>
                                        </form>
                                    </td>
                                    <td style="color:var(--text-muted);font-size:0.82rem">
                                        <i class="bi bi-geo-alt-fill" style="color:var(--neon-pink);margin-right:4px"></i>
                                        <c:out value="${router.location}" />
                                    </td>
                                    <td>
                                        <span class="id-badge" style="color:var(--neon-purple);border-color:rgba(139,92,246,0.3);background:rgba(139,92,246,0.08)">
                                            ${router.roomId}
                                        </span>
                                    </td>
                                    <td>
                                        <div class="action-group">
                                            <a class="btn-icon btn-icon-edit"
                                               href="MainController?action=routerEdit&id=${router.routerId}"
                                               title="Edit router">
                                                <i class="bi bi-pencil-fill"></i>
                                            </a>
                                            <a class="btn-icon btn-icon-restart"
                                               href="MainController?action=routerRestart&id=${router.routerId}"
                                               title="Restart router">
                                                <i class="bi bi-arrow-clockwise"></i>
                                            </a>
                                            <a class="btn-icon btn-icon-delete"
                                               href="MainController?action=routerDelete&routerId=${router.routerId}"
                                               title="Delete router"
                                               onclick="return confirm('Delete router \'${router.routerName}\'?')">
                                                <i class="bi bi-trash3-fill"></i>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="10">
                                    <div class="empty-state">
                                        <i class="bi bi-router"></i>
                                        <p>No routers found. Add your first router to get started.</p>
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
