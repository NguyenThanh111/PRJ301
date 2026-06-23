<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    response.setHeader("Referrer-Policy", "no-referrer");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Set New Password — Network Manager</title>
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
            --neon-blue: #60a5fa;
            --danger: #ff6b81;
            --focus-ring: 0 0 0 4px rgba(139, 92, 246, 0.22);
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
        }
        .icon-wrap {
            width: 64px; height: 64px; margin: 0 auto 20px;
            border-radius: 50%;
            background: linear-gradient(135deg, rgba(139, 92, 246, 0.2), rgba(217, 70, 239, 0.2));
            border: 1px solid rgba(139, 92, 246, 0.3);
            display: flex; align-items: center; justify-content: center;
        }
        .icon-wrap i { font-size: 28px; color: var(--neon-purple); }
        h2 {
            margin: 0 0 8px; font-size: 26px; font-weight: 800;
            text-align: center; letter-spacing: -0.02em;
        }
        .sub {
            margin: 0 0 24px; text-align: center;
            color: var(--text-muted); font-size: 14px; line-height: 1.6;
        }
        .alert {
            border-radius: var(--radius-md); font-size: 13px; padding: 12px 14px; margin-bottom: 16px;
            display: flex; gap: 8px; align-items: center;
        }
        .alert-error {
            border: 1px solid rgba(255, 107, 129, 0.45);
            background: rgba(255, 107, 129, 0.12);
            color: #ffc0cb;
        }
        .field { margin-bottom: 14px; }
        .field label {
            display: block; margin-bottom: 6px;
            font-size: 13px; color: #d9def2; font-weight: 600; letter-spacing: .02em;
        }
        .input-wrap { position: relative; }
        .input-wrap i {
            position: absolute; left: 12px; top: 50%; transform: translateY(-50%);
            color: #8ea0cd; font-size: 14px; pointer-events: none;
        }
        .field input {
            width: 100%; height: 44px;
            border-radius: var(--radius-md);
            border: 1px solid var(--border);
            background: rgba(16, 23, 42, 0.72);
            color: var(--text-primary);
            padding: 0 12px 0 36px;
            font-size: 14px; outline: none;
            transition: border-color .2s, box-shadow .2s;
        }
        .field input::placeholder { color: #7481a8; }
        .field input:focus { border-color: var(--neon-purple); box-shadow: var(--focus-ring); }
        .password-row { position: relative; }
        .toggle-pass {
            position: absolute; right: 10px; top: 50%; transform: translateY(-50%);
            border: none; background: transparent; color: #93a0c8; cursor: pointer; padding: 4px;
        }
        .hint { color: #8ea0cd; font-size: 11px; font-weight: 500; margin-left: 4px; }
        .btn-submit {
            width: 100%; margin-top: 4px;
            border: none; border-radius: var(--radius-md); height: 46px;
            font-size: 15px; font-weight: 700; color: white; cursor: pointer;
            background: linear-gradient(90deg, var(--neon-purple), var(--neon-pink));
            box-shadow: 0 10px 22px rgba(139, 92, 246, 0.35);
            transition: transform .15s;
            display: flex; align-items: center; justify-content: center; gap: 8px;
        }
        .btn-submit:active { transform: scale(0.97); }
        .back-link {
            display: block; text-align: center; margin-top: 16px;
            color: #93a0c8; font-size: 12px; text-decoration: none;
        }
        .back-link i { margin-right: 4px; }
        .back-link:hover { color: #caa7ff; }
        .foot-note { margin-top: 24px; text-align: center; font-size: 11px; color: #7f8db4; letter-spacing: .06em; text-transform: uppercase; }
        .strength-bar {
            height: 3px; border-radius: 999px; margin-top: 6px;
            background: rgba(255,255,255,0.06);
            overflow: hidden; transition: all .2s;
        }
        .strength-bar-fill {
            height: 100%; width: 0%; border-radius: 999px;
            transition: width .3s, background .3s;
        }
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
            <i class="bi bi-shield-lock-fill"></i>
        </div>
        <h2>Set New Password</h2>
        <p class="sub">Choose a strong password for your account.</p>

        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error">
                <i class="bi bi-exclamation-triangle-fill"></i>
                <span><%= request.getAttribute("error") %></span>
            </div>
        <% } %>

        <form action="ResetPasswordController" method="post">
            <input type="hidden" name="token" value="<%= request.getAttribute("token") != null ? request.getAttribute("token") : "" %>">

            <div class="field">
                <label for="newPassword">New Password <span class="hint">(min 6 characters)</span></label>
                <div class="input-wrap password-row">
                    <i class="bi bi-shield-lock-fill"></i>
                    <input type="password" id="newPassword" name="newPassword" minlength="6"
                        placeholder="Create new password" required autofocus>
                    <button class="toggle-pass" type="button" id="toggleNew" aria-label="Toggle password">
                        <i class="bi bi-eye-slash" id="eyeNew"></i>
                    </button>
                </div>
                <div class="strength-bar">
                    <div class="strength-bar-fill" id="strengthFill"></div>
                </div>
            </div>

            <div class="field">
                <label for="confirmPassword">Confirm Password</label>
                <div class="input-wrap password-row">
                    <i class="bi bi-patch-check-fill"></i>
                    <input type="password" id="confirmPassword" name="confirmPassword" minlength="6"
                        placeholder="Confirm new password" required>
                    <button class="toggle-pass" type="button" id="toggleConfirm" aria-label="Toggle password">
                        <i class="bi bi-eye-slash" id="eyeConfirm"></i>
                    </button>
                </div>
                <div id="matchHint" style="font-size: 12px; margin-top: 4px; min-height: 18px;"></div>
            </div>

            <button type="submit" class="btn-submit">
                <i class="bi bi-check2"></i> Reset Password
            </button>
        </form>

        <a href="login.jsp" class="back-link"><i class="bi bi-arrow-left"></i> Back to Login</a>
        <div class="foot-note">University Network Management System</div>
    </div>

    <script>
        (function() {
            const newPwd = document.getElementById('newPassword');
            const confirmPwd = document.getElementById('confirmPassword');
            const matchHint = document.getElementById('matchHint');
            const strengthFill = document.getElementById('strengthFill');

            function calcStrength(pw) {
                let score = 0;
                if (pw.length >= 6) score += 20;
                if (pw.length >= 10) score += 20;
                if (/[a-z]/.test(pw) && /[A-Z]/.test(pw)) score += 20;
                if (/\d/.test(pw)) score += 20;
                if (/[^a-zA-Z0-9]/.test(pw)) score += 20;
                return score;
            }

            function updateStrength() {
                const score = calcStrength(newPwd.value);
                strengthFill.style.width = score + '%';
                if (score <= 20) { strengthFill.style.background = '#ff6b81'; }
                else if (score <= 40) { strengthFill.style.background = '#f59e0b'; }
                else if (score <= 60) { strengthFill.style.background = '#60a5fa'; }
                else { strengthFill.style.background = '#10b981'; }
            }

            function checkMatch() {
                if (!confirmPwd.value) { matchHint.textContent = ''; return; }
                if (newPwd.value === confirmPwd.value) {
                    matchHint.innerHTML = '<i class="bi bi-check-circle" style="color:#10b981;"></i> Passwords match';
                    matchHint.style.color = '#a7f3d0';
                } else {
                    matchHint.innerHTML = '<i class="bi bi-exclamation-circle" style="color:#ff6b81;"></i> Passwords do not match';
                    matchHint.style.color = '#ffc0cb';
                }
            }

            newPwd.addEventListener('input', function() { updateStrength(); checkMatch(); });
            confirmPwd.addEventListener('input', checkMatch);

            function toggleVisibility(inputId, iconId) {
                const input = document.getElementById(inputId);
                const icon = document.getElementById(iconId);
                input.type = input.type === 'password' ? 'text' : 'password';
                icon.className = input.type === 'password' ? 'bi bi-eye-slash' : 'bi bi-eye';
            }

            document.getElementById('toggleNew').addEventListener('click', function() {
                toggleVisibility('newPassword', 'eyeNew');
            });
            document.getElementById('toggleConfirm').addEventListener('click', function() {
                toggleVisibility('confirmPassword', 'eyeConfirm');
            });
        })();
    </script>
</body>
</html>
