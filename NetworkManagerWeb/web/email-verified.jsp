<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Email Verified — Network Manager</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root {
            --bg-0: #04060d;
            --bg-1: #0a1020;
            --surface: rgba(14, 20, 36, 0.78);
            --border: rgba(146, 167, 223, 0.25);
            --text-primary: #f3f6ff;
            --text-muted: #a2b0d4;
            --neon-purple: #8b5cf6;
            --neon-pink: #d946ef;
            --neon-green: #10b981;
            --shadow-main: 0 24px 55px rgba(0, 0, 0, 0.55);
            --radius-xl: 18px;
            --radius-md: 10px;
        }
        * { box-sizing: border-box; }
        body {
            margin: 0;
            min-height: 100vh;
            font-family: "Segoe UI", Arial, sans-serif;
            color: var(--text-primary);
            background: linear-gradient(135deg, #03050c 0%, #090f1d 45%, #04060d 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            overflow: hidden;
        }
        .bg-video {
            position: fixed; inset: 0; width: 100%; height: 100%;
            object-fit: cover; opacity: 0.32; z-index: -3;
            filter: saturate(1.2) contrast(1.05);
        }
        .bg-overlay {
            position: fixed; inset: 0; z-index: -2;
            background:
                linear-gradient(120deg, rgba(5, 8, 18, 0.82), rgba(6, 9, 20, 0.68)),
                radial-gradient(circle at 15% 20%, rgba(139, 92, 246, 0.22), transparent 34%),
                radial-gradient(circle at 86% 12%, rgba(96, 165, 250, 0.16), transparent 28%);
        }
        .bg-grid {
            position: fixed; inset: 0; z-index: -1;
            background-image:
                linear-gradient(to right, rgba(255,255,255,0.06) 1px, transparent 1px),
                linear-gradient(to bottom, rgba(255,255,255,0.05) 1px, transparent 1px);
            background-size: 72px 72px; opacity: .22; pointer-events: none;
        }
        .card {
            width: 100%;
            max-width: 460px;
            border: 1px solid var(--border);
            border-radius: var(--radius-xl);
            background: rgba(8, 12, 24, 0.55);
            backdrop-filter: blur(10px);
            box-shadow: var(--shadow-main);
            padding: 48px 40px;
            text-align: center;
        }
        .icon-wrap {
            width: 80px; height: 80px; margin: 0 auto 24px;
            border-radius: 50%;
            background: linear-gradient(135deg, rgba(16, 185, 129, 0.2), rgba(16, 185, 129, 0.08));
            border: 2px solid rgba(16, 185, 129, 0.3);
            display: flex; align-items: center; justify-content: center;
            animation: pulse-glow 2s ease-in-out infinite;
        }
        @keyframes pulse-glow {
            0%, 100% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.3); }
            50% { box-shadow: 0 0 24px 8px rgba(16, 185, 129, 0.1); }
        }
        .icon-wrap i { font-size: 36px; color: var(--neon-green); }
        h2 {
            margin: 0 0 8px; font-size: 28px; font-weight: 800;
            letter-spacing: -0.02em; color: #a7f3d0;
        }
        .sub {
            margin: 0 0 24px; color: var(--text-muted); font-size: 14px; line-height: 1.6;
        }
        .alert-success {
            border-radius: var(--radius-md); font-size: 13px; padding: 12px 14px; margin-bottom: 20px;
            display: flex; gap: 8px; align-items: center; text-align: left;
            border: 1px solid rgba(16, 185, 129, 0.45);
            background: rgba(16, 185, 129, 0.12);
            color: #a7f3d0;
        }
        .btn-login {
            display: inline-flex; align-items: center; gap: 8px;
            border: none; border-radius: var(--radius-md); height: 46px;
            padding: 0 32px; font-size: 15px; font-weight: 700;
            color: white; cursor: pointer; text-decoration: none;
            background: linear-gradient(90deg, var(--neon-purple), var(--neon-pink));
            box-shadow: 0 10px 22px rgba(139, 92, 246, 0.35);
            transition: transform .15s;
        }
        .btn-login:active { transform: scale(0.97); }
        .features {
            display: flex; flex-direction: column; gap: 10px; margin: 24px 0 0;
            padding: 16px 20px;
            background: rgba(255,255,255,0.03);
            border-radius: var(--radius-md);
            border: 1px solid var(--border);
            text-align: left;
        }
        .feature { display: flex; gap: 10px; align-items: center; font-size: 13px; color: #d5dcf6; }
        .feature i { color: var(--neon-green); font-size: 14px; }
        .foot-note { margin-top: 24px; font-size: 11px; color: #7f8db4; letter-spacing: .06em; text-transform: uppercase; }
    </style>
</head>
<body>
    <video class="bg-video" autoplay muted loop playsinline>
        <source src="theme/original-bbd8c0ff4dbd70e3f804581b5b16a73f.mp4" type="video/mp4">
    </video>
    <div class="bg-overlay"></div>
    <div class="bg-grid"></div>

    <div class="card">
        <div class="icon-wrap">
            <i class="bi bi-check2-circle"></i>
        </div>
        <h2>Email Verified</h2>
        <p class="sub">Your email has been confirmed. You're all set.</p>

        <% if (request.getAttribute("success") != null) { %>
            <div class="alert-success">
                <i class="bi bi-check-circle-fill"></i>
                <span><%= request.getAttribute("success") %></span>
            </div>
        <% } %>

        <a href="login.jsp" class="btn-login">
            <i class="bi bi-box-arrow-in-right"></i> Login Now
        </a>

        <div class="features">
            <div class="feature"><i class="bi bi-shield-check"></i> Account is now active</div>
            <div class="feature"><i class="bi bi-graph-up-arrow"></i> Full access to dashboards</div>
            <div class="feature"><i class="bi bi-bell"></i> Real-time network alerts</div>
        </div>

        <div class="foot-note">University Network Management System</div>
    </div>
</body>
</html>
