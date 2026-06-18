<%-- login.jsp - Themed auth page (network media from /theme) --%>
    <%@page contentType="text/html" pageEncoding="UTF-8" %>
        <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Network Manager — Sign In</title>

                <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"
                    rel="stylesheet">
                <script src="https://accounts.google.com/gsi/client" async defer></script>

                <style>
                    :root {
                        --bg-0: #04060d;
                        --bg-1: #0a1020;
                        --surface: rgba(14, 20, 36, 0.78);
                        --surface-2: rgba(20, 28, 48, 0.75);
                        --border: rgba(146, 167, 223, 0.25);
                        --text-primary: #f3f6ff;
                        --text-muted: #a2b0d4;
                        --danger: #ff6b81;
                        --neon-purple: #8b5cf6;
                        --neon-pink: #d946ef;
                        --neon-blue: #60a5fa;
                        --focus-ring: 0 0 0 4px rgba(139, 92, 246, 0.22);
                        --shadow-main: 0 24px 55px rgba(0, 0, 0, 0.55);
                        --radius-xl: 18px;
                        --radius-md: 10px;
                    }

                    * {
                        box-sizing: border-box;
                    }

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
                        position: fixed;
                        inset: 0;
                        width: 100%;
                        height: 100%;
                        object-fit: cover;
                        opacity: 0.32;
                        z-index: -3;
                        filter: saturate(1.2) contrast(1.05);
                    }

                    .bg-overlay {
                        position: fixed;
                        inset: 0;
                        z-index: -2;
                        background:
                            linear-gradient(120deg, rgba(5, 8, 18, 0.82), rgba(6, 9, 20, 0.68)),
                            radial-gradient(circle at 15% 20%, rgba(139, 92, 246, 0.22), transparent 34%),
                            radial-gradient(circle at 86% 12%, rgba(96, 165, 250, 0.16), transparent 28%);
                    }

                    .bg-grid {
                        position: fixed;
                        inset: 0;
                        z-index: -1;
                        background-image:
                            linear-gradient(to right, rgba(255, 255, 255, 0.06) 1px, transparent 1px),
                            linear-gradient(to bottom, rgba(255, 255, 255, 0.05) 1px, transparent 1px);
                        background-size: 72px 72px;
                        opacity: .22;
                        pointer-events: none;
                    }

                    .auth-shell {
                        width: 100%;
                        max-width: 1120px;
                        min-height: 640px;
                        border: 1px solid var(--border);
                        border-radius: var(--radius-xl);
                        background: rgba(8, 12, 24, 0.55);
                        backdrop-filter: blur(10px);
                        box-shadow: var(--shadow-main);
                        overflow: hidden;
                        display: grid;
                        grid-template-columns: 1.06fr 0.94fr;
                    }

                    .left-panel {
                        position: relative;
                        padding: 46px;
                        background:
                            linear-gradient(145deg, rgba(6, 9, 20, 0.7), rgba(10, 14, 28, 0.5)),
                            url('theme/original-f73343d902c4c7335f94cb0e9dc08fef.webp') center/cover no-repeat;
                        border-right: 1px solid var(--border);
                        display: flex;
                        align-items: flex-end;
                    }

                    .left-panel::after {
                        content: "";
                        position: absolute;
                        inset: 0;
                        background:
                            linear-gradient(transparent 55%, rgba(3, 6, 16, 0.8) 100%),
                            repeating-linear-gradient(90deg, rgba(96, 165, 250, 0.07) 0 1px, transparent 1px 72px);
                        pointer-events: none;
                    }

                    .left-content {
                        position: relative;
                        z-index: 1;
                        max-width: 460px;
                    }

                    .left-kicker {
                        display: inline-block;
                        margin-bottom: 14px;
                        padding: 6px 12px;
                        border-radius: 999px;
                        font-size: 12px;
                        letter-spacing: .08em;
                        text-transform: uppercase;
                        color: #dbc8ff;
                        border: 1px solid rgba(139, 92, 246, 0.5);
                        background: rgba(139, 92, 246, 0.18);
                    }

                    .left-title {
                        margin: 0 0 10px;
                        font-size: 48px;
                        line-height: 1.05;
                        font-weight: 800;
                        text-shadow: 0 8px 26px rgba(0, 0, 0, 0.45);
                    }

                    .left-sub {
                        margin: 0 0 24px;
                        font-size: 18px;
                        line-height: 1.45;
                        color: #d7def8;
                        max-width: 430px;
                    }

                    .feature-list {
                        list-style: none;
                        margin: 0;
                        padding: 0;
                    }

                    .feature-list li {
                        display: flex;
                        gap: 10px;
                        align-items: center;
                        font-size: 14px;
                        color: #d5dcf6;
                        margin-bottom: 10px;
                    }

                    .feature-list i {
                        color: #c8a9ff;
                        font-size: 14px;
                    }

                    .right-panel {
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        padding: 36px 30px;
                        background:
                            radial-gradient(circle at 85% 20%, rgba(139, 92, 246, 0.14), transparent 32%),
                            linear-gradient(180deg, rgba(14, 20, 36, 0.72), rgba(8, 12, 24, 0.84));
                    }

                    .form-wrap {
                        width: 100%;
                        max-width: 380px;
                    }

                    .title {
                        margin: 0 0 8px;
                        font-size: 34px;
                        font-weight: 800;
                        text-align: center;
                    }

                    .sub {
                        margin: 0 0 24px;
                        text-align: center;
                        color: var(--text-muted);
                        font-size: 14px;
                    }

                    .alert-error {
                        border: 1px solid rgba(255, 107, 129, 0.45);
                        background: rgba(255, 107, 129, 0.12);
                        color: #ffc0cb;
                        border-radius: var(--radius-md);
                        font-size: 13px;
                        padding: 10px 12px;
                        margin-bottom: 14px;
                        display: flex;
                        gap: 8px;
                        align-items: center;
                    }

                    .field {
                        margin-bottom: 13px;
                    }

                    .field label {
                        display: block;
                        margin-bottom: 6px;
                        font-size: 13px;
                        color: #d9def2;
                        font-weight: 600;
                        letter-spacing: .02em;
                    }

                    .input-wrap {
                        position: relative;
                    }

                    .input-wrap i {
                        position: absolute;
                        left: 12px;
                        top: 50%;
                        transform: translateY(-50%);
                        color: #8ea0cd;
                        font-size: 14px;
                        pointer-events: none;
                    }

                    .field input {
                        width: 100%;
                        height: 44px;
                        border-radius: var(--radius-md);
                        border: 1px solid var(--border);
                        background: rgba(16, 23, 42, 0.72);
                        color: var(--text-primary);
                        padding: 0 12px 0 36px;
                        font-size: 14px;
                        outline: none;
                        transition: border-color .2s, box-shadow .2s;
                    }

                    .field input::placeholder {
                        color: #7481a8;
                    }

                    .field input:focus {
                        border-color: var(--neon-purple);
                        box-shadow: var(--focus-ring);
                    }

                    .password-row {
                        position: relative;
                    }

                    .toggle-pass {
                        position: absolute;
                        right: 10px;
                        top: 50%;
                        transform: translateY(-50%);
                        border: none;
                        background: transparent;
                        color: #93a0c8;
                        cursor: pointer;
                        padding: 4px;
                    }

                    .btn-login {
                        width: 100%;
                        margin-top: 6px;
                        border: none;
                        border-radius: var(--radius-md);
                        height: 46px;
                        font-size: 15px;
                        font-weight: 700;
                        color: white;
                        cursor: pointer;
                        background: linear-gradient(90deg, var(--neon-purple), var(--neon-pink));
                        box-shadow: 0 10px 22px rgba(139, 92, 246, 0.35);
                    }

                    .divider {
                        margin: 16px 0 14px;
                        display: flex;
                        align-items: center;
                        gap: 10px;
                        color: #8391b8;
                        font-size: 12px;
                        text-transform: uppercase;
                        letter-spacing: .08em;
                    }

                    .divider::before,
                    .divider::after {
                        content: "";
                        flex: 1;
                        height: 1px;
                        background: #2a3558;
                    }

                    .gbox {
                        display: flex;
                        justify-content: center;
                        margin-bottom: 12px;
                    }

                    .register-link {
                        text-align: center;
                        font-size: 13px;
                        color: #b7c2e6;
                    }

                    .register-link a {
                        color: #caa7ff;
                        text-decoration: none;
                        font-weight: 600;
                    }

                    .foot-note {
                        margin-top: 18px;
                        text-align: center;
                        font-size: 11px;
                        color: #7f8db4;
                        letter-spacing: .06em;
                        text-transform: uppercase;
                    }

                    @media (max-width: 980px) {
                        .auth-shell {
                            grid-template-columns: 1fr;
                            min-height: auto;
                        }

                        .left-panel {
                            min-height: 250px;
                            padding: 30px 26px;
                        }

                        .left-title {
                            font-size: 36px;
                        }

                        .left-sub {
                            font-size: 15px;
                        }

                        .right-panel {
                            padding: 28px 20px 30px;
                        }
                    }
                </style>
            </head>

            <body>
                <video class="bg-video" autoplay muted loop playsinline>
                    <source src="theme/original-bbd8c0ff4dbd70e3f804581b5b16a73f.mp4" type="video/mp4">
                </video>
                <div class="bg-overlay"></div>
                <div class="bg-grid"></div>

                <div class="auth-shell">
                    <section class="left-panel">
                        <div class="left-content">
                            <span class="left-kicker">Network Security Portal</span>
                            <h1 class="left-title">Create your<br>connected workspace</h1>
                            <p class="left-sub">
                                Monitor routers, access points and network health in one secure platform.
                            </p>
                            <ul class="feature-list">
                                <li><i class="bi bi-check-circle-fill"></i> Real-time device monitoring</li>
                                <li><i class="bi bi-check-circle-fill"></i> Access point analytics</li>
                                <li><i class="bi bi-check-circle-fill"></i> Alert and maintenance workflow</li>
                            </ul>
                        </div>
                    </section>

                    <section class="right-panel">
                        <div class="form-wrap">
                            <h2 class="title">Sign In</h2>
                            <p class="sub">Enter your account credentials to continue</p>

                            <% String errorMsg=(String) request.getAttribute("errorMsg"); %>
                                <% if (errorMsg !=null && !errorMsg.isEmpty()) { %>
                                    <div class="alert-error">
                                        <i class="bi bi-exclamation-triangle-fill"></i>
                                        <span>
                                            <%= errorMsg %>
                                        </span>
                                    </div>
                                    <% } %>

                                <% String successMsg = (String) request.getAttribute("success"); %>
                                <% if (successMsg != null && !successMsg.isEmpty()) { %>
                                    <div class="alert-success" style="border: 1px solid rgba(16, 185, 129, 0.45); background: rgba(16, 185, 129, 0.12); color: #a7f3d0; border-radius: var(--radius-md); font-size: 13px; padding: 10px 12px; margin-bottom: 14px; display: flex; gap: 8px; align-items: center;">
                                        <i class="bi bi-check-circle-fill"></i>
                                        <span>
                                            <%= successMsg %>
                                        </span>
                                    </div>
                                <% } %>

                                        <c:if test="${not empty error}">
                                            <div class="alert-error">
                                                <i class="bi bi-exclamation-triangle-fill"></i>
                                                <span>${error}</span>
                                            </div>
                                        </c:if>

                                        <form action="LoginController" method="POST" autocomplete="off">
                                            <div class="field">
                                                <label for="username">Username or Email</label>
                                                <div class="input-wrap">
                                                    <i class="bi bi-person-fill"></i>
                                                    <input type="text" id="username" name="username"
                                                        placeholder="Enter your username or email" required autofocus>
                                                </div>
                                            </div>

                                            <div class="field">
                                                <label for="password">Password</label>
                                                <div class="input-wrap password-row">
                                                    <i class="bi bi-shield-lock-fill"></i>
                                                    <input type="password" id="password" name="password"
                                                        placeholder="Enter your password" required>
                                                    <button class="toggle-pass" type="button" id="togglePwd"
                                                        aria-label="Toggle password">
                                                        <i class="bi bi-eye-slash" id="eyeIcon"></i>
                                                    </button>
                                                </div>
                                            </div>

                                            <button type="submit" class="btn-login">
                                                <i class="bi bi-box-arrow-in-right"></i> Sign In
                                            </button>
                                        </form>

                                        <div class="divider">or</div>

                                        <div id="g_id_onload"
                                            data-client_id="353952447542-f2u39lhvfn0j2ikufm0pbl9jcc84q1hj.apps.googleusercontent.com"
                                            data-callback="handleGoogleLogin">
                                        </div>
                                        <div class="gbox">
                                            <div class="g_id_signin" data-type="standard" data-text="signin_with"
                                                data-shape="rectangular" data-logo_alignment="left">
                                            </div>
                                        </div>

                                        <p class="register-link">
                                            Don’t have an account?
                                            <a href="user-form.jsp?source=normal">Create a new account</a>
                                        </p>

                                        <div class="foot-note">University Network Management System</div>
                        </div>
                    </section>
                </div>

                <script>
                    document.getElementById('togglePwd').addEventListener('click', function () {
                        const pwd = document.getElementById('password');
                        const icon = document.getElementById('eyeIcon');
                        if (pwd.type === 'password') {
                            pwd.type = 'text';
                            icon.className = 'bi bi-eye';
                        } else {
                            pwd.type = 'password';
                            icon.className = 'bi bi-eye-slash';
                        }
                    });

                    function handleGoogleLogin(response) {
                        const form = document.createElement("form");
                        form.method = "POST";
                        form.action = "GoogleLoginController";

                        const input = document.createElement("input");
                        input.type = "hidden";
                        input.name = "credential";
                        input.value = response.credential;

                        form.appendChild(input);
                        document.body.appendChild(form);
                        form.submit();
                    }
                </script>
            </body>

            </html>