<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <% String source=request.getParameter("source"); if (source==null || source.trim().isEmpty()) { Object
        sourceAttr=request.getAttribute("source"); source=sourceAttr !=null ? sourceAttr.toString() : "normal" ; }
        boolean isGoogleSource="google" .equalsIgnoreCase(source); String sessionGoogleEmail=null; String
        sessionGoogleName=null; Boolean googleFirstLogin=null; if (session !=null) { sessionGoogleEmail=(String)
        session.getAttribute("googleEmail"); sessionGoogleName=(String) session.getAttribute("googleName");
        googleFirstLogin=(Boolean) session.getAttribute("googleFirstLogin"); } if (isGoogleSource &&
        (googleFirstLogin==null || !googleFirstLogin || sessionGoogleEmail==null)) { response.sendRedirect("login.jsp");
        return; } String error=(String) request.getAttribute("error"); String
        usernameVal=request.getParameter("username") !=null ? request.getParameter("username") : "" ; String
        fullNameVal=request.getParameter("fullName") !=null ? request.getParameter("fullName") : "" ; if (isGoogleSource
        && (fullNameVal==null || fullNameVal.trim().isEmpty()) && sessionGoogleName !=null) {
        fullNameVal=sessionGoogleName; } String emailVal=isGoogleSource ? (sessionGoogleEmail !=null ?
        sessionGoogleEmail : "" ) : (request.getParameter("email") !=null ? request.getParameter("email") : "" ); %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>
                <%= isGoogleSource ? "Complete Registration" : "Sign Up" %> — Network Manager
            </title>
            <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
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
                    opacity: 0.3;
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
                        url('theme/original-ed1caa61b27dd5dba96cc8edeb223fc5.webp') center/cover no-repeat;
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
                    font-size: 46px;
                    line-height: 1.06;
                    font-weight: 800;
                    text-shadow: 0 8px 26px rgba(0, 0, 0, 0.45);
                }

                .left-sub {
                    margin: 0;
                    font-size: 18px;
                    line-height: 1.45;
                    color: #d7def8;
                    max-width: 430px;
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
                    max-width: 390px;
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
                    line-height: 1.45;
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

                .hint {
                    color: #8ea0cd;
                    font-size: 11px;
                    font-weight: 500;
                    margin-left: 4px;
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

                .field input[readonly] {
                    background: rgba(255, 255, 255, 0.05);
                    color: #b7c2e6;
                    cursor: not-allowed;
                }

                .inline-error {
                    color: #ff95a9;
                    font-size: 12px;
                    margin-top: 6px;
                    min-height: 16px;
                }

                .agreement {
                    display: flex;
                    align-items: center;
                    gap: 8px;
                    margin: 8px 0 16px 0;
                    font-size: 12px;
                    color: #b9c5e8;
                }

                .agreement input[type="checkbox"] {
                    transform: translateY(1px);
                    accent-color: var(--neon-purple);
                }

                .btn-submit {
                    width: 100%;
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

                .back-link {
                    display: block;
                    text-align: center;
                    margin-top: 12px;
                    font-size: 13px;
                    color: #caa7ff;
                    text-decoration: none;
                    font-weight: 600;
                }

                .back-link:hover {
                    text-decoration: underline;
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
                        <h1 class="left-title">
                            <%= isGoogleSource ? "Complete your account" : "Create your account" %>
                        </h1>
                        <p class="left-sub">
                            <%= isGoogleSource
                                ? "First Google login detected. Complete your profile to continue securely."
                                : "Set up your account to access the network management workspace." %>
                        </p>
                    </div>
                </section>

                <section class="right-panel">
                    <div class="form-wrap">
                        <h2 class="title">
                            <%= isGoogleSource ? "Complete Profile" : "Sign Up" %>
                        </h2>
                        <p class="sub">
                            <%= isGoogleSource ? "Fill in missing information to finish Google onboarding."
                                : "Register a new account to continue." %>
                        </p>

                        <% if (error !=null && !error.trim().isEmpty()) { %>
                            <div class="alert-error">
                                <i class="bi bi-exclamation-triangle-fill"></i>
                                <span>
                                    <%= error %>
                                </span>
                            </div>
                            <% } %>

                                <form id="registerForm" action="RegisterUserController" method="post"
                                    autocomplete="off">
                                    <input type="hidden" name="source" value="<%= isGoogleSource ? "google" : "normal"
                                        %>"/>

                                    <div class="field">
                                        <label for="fullName">Full name</label>
                                        <div class="input-wrap">
                                            <i class="bi bi-person-badge-fill"></i>
                                            <input id="fullName" type="text" name="fullName" value="<%= fullNameVal %>"
                                                placeholder="Your full name" required />
                                        </div>
                                    </div>

                                    <div class="field">
                                        <label for="username">Username</label>
                                        <div class="input-wrap">
                                            <i class="bi bi-person-fill"></i>
                                            <input id="username" type="text" name="username" value="<%= usernameVal %>"
                                                placeholder="Choose username" required />
                                        </div>
                                    </div>

                                    <div class="field">
                                        <label for="email">Email <span class="hint">(use a popular provider e.g.
                                                gmail)</span></label>
                                        <div class="input-wrap">
                                            <i class="bi bi-envelope-fill"></i>
                                            <input id="email" type="email" name="email" value="<%= emailVal %>"
                                                placeholder="you@example.com" <%=isGoogleSource ? "readonly"
                                                : "required" %> />
                                        </div>
                                    </div>

                                    <div class="field">
                                        <label for="password">Password <span class="hint">(minimum 6
                                                characters)</span></label>
                                        <div class="input-wrap">
                                            <i class="bi bi-shield-lock-fill"></i>
                                            <input id="password" type="password" name="password" minlength="6"
                                                placeholder="Create password" required />
                                        </div>
                                    </div>

                                    <div class="field">
                                        <label for="confirmPassword">Password<sup>2</sup> <span class="hint">(again, for
                                                confirmation)</span></label>
                                        <div class="input-wrap">
                                            <i class="bi bi-patch-check-fill"></i>
                                            <input id="confirmPassword" type="password" name="confirmPassword"
                                                minlength="6" placeholder="Confirm password" required />
                                        </div>
                                        <div id="confirmError" class="inline-error"></div>
                                    </div>

                                    <div class="agreement">
                                        <input type="checkbox" id="agreeTerms" required>
                                        <label for="agreeTerms">Accept Terms & Conditions</label>
                                    </div>

                                    <button class="btn-submit" type="submit">
                                        <%= isGoogleSource ? "Complete & Continue with Google" : "Join us" %>
                                    </button>
                                </form>

                                <a class="back-link" href="login.jsp">Back to Login</a>
                    </div>
                </section>
            </div>

            <script>
                (function () {
                    const form = document.getElementById('registerForm');
                    const pwd = document.getElementById('password');
                    const confirmPwd = document.getElementById('confirmPassword');
                    const errorBox = document.getElementById('confirmError');

                    function validateConfirmPassword() {
                        if (confirmPwd.value && pwd.value !== confirmPwd.value) {
                            errorBox.textContent = 'Confirm password does not match.';
                            return false;
                        }
                        errorBox.textContent = '';
                        return true;
                    }

                    confirmPwd.addEventListener('input', validateConfirmPassword);
                    pwd.addEventListener('input', validateConfirmPassword);

                    form.addEventListener('submit', function (e) {
                        if (!validateConfirmPassword()) {
                            e.preventDefault();
                            confirmPwd.focus();
                        }
                    });
                })();
            </script>
        </body>

        </html>