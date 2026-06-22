<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="router"     value="${requestScope.router}" />
<c:set var="formRouter" value="${requestScope.formRouter}" />
<c:set var="returnTo"   value="${requestScope.returnTo}" />
<c:set var="editMode"   value="${not empty router}" />
<c:choose>
    <c:when test="${editMode}">
        <c:set var="valueRouter" value="${router}" />
    </c:when>
    <c:otherwise>
        <c:set var="valueRouter" value="${formRouter}" />
    </c:otherwise>
</c:choose>
<c:set var="statusValue" value="${valueRouter.status}" />
<c:if test="${empty statusValue}">
    <c:set var="statusValue" value="ONLINE" />
</c:if>
<c:set var="roomIdValue" value="${valueRouter.roomId}" />
<c:if test="${empty roomIdValue}">
    <c:set var="roomIdValue" value="0" />
</c:if>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>
        <c:choose>
            <c:when test="${editMode}">Edit Router</c:when>
            <c:otherwise>Add Router</c:otherwise>
        </c:choose>
        — Network Manager
    </title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root {
            --bg-0: #05070d;
            --surface: #10172a;
            --surface-2: #161f36;
            --border: #2a3555;
            --text-primary: #f2f5ff;
            --text-muted: #9aa6c7;
            --neon-purple: #8b5cf6;
            --neon-blue: #60a5fa;
            --neon-cyan: #22d3ee;
            --neon-green: #34d399;
            --neon-red: #f87171;
            --neon-yellow: #fbbf24;
            --radius-md: 10px;
            --radius-lg: 14px;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            background:
                linear-gradient(rgba(5, 8, 18, 0.90), rgba(6, 9, 20, 0.86)),
                radial-gradient(circle at 10% 20%, rgba(139, 92, 246, 0.18), transparent 30%),
                radial-gradient(circle at 88% 78%, rgba(34, 211, 238, 0.10), transparent 28%),
                url('theme/original-d5209459af4999984ad44693bbcb28f7.webp') center/cover fixed no-repeat;
            color: var(--text-primary);
            min-height: 100vh;
            font-family: "Segoe UI", Arial, sans-serif;
            display: flex;
            align-items: flex-start;
            justify-content: center;
            padding: 40px 16px 60px;
        }

        /* ── Page wrapper ── */
        .form-page {
            width: 100%;
            max-width: 780px;
            animation: fadeUp 0.35s ease both;
        }

        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(20px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* ── Back link ── */
        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            color: var(--text-muted);
            font-size: 0.83rem;
            text-decoration: none;
            margin-bottom: 24px;
            transition: color 0.2s;
        }
        .back-link:hover { color: var(--neon-blue); }

        /* ── Header ── */
        .form-header {
            display: flex;
            align-items: center;
            gap: 16px;
            margin-bottom: 28px;
        }

        .form-icon {
            width: 52px; height: 52px;
            border-radius: var(--radius-md);
            display: flex; align-items: center; justify-content: center;
            font-size: 24px;
            flex-shrink: 0;
        }
        .form-icon-add {
            background: linear-gradient(135deg, var(--neon-purple), #6d28d9);
            box-shadow: 0 0 24px rgba(139,92,246,0.4);
            color: #fff;
        }
        .form-icon-edit {
            background: linear-gradient(135deg, var(--neon-blue), #2563eb);
            box-shadow: 0 0 24px rgba(96,165,250,0.4);
            color: #fff;
        }

        .form-title {
            font-size: 1.6rem;
            font-weight: 700;
            letter-spacing: -0.4px;
            background: linear-gradient(90deg, #f2f5ff, var(--neon-cyan));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .form-subtitle {
            color: var(--text-muted);
            font-size: 0.82rem;
            margin-top: 3px;
        }

        /* ── Alert ── */
        .alert-error {
            background: rgba(248, 113, 113, 0.10);
            border: 1px solid rgba(248, 113, 113, 0.35);
            color: var(--neon-red);
            border-radius: var(--radius-md);
            padding: 13px 16px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 0.875rem;
        }

        /* ── Card ── */
        .form-card {
            background: rgba(16, 23, 42, 0.85);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 32px;
            box-shadow: 0 12px 48px rgba(0,0,0,0.5), 0 0 20px rgba(139,92,246,0.10);
            backdrop-filter: blur(14px);
        }

        /* ── Section divider ── */
        .form-section {
            margin-bottom: 28px;
        }

        .section-label {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.72rem;
            font-weight: 700;
            letter-spacing: 0.1em;
            text-transform: uppercase;
            color: var(--neon-purple);
            margin-bottom: 16px;
            padding-bottom: 10px;
            border-bottom: 1px solid rgba(139, 92, 246, 0.2);
        }

        /* ── Field ── */
        .field-grid {
            display: grid;
            gap: 18px;
        }

        .field-grid-2 { grid-template-columns: 1fr 1fr; }
        .field-grid-3 { grid-template-columns: 2fr 1fr; }

        @media (max-width: 600px) {
            .field-grid-2, .field-grid-3 { grid-template-columns: 1fr; }
            .form-card { padding: 20px; }
        }

        .field-group { display: flex; flex-direction: column; gap: 7px; }

        .field-label {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 0.78rem;
            font-weight: 600;
            color: var(--text-muted);
            letter-spacing: 0.03em;
        }

        .field-label i { color: var(--neon-purple); font-size: 13px; }

        .req { color: var(--neon-red); margin-left: 1px; }

        .field-input {
            background: rgba(22, 31, 54, 0.85);
            border: 1px solid var(--border);
            border-radius: var(--radius-md);
            padding: 11px 14px;
            color: var(--text-primary);
            font-size: 0.875rem;
            font-family: inherit;
            outline: none;
            transition: border-color 0.2s, box-shadow 0.2s;
            width: 100%;
        }

        .field-input::placeholder { color: rgba(154,166,199,0.45); }

        .field-input:focus {
            border-color: var(--neon-purple);
            box-shadow: 0 0 0 3px rgba(139,92,246,0.12);
        }

        .field-input-mono {
            font-family: 'Courier New', monospace;
            font-size: 0.84rem;
            letter-spacing: 0.03em;
            color: var(--neon-cyan);
        }

        /* ── Select ── */
        .field-select {
            background: rgba(22, 31, 54, 0.85);
            border: 1px solid var(--border);
            border-radius: var(--radius-md);
            padding: 11px 14px;
            color: var(--text-primary);
            font-size: 0.875rem;
            font-family: inherit;
            outline: none;
            transition: border-color 0.2s, box-shadow 0.2s;
            width: 100%;
            cursor: pointer;
            appearance: none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 16 16'%3E%3Cpath fill='%239aa6c7' d='M7.247 11.14 2.451 5.658C1.885 5.013 2.345 4 3.204 4h9.592a1 1 0 0 1 .753 1.659l-4.796 5.48a1 1 0 0 1-1.506 0z'/%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 14px center;
            padding-right: 36px;
        }

        .field-select option { background: #0b1020; }

        .field-select:focus {
            border-color: var(--neon-purple);
            box-shadow: 0 0 0 3px rgba(139,92,246,0.12);
        }

        /* Status options with color hint */
        .status-hint {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-top: 6px;
        }
        .status-dot {
            width: 8px; height: 8px; border-radius: 50%;
            display: inline-block; flex-shrink: 0;
        }
        .status-hint-text { font-size: 0.75rem; color: var(--text-muted); }

        /* ── Divider ── */
        .divider {
            border: none;
            border-top: 1px solid var(--border);
            margin: 28px 0;
        }

        /* ── Footer actions ── */
        .form-actions {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }

        .btn-submit {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 11px 28px;
            border-radius: var(--radius-md);
            font-size: 0.9rem;
            font-weight: 700;
            border: none;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.2s;
        }

        .btn-submit-primary {
            background: linear-gradient(135deg, var(--neon-purple) 0%, #6d28d9 100%);
            color: #fff;
            box-shadow: 0 4px 16px rgba(139,92,246,0.4);
        }
        .btn-submit-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(139,92,246,0.55);
            background: linear-gradient(135deg, #a78bfa 0%, var(--neon-purple) 100%);
            color: #fff;
        }
        .btn-submit-primary:active { transform: translateY(0); }

        .btn-submit-ghost {
            background: rgba(42, 53, 85, 0.5);
            color: var(--text-muted);
            border: 1px solid var(--border);
        }
        .btn-submit-ghost:hover {
            background: rgba(42, 53, 85, 0.8);
            color: var(--text-primary);
            border-color: var(--neon-blue);
            box-shadow: 0 0 12px rgba(96,165,250,0.15);
        }

        /* ── Edit mode indicator ── */
        .edit-indicator {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: rgba(96, 165, 250, 0.10);
            border: 1px solid rgba(96, 165, 250, 0.25);
            border-radius: 6px;
            padding: 4px 12px;
            font-size: 0.75rem;
            color: var(--neon-blue);
            font-weight: 600;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
<div class="form-page">

    <!-- Back link -->
    <c:choose>
        <c:when test="${returnTo eq 'dashboard'}">
            <a class="back-link" href="staffDashboard.jsp?page=routers">
                <i class="bi bi-arrow-left"></i> Back to Dashboard
            </a>
        </c:when>
        <c:otherwise>
            <a class="back-link" href="MainController?action=routerList">
                <i class="bi bi-arrow-left"></i> Back to Routers
            </a>
        </c:otherwise>
    </c:choose>

    <!-- Header -->
    <div class="form-header">
        <div class="form-icon ${editMode ? 'form-icon-edit' : 'form-icon-add'}">
            <i class="bi bi-${editMode ? 'pencil-square' : 'router'}"></i>
        </div>
        <div>
            <div class="form-title">
                <c:choose>
                    <c:when test="${editMode}">Edit Router</c:when>
                    <c:otherwise>Add New Router</c:otherwise>
                </c:choose>
            </div>
            <div class="form-subtitle">
                <c:choose>
                    <c:when test="${editMode}">Update the configuration of this router device</c:when>
                    <c:otherwise>Register a new router device to the network</c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <!-- Edit mode chip -->
    <c:if test="${editMode}">
        <div class="edit-indicator">
            <i class="bi bi-pencil-fill"></i>
            Editing Router #${router.routerId}
        </div>
    </c:if>

    <!-- Error alert -->
    <c:if test="${not empty requestScope.error}">
        <div class="alert-error">
            <i class="bi bi-exclamation-triangle-fill"></i>
            <c:out value="${requestScope.error}" />
        </div>
    </c:if>

    <!-- Form card -->
    <div class="form-card">
        <form action="MainController" method="post">
            <%-- Hidden inputs: action & id (unchanged) --%>
            <c:choose>
                <c:when test="${editMode}">
                    <input type="hidden" name="action" value="routerUpdate">
                    <input type="hidden" name="routerId" value="${router.routerId}">
                </c:when>
                <c:otherwise>
                    <input type="hidden" name="action" value="routerInsert">
                </c:otherwise>
            </c:choose>
            <c:if test="${not empty returnTo}">
                <input type="hidden" name="returnTo" value="${returnTo}">
            </c:if>

            <!-- Section 1: Identity -->
            <div class="form-section">
                <div class="section-label">
                    <i class="bi bi-tag-fill"></i> Device Identity
                </div>
                <div class="field-grid field-grid-2">
                    <div class="field-group">
                        <label class="field-label">
                            <i class="bi bi-router-fill"></i>
                            Router Name <span class="req">*</span>
                        </label>
                        <input class="field-input"
                               type="text"
                               name="routerName"
                               value="${valueRouter.routerName}"
                               placeholder="e.g. Core-Router-01"
                               required>
                    </div>
                    <div class="field-group">
                        <label class="field-label">
                            <i class="bi bi-cpu-fill"></i>
                            Model
                        </label>
                        <input class="field-input"
                               type="text"
                               name="model"
                               value="${valueRouter.model}"
                               placeholder="e.g. Cisco ISR 4331">
                    </div>
                </div>
            </div>

            <!-- Section 2: Network -->
            <div class="form-section">
                <div class="section-label">
                    <i class="bi bi-diagram-3-fill"></i> Network Configuration
                </div>
                <div class="field-grid field-grid-2">
                    <div class="field-group">
                        <label class="field-label">
                            <i class="bi bi-globe"></i>
                            IP Address <span class="req">*</span>
                        </label>
                        <input class="field-input field-input-mono"
                               type="text"
                               name="ipAddress"
                               value="${valueRouter.ipAddress}"
                               placeholder="192.168.1.1"
                               required>
                    </div>
                    <div class="field-group">
                        <label class="field-label">
                            <i class="bi bi-ethernet"></i>
                            MAC Address <span class="req">*</span>
                        </label>
                        <input class="field-input field-input-mono"
                               type="text"
                               name="macAddress"
                               value="${valueRouter.macAddress}"
                               placeholder="AA:BB:CC:DD:EE:FF"
                               required>
                    </div>
                </div>
            </div>

            <!-- Section 3: Software & Status -->
            <div class="form-section">
                <div class="section-label">
                    <i class="bi bi-activity"></i> Software & Status
                </div>
                <div class="field-grid field-grid-2">
                    <div class="field-group">
                        <label class="field-label">
                            <i class="bi bi-code-slash"></i>
                            Firmware
                        </label>
                        <input class="field-input"
                               type="text"
                               name="firmware"
                               value="${valueRouter.firmware}"
                               placeholder="e.g. v15.4.3">
                    </div>
                    <div class="field-group">
                        <label class="field-label">
                            <i class="bi bi-circle-fill"></i>
                            Status
                        </label>
                        <input class="field-input"
                               type="text"
                               name="status"
                               value="${statusValue}"
                               placeholder="ONLINE / OFFLINE / MAINTENANCE">
                    </div>
                </div>
            </div>

            <!-- Section 4: Location -->
            <div class="form-section">
                <div class="section-label">
                    <i class="bi bi-geo-alt-fill"></i> Location
                </div>
                <div class="field-grid field-grid-3">
                    <div class="field-group">
                        <label class="field-label">
                            <i class="bi bi-building"></i>
                            Location
                        </label>
                        <input class="field-input"
                               type="text"
                               name="location"
                               value="${valueRouter.location}"
                               placeholder="e.g. Building A, Floor 2">
                    </div>
                    <div class="field-group">
                        <label class="field-label">
                            <i class="bi bi-door-open-fill"></i>
                            Room ID
                        </label>
                        <input class="field-input"
                               type="number"
                               name="roomId"
                               value="${roomIdValue}"
                               min="0"
                               placeholder="0">
                    </div>
                </div>
            </div>

            <hr class="divider">

            <!-- Actions -->
            <div class="form-actions">
                <button class="btn-submit btn-submit-primary" type="submit">
                    <i class="bi bi-${editMode ? 'check-lg' : 'plus-lg'}"></i>
                    <c:choose>
                        <c:when test="${editMode}">Save Changes</c:when>
                        <c:otherwise>Add Router</c:otherwise>
                    </c:choose>
                </button>
                <c:choose>
                    <c:when test="${returnTo eq 'dashboard'}">
                        <a class="btn-submit btn-submit-ghost" href="staffDashboard.jsp?page=routers">
                            <i class="bi bi-x-lg"></i> Cancel
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a class="btn-submit btn-submit-ghost" href="MainController?action=routerList">
                            <i class="bi bi-x-lg"></i> Cancel
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </form>
    </div>

</div>
</body>
</html>
