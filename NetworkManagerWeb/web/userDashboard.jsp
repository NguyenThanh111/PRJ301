<%-- userDashboard.jsp - Dashboard for USER role Accessible after login when roleID='USER' --%>
    <%@page contentType="text/html" pageEncoding="UTF-8" %>
        <%@page import="Models.UserDTO" %>
            <% UserDTO currentUser=(UserDTO) session.getAttribute("user"); String role=(String)
                session.getAttribute("role"); if (currentUser==null || role==null || !role.equalsIgnoreCase("Viewer")) {
                session.removeAttribute("user"); session.removeAttribute("role"); response.sendRedirect("login.jsp"); return; } String displayName=currentUser.getFullName() !=null ?
                currentUser.getFullName() : currentUser.getUserName(); %>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Network Manager — My Dashboard</title>
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
                            --sidebar-w: 250px;
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
                                linear-gradient(rgba(5, 8, 18, 0.84), rgba(6, 9, 20, 0.8)),
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

                        .role-badge-viewer {
                            border-radius: 999px;
                            padding: 4px 10px;
                            font-size: 11px;
                            letter-spacing: .08em;
                            text-transform: uppercase;
                            font-weight: 700;
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

                        <div class="sidebar-section-label">Account</div>
                        <button class="nav-item-link" onclick="showPage('profile', this)">
                            <i class="bi bi-person"></i> My Profile
                        </button>
                        <button class="nav-item-link" onclick="showPage('mydevices', this)">
                            <i class="bi bi-phone"></i> My Devices
                        </button>
                        <button class="nav-item-link" onclick="showPage('notifications', this)">
                            <i class="bi bi-bell"></i> Notifications
                        </button>
                        <a class="nav-item-link text-decoration-none" href="<%= request.getContextPath() %>/payment/checkout">
                            <i class="bi bi-credit-card"></i> Thanh toán VNPAY
                        </a>

                        <div class="sidebar-section-label">Support</div>
                        <button class="nav-item-link" onclick="showPage('tickets', this)">
                            <i class="bi bi-ticket-perforated"></i> My Tickets
                        </button>
                        <button class="nav-item-link" onclick="showPage('createticket', this)">
                            <i class="bi bi-plus-circle"></i> Create Ticket
                        </button>

                        <div class="sidebar-section-label">Settings</div>
                        <button class="nav-item-link" onclick="showPage('changepassword', this)">
                            <i class="bi bi-key"></i> Change Password
                        </button>

                        <div class="sidebar-footer">
                            <div class="d-flex align-items-center gap-2 mb-2">
                                <div class="user-avatar">
                                    <%= displayName.charAt(0) %>
                                </div>
                                <div>
                                    <div style="font-size:13px;font-weight:600;color:#e8ecff;">
                                        <%= displayName %>
                                    </div>
                                    <div style="font-size:11px;color:#8ea0cb;">
                                        <%= role %>
                                    </div>
                                </div>
                            </div>
                            <a href="LoginController?action=logout" class="nav-item-link text-danger"
                                style="padding-left:0;">
                                <i class="bi bi-box-arrow-left"></i> Sign Out
                            </a>
                        </div>
                    </nav>

                    <div class="main-content">
                        <div class="topbar">
                            <div>
                                <span class="topbar-title" id="pageTitle">Dashboard</span>
                                <span class="topbar-breadcrumb" id="pageBreadcrumb">/ Overview</span>
                            </div>
                            <div class="d-flex align-items-center gap-2">
                                <a class="premium-btn" href="<%= request.getContextPath() %>/payment/checkout">
                                    <i class="bi bi-gem"></i> Premium
                                </a>
                                <span class="role-badge-viewer">
                                    <%= role %>
                                </span>
                                <span style="font-size:13px;color:#9db0db;">Welcome, <strong style="color:#f2f5ff;">
                                        <%= displayName %>
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
                                                    class="bi bi-wifi"></i></div>
                                            <div class="stat-value" style="color:#4ade80;">Good</div>
                                            <div class="stat-label">WiFi Status</div>
                                            <div class="stat-delta">Campus network stable</div>
                                        </div>
                                    </div>
                                    <div class="col-6 col-md-3">
                                        <div class="stat-card">
                                            <div class="stat-icon"
                                                style="background:rgba(96,165,250,0.16);color:#60a5fa;"><i
                                                    class="bi bi-phone"></i></div>
                                            <div class="stat-value">2</div>
                                            <div class="stat-label">My Devices</div>
                                            <div class="stat-delta">Connected to account</div>
                                        </div>
                                    </div>
                                    <div class="col-6 col-md-3">
                                        <div class="stat-card">
                                            <div class="stat-icon"
                                                style="background:rgba(245,158,11,0.16);color:#f59e0b;"><i
                                                    class="bi bi-bell"></i></div>
                                            <div class="stat-value">3</div>
                                            <div class="stat-label">Notifications</div>
                                            <div class="stat-delta">Unread updates</div>
                                        </div>
                                    </div>
                                    <div class="col-6 col-md-3">
                                        <div class="stat-card">
                                            <div class="stat-icon"
                                                style="background:rgba(139,92,246,0.16);color:#c4b5fd;"><i
                                                    class="bi bi-ticket-perforated"></i></div>
                                            <div class="stat-value">1</div>
                                            <div class="stat-label">Open Tickets</div>
                                            <div class="stat-delta">Support in progress</div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="page-section" id="page-profile">
                                <div class="section-card">
                                    <div class="section-card-header">
                                        <h6><i class="bi bi-person me-2"></i>My Profile</h6>
                                    </div>
                                    <div class="section-card-body">
                                        <div class="placeholder-box">
                                            Profile details will appear here<br>
                                            <small>Name, email, role, account status</small>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="page-section" id="page-mydevices">
                                <div class="section-card">
                                    <div class="section-card-header">
                                        <h6><i class="bi bi-phone me-2"></i>My Devices</h6>
                                    </div>
                                    <div class="section-card-body">
                                        <div class="placeholder-box">
                                            Registered devices list will appear here<br>
                                            <small>Device name, MAC, IP, last seen</small>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="page-section" id="page-notifications">
                                <div class="section-card">
                                    <div class="section-card-header">
                                        <h6><i class="bi bi-bell me-2"></i>Notifications</h6>
                                    </div>
                                    <div class="section-card-body">
                                        <div class="placeholder-box">Your notifications feed will appear here</div>
                                    </div>
                                </div>
                            </div>

                            <div class="page-section" id="page-tickets">
                                <div class="section-card">
                                    <div class="section-card-header">
                                        <h6><i class="bi bi-ticket-perforated me-2"></i>My Tickets</h6>
                                    </div>
                                    <div class="section-card-body">
                                        <div class="placeholder-box">
                                            Your support tickets will appear here<br>
                                            <small>Ticket ID, status, response time</small>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="page-section" id="page-createticket">
                                <div class="section-card">
                                    <div class="section-card-header">
                                        <h6><i class="bi bi-plus-circle me-2"></i>Create Ticket</h6>
                                    </div>
                                    <div class="section-card-body">
                                        <div class="placeholder-box">
                                            Ticket creation form will appear here<br>
                                            <small>Issue type, description, priority</small>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="page-section" id="page-changepassword">
                                <div class="section-card">
                                    <div class="section-card-header">
                                        <h6><i class="bi bi-key me-2"></i>Change Password</h6>
                                    </div>
                                    <div class="section-card-body">
                                        <form style="max-width:420px;">
                                            <div class="mb-3">
                                                <label class="form-label" style="font-size:12px;color:#9fb0d8;">Current
                                                    Password</label>
                                                <input type="password" class="form-control"
                                                    style="background:#0f162b;border-color:var(--border);color:#e7ecff;"
                                                    placeholder="Enter current password">
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label" style="font-size:12px;color:#9fb0d8;">New
                                                    Password</label>
                                                <input type="password" class="form-control"
                                                    style="background:#0f162b;border-color:var(--border);color:#e7ecff;"
                                                    placeholder="Enter new password">
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label" style="font-size:12px;color:#9fb0d8;">Confirm
                                                    New Password</label>
                                                <input type="password" class="form-control"
                                                    style="background:#0f162b;border-color:var(--border);color:#e7ecff;"
                                                    placeholder="Confirm new password">
                                            </div>
                                            <button type="submit" class="btn-theme"><i
                                                    class="bi bi-check2-circle me-1"></i>Update Password</button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
                    <script>
                        const pageTitles = {
                            'dashboard': ['Dashboard', '/ Overview'],
                            'profile': ['My Profile', '/ Account'],
                            'mydevices': ['My Devices', '/ Account'],
                            'notifications': ['Notifications', '/ Account'],
                            'tickets': ['My Tickets', '/ Support'],
                            'createticket': ['Create Ticket', '/ Support'],
                            'changepassword': ['Change Password', '/ Settings']
                        };

                        function showPage(pageId, triggerEl) {
                            document.querySelectorAll('.page-section').forEach(s => s.classList.remove('active'));
                            document.querySelectorAll('.nav-item-link').forEach(b => b.classList.remove('active'));
                            const section = document.getElementById('page-' + pageId);
                            if (section) section.classList.add('active');
                            if (triggerEl) triggerEl.classList.add('active');
                            const [title, crumb] = pageTitles[pageId] || ['Dashboard', '/ Overview'];
                            document.getElementById('pageTitle').textContent = title;
                            document.getElementById('pageBreadcrumb').textContent = crumb;
                        }
                    </script>
                </body>

                </html>
