<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="Models.NetworkDeviceDAO"%>
<%@page import="Models.NetworkDeviceDTO"%>
<%@page import="java.util.ArrayList"%>
<%
    NetworkDeviceDAO deviceDAO = new NetworkDeviceDAO();
    ArrayList<NetworkDeviceDTO> devices = deviceDAO.ListAll();
    request.setAttribute("devices", devices);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Run Speed Test — Network Manager</title>
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
            max-width: 800px;
            margin: 0 auto;
            padding: 40px 24px;
            animation: fadeInUp 0.35s ease both;
        }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .page-header {
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 28px;
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

        .form-card {
            background: rgba(16, 23, 42, 0.82); border: 1px solid var(--border);
            border-radius: var(--radius-lg); padding: 32px;
            box-shadow: 0 8px 40px rgba(0,0,0,0.45), var(--glow-purple); backdrop-filter: blur(12px);
        }

        .form-label {
            color: #d8c9ff; font-size: 0.85rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 8px;
        }

        .form-control, .form-select {
            background: rgba(11, 16, 32, 0.8); border: 1px solid var(--border);
            color: var(--text-primary); border-radius: 8px; padding: 12px 16px; font-size: 0.95rem;
        }

        .form-control:focus, .form-select:focus {
            background: rgba(16, 23, 42, 0.9); border-color: var(--neon-purple);
            box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.2); color: var(--text-primary);
        }

        .form-control::placeholder { color: #5a6b9a; }
        
        .form-select option { background: #0b1020; color: #fff; }

        .input-group-text {
            background: rgba(22, 31, 54, 0.8); border: 1px solid var(--border); border-left: none; color: var(--neon-cyan); font-weight: 600;
        }
        
        .form-control:focus + .input-group-text { border-color: var(--neon-purple); }

        .form-actions {
            display: flex; gap: 14px; margin-top: 32px; padding-top: 24px; border-top: 1px solid var(--border); justify-content: flex-end;
        }

        .btn-dash {
            display: inline-flex; align-items: center; gap: 7px; padding: 10px 24px;
            border-radius: 8px; font-size: 0.95rem; font-weight: 600;
            border: none; cursor: pointer; text-decoration: none; transition: all 0.2s; white-space: nowrap;
        }

        .btn-dash-ghost {
            background: rgba(42, 53, 85, 0.55); color: var(--text-muted); border: 1px solid var(--border);
        }
        .btn-dash-ghost:hover {
            background: rgba(42, 53, 85, 0.85); color: var(--text-primary); border-color: var(--neon-blue);
        }

        .btn-dash-primary {
            background: linear-gradient(135deg, var(--neon-purple) 0%, #6d28d9 100%); color: #fff;
            box-shadow: 0 4px 14px rgba(139,92,246,0.35);
        }
        .btn-dash-primary:hover {
            background: linear-gradient(135deg, #a78bfa 0%, var(--neon-purple) 100%);
            transform: translateY(-1px); box-shadow: 0 6px 20px rgba(139,92,246,0.5); color: #fff;
        }
    </style>
</head>
<body>
<div class="page-wrapper">

    <div class="page-header">
        <div class="page-title-group">
            <div class="page-icon"><i class="bi bi-speedometer2"></i></div>
            <div>
                <h1 class="page-title">Run Speed Test</h1>
                <p class="page-subtitle">Record new bandwidth usage for a device</p>
            </div>
        </div>
    </div>

    <div class="form-card">
        <form action="MainController" method="post">
            <input type="hidden" name="action" value="bandwidthInsert">
            
            <div class="mb-4">
                <label class="form-label">Network Device <span class="text-danger">*</span></label>
                <div class="input-group">
                    <span class="input-group-text" style="border-right:none; border-left:1px solid var(--border);"><i class="bi bi-laptop text-muted"></i></span>
                    <select class="form-select" name="deviceId" required style="border-left:none;">
                        <option value="" disabled selected>Select a device to test...</option>
                        <c:forEach var="device" items="${devices}">
                            <option value="${device.deviceId}">${device.deviceName} (${device.ipAddress})</option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <div class="row mb-4">
                <div class="col-md-6">
                    <label class="form-label">Upload Speed <span class="text-danger">*</span></label>
                    <div class="input-group">
                        <span class="input-group-text" style="border-right:none; border-left:1px solid var(--border);"><i class="bi bi-cloud-arrow-up" style="color:var(--neon-green)"></i></span>
                        <input type="number" step="0.01" min="0" class="form-control" name="uploadSpeed" placeholder="0.00" required style="border-left:none; border-right:none;">
                        <span class="input-group-text">Mbps</span>
                    </div>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Download Speed <span class="text-danger">*</span></label>
                    <div class="input-group">
                        <span class="input-group-text" style="border-right:none; border-left:1px solid var(--border);"><i class="bi bi-cloud-arrow-down" style="color:var(--neon-cyan)"></i></span>
                        <input type="number" step="0.01" min="0" class="form-control" name="downloadSpeed" placeholder="0.00" required style="border-left:none; border-right:none;">
                        <span class="input-group-text">Mbps</span>
                    </div>
                </div>
            </div>

            <div class="form-actions">
                <a href="bandwidth-list.jsp" class="btn-dash btn-dash-ghost">Cancel</a>
                <button type="submit" class="btn-dash btn-dash-primary">
                    <i class="bi bi-check2"></i> Save Record
                </button>
            </div>
        </form>
    </div>

</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
