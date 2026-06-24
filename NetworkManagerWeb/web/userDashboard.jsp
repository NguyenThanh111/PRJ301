<%-- userDashboard.jsp - Dashboard for USER role Accessible after login when roleID='USER' --%>
    <%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@page import="Models.UserDTO" %>
    <%@page import="Models_DAO.NetworkDeviceDAO" %>
    <%@page import="Models.NetworkDeviceDTO" %>
    <%@page import="Models_DAO.SupportTicketDAO" %>
    <%@page import="Models.SupportTicketDTO" %>
    <%@page import="java.util.ArrayList" %>
    <%@page import="java.text.SimpleDateFormat" %>
    <% 
        UserDTO currentUser = (UserDTO) session.getAttribute("user"); 
        String role = (String) session.getAttribute("role"); 
        if (currentUser==null || role==null || !role.equalsIgnoreCase("Viewer")) {
            session.removeAttribute("user"); 
            session.removeAttribute("role"); 
            response.sendRedirect("login.jsp"); 
            return; 
        } 
        String displayName = currentUser.getFullName() !=null ? currentUser.getFullName() : currentUser.getUserName(); 

        NetworkDeviceDAO deviceDAO = new NetworkDeviceDAO();
        ArrayList<NetworkDeviceDTO> myDevices = deviceDAO.findByOwner(currentUser.getUserName());
        
        SupportTicketDAO ticketDAO = new SupportTicketDAO();
        ArrayList<SupportTicketDTO> myTickets = ticketDAO.findByUser(currentUser.getUserId());
        
        int openTicketsCount = 0;
        for (SupportTicketDTO t : myTickets) {
            if (!"Resolved".equalsIgnoreCase(t.getStatus()) && !"Closed".equalsIgnoreCase(t.getStatus())) {
                openTicketsCount++;
            }
        }
        
        SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy HH:mm");
    %>
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
                            border-radius: 8px;
                            padding: 30px;
                            text-align: center;
                            color: #7f8db4;
                            font-size: 13px;
                            font-style: italic;
                        }

                        /* Notifications UI */
                        .notification-list {
                            display: flex;
                            flex-direction: column;
                            gap: 12px;
                        }
                        .notification-item {
                            display: flex;
                            align-items: flex-start;
                            padding: 16px;
                            background: #0f162b;
                            border-radius: 12px;
                            border: 1px solid var(--border);
                            transition: all 0.2s ease;
                            cursor: pointer;
                        }
                        .notification-item:hover {
                            background: #151e3b;
                            transform: translateY(-2px);
                        }
                        .notification-item.unread {
                            background: rgba(139, 92, 246, 0.05);
                            border-color: rgba(139, 92, 246, 0.3);
                        }
                        .notification-item.unread::before {
                            content: '';
                            position: absolute;
                            width: 8px;
                            height: 8px;
                            background: #8b5cf6;
                            border-radius: 50%;
                            top: 16px;
                            right: 16px;
                        }
                        .notification-item { position: relative; }
                        
                        .notification-icon {
                            width: 40px;
                            height: 40px;
                            border-radius: 50%;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-size: 18px;
                            flex-shrink: 0;
                            margin-right: 16px;
                        }
                        .notification-icon.success { background: rgba(34, 197, 94, 0.15); color: #4ade80; }
                        .notification-icon.warning { background: rgba(245, 158, 11, 0.15); color: #fbbf24; }
                        .notification-icon.info { background: rgba(59, 130, 246, 0.15); color: #60a5fa; }
                        .notification-icon.danger { background: rgba(239, 68, 68, 0.15); color: #f87171; }
                        
                        .notification-content { flex-grow: 1; }
                        .notification-title { font-size: 14px; font-weight: 600; color: #ebedff; margin-bottom: 4px; }
                        .notification-desc { font-size: 13px; color: #9fb0d9; line-height: 1.4; margin-bottom: 6px; }
                        .notification-time { font-size: 11px; color: #637399; font-weight: 500; }

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
                            <%
                                String profileSuccessMessage = (String) session.getAttribute("profileSuccessMessage");
                                String profileErrorMessage = (String) session.getAttribute("profileErrorMessage");
                                if (profileSuccessMessage != null) {
                            %>
                                <div class="alert alert-success alert-dismissible fade show m-3" role="alert">
                                    <%= profileSuccessMessage %>
                                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                </div>
                            <%
                                    session.removeAttribute("profileSuccessMessage");
                                }
                                if (profileErrorMessage != null) {
                            %>
                                <div class="alert alert-danger alert-dismissible fade show m-3" role="alert">
                                    <%= profileErrorMessage %>
                                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                </div>
                            <%
                                    session.removeAttribute("profileErrorMessage");
                                }
                            %>

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
                                            <div class="stat-value"><%= myDevices.size() %></div>
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
                                            <div class="stat-value"><%= openTicketsCount %></div>
                                            <div class="stat-label">Open Tickets</div>
                                            <div class="stat-delta">Support in progress</div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="page-section" id="page-profile">
                                <style>
                                    .profile-mockup {
                                        background: #000000;
                                        border-radius: 20px;
                                        padding: 30px;
                                        width: 100%;
                                        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
                                        color: #fff;
                                        box-shadow: 0 10px 30px rgba(0,0,0,0.4);
                                        border: 1px solid #1c1c1e;
                                    }
                                    .profile-header-desktop {
                                        display: flex;
                                        gap: 50px;
                                        margin-bottom: 30px;
                                        align-items: flex-start;
                                    }
                                    .profile-avatar-container {
                                        flex-shrink: 0;
                                    }
                                    .profile-avatar-lg {
                                        width: 150px;
                                        height: 150px;
                                        border-radius: 50%;
                                        background: linear-gradient(45deg, #f09433 0%, #e6683c 25%, #dc2743 50%, #cc2366 75%, #bc1888 100%);
                                        padding: 4px;
                                    }
                                    .profile-avatar-inner {
                                        width: 100%;
                                        height: 100%;
                                        border-radius: 50%;
                                        background: #000;
                                        border: 4px solid #000;
                                        display: flex;
                                        align-items: center;
                                        justify-content: center;
                                        font-size: 60px;
                                        font-weight: bold;
                                        color: #fff;
                                    }
                                    .profile-details {
                                        flex: 1;
                                    }
                                    .profile-top-row {
                                        display: flex;
                                        align-items: center;
                                        gap: 20px;
                                        margin-bottom: 20px;
                                    }
                                    .profile-username {
                                        font-size: 20px;
                                        font-weight: 500;
                                    }
                                    .profile-stats {
                                        display: flex;
                                        gap: 40px;
                                        margin-bottom: 20px;
                                    }
                                    .stat-item {
                                        font-size: 16px;
                                    }
                                    .stat-item .count {
                                        font-weight: 700;
                                    }
                                    .profile-info {
                                        font-size: 15px;
                                        line-height: 1.5;
                                    }
                                    .profile-info .name {
                                        font-weight: 600;
                                    }
                                    .profile-info .bio {
                                        color: #f5f5f5;
                                    }
                                    .profile-info .link {
                                        color: #e0f2fe;
                                        font-weight: 500;
                                        margin-top: 5px;
                                    }
                                    .btn-ig {
                                        background: #262626;
                                        color: #fff;
                                        border: none;
                                        border-radius: 8px;
                                        padding: 7px 16px;
                                        font-weight: 600;
                                        font-size: 14px;
                                        cursor: pointer;
                                        transition: background 0.2s;
                                    }
                                    .btn-ig:hover { background: #363636; }
                                    .btn-ig.primary { background: #0095f6; }
                                    .btn-ig.primary:hover { background: #1877f2; }
                                    .profile-highlights {
                                        display: flex;
                                        gap: 30px;
                                        margin-bottom: 30px;
                                        padding-left: 20px;
                                    }
                                    .highlight-item {
                                        display: flex;
                                        flex-direction: column;
                                        align-items: center;
                                        gap: 10px;
                                        cursor: pointer;
                                    }
                                    .highlight-circle {
                                        width: 76px;
                                        height: 76px;
                                        border-radius: 50%;
                                        background: #121212;
                                        border: 1px solid #333;
                                        display: flex;
                                        align-items: center;
                                        justify-content: center;
                                        font-size: 28px;
                                        color: #aaa;
                                        padding: 3px;
                                    }
                                    .highlight-circle-inner {
                                        width: 100%;
                                        height: 100%;
                                        border-radius: 50%;
                                        background: #262626;
                                        display: flex;
                                        align-items: center;
                                        justify-content: center;
                                    }
                                    .highlight-label {
                                        font-size: 13px;
                                        font-weight: 600;
                                        color: #f5f5f5;
                                    }
                                    .profile-tabs {
                                        display: flex;
                                        justify-content: center;
                                        gap: 60px;
                                        border-top: 1px solid #262626;
                                    }
                                    .tab-item {
                                        color: #888;
                                        font-size: 13px;
                                        font-weight: 600;
                                        letter-spacing: 1px;
                                        padding: 15px 0;
                                        cursor: pointer;
                                        text-transform: uppercase;
                                        display: flex;
                                        align-items: center;
                                        gap: 6px;
                                    }
                                    .tab-item i { font-size: 14px; }
                                    .tab-item.active {
                                        color: #fff;
                                        border-top: 1px solid #fff;
                                        margin-top: -1px;
                                    }
                                    .profile-grid {
                                        display: grid;
                                        grid-template-columns: repeat(3, 1fr);
                                        gap: 4px;
                                    }
                                    .grid-item {
                                        aspect-ratio: 1;
                                        background: #262626;
                                        display: flex;
                                        align-items: center;
                                        justify-content: center;
                                        font-size: 40px;
                                        color: rgba(255,255,255,0.2);
                                    }
                                    @media (max-width: 768px) {
                                        .profile-header-desktop { flex-direction: column; align-items: center; gap: 20px; }
                                        .profile-details { width: 100%; text-align: center; }
                                        .profile-top-row { flex-direction: column; gap: 15px; }
                                        .profile-stats { justify-content: center; }
                                        .profile-highlights { justify-content: center; padding-left: 0; }
                                    }
                                </style>
                                <div class="profile-mockup">
                                    <div class="profile-header-desktop">
                                        <div class="profile-avatar-container">
                                            <div class="profile-avatar-lg">
                                                <div class="profile-avatar-inner" style="overflow:hidden;">
                                                    <% if (currentUser.getAvatar() != null && !currentUser.getAvatar().isEmpty()) { %>
                                                        <img src="<%= request.getContextPath() %>/<%= currentUser.getAvatar() %>" alt="Avatar" style="width:100%;height:100%;object-fit:cover;">
                                                    <% } else { %>
                                                        <%= currentUser.getFullName() != null && !currentUser.getFullName().isEmpty() ? currentUser.getFullName().substring(0, 1).toUpperCase() : currentUser.getUserName().substring(0, 1).toUpperCase() %>
                                                    <% } %>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="profile-details">
                                            <div class="profile-top-row">
                                                <div class="profile-username"><%= currentUser.getUserName() %></div>
                                                <button class="btn-ig primary" onclick="showPage('editprofile', null)">Edit Profile</button>
                                                <button class="btn-ig" onclick="showPage('mydevices', null)">Devices</button>
                                                <i class="bi bi-gear" style="font-size: 24px; cursor: pointer; color: #fff;" onclick="showPage('changepassword', null)"></i>
                                            </div>
                                            <div class="profile-stats">
                                                <div class="stat-item"><span class="count"><%= myDevices.size() %></span> devices</div>
                                                <div class="stat-item"><span class="count"><%= openTicketsCount %></span> open tickets</div>
                                                <div class="stat-item"><span class="count"><%= myTickets.size() %></span> support tickets</div>
                                            </div>
                                            <div class="profile-info">
                                                <div class="name"><%= currentUser.getFullName() %></div>
                                                <div class="bio">Passionate about reliable networks 🚀<br>Network <%= role %> • <i class="bi bi-envelope"></i> <%= currentUser.getEmail() %></div>
                                                <div class="link">Status: <span style="color:#4ade80;">Active</span></div>
                                            </div>
                                        </div>
                                    </div>
                            
                                    <div class="profile-highlights">
                                        <div class="highlight-item" onclick="showPage('mydevices', null)">
                                            <div class="highlight-circle"><div class="highlight-circle-inner"><i class="bi bi-phone"></i></div></div>
                                            <div class="highlight-label">Devices</div>
                                        </div>
                                        <div class="highlight-item" onclick="showPage('tickets', null)">
                                            <div class="highlight-circle"><div class="highlight-circle-inner"><i class="bi bi-ticket-detailed"></i></div></div>
                                            <div class="highlight-label">Tickets</div>
                                        </div>
                                        <div class="highlight-item" onclick="showPage('changepassword', null)">
                                            <div class="highlight-circle"><div class="highlight-circle-inner"><i class="bi bi-shield-check"></i></div></div>
                                            <div class="highlight-label">Security</div>
                                        </div>
                                        <div class="highlight-item" onclick="showPage('notifications', null)">
                                            <div class="highlight-circle"><div class="highlight-circle-inner"><i class="bi bi-star"></i></div></div>
                                            <div class="highlight-label">Saved</div>
                                        </div>
                                    </div>
                            
                                    <style>
                                        .grid-item-real {
                                            aspect-ratio: 1;
                                            background: #1c1c1e;
                                            display: flex;
                                            flex-direction: column;
                                            align-items: center;
                                            justify-content: center;
                                            color: #fff;
                                            cursor: pointer;
                                            transition: background 0.2s;
                                            text-align: center;
                                            border: 1px solid #2c2c2e;
                                        }
                                        .grid-item-real:hover { background: #2c2c2e; }
                                        .grid-item-real i { font-size: 36px; color: #a5b4fc; }
                                        .grid-item-real .label { font-size: 12px; margin-top: 12px; color: #d8c9ff; padding: 0 10px; word-break: break-all; }
                                    </style>
                                    <div class="profile-tabs">
                                        <div class="tab-item active" id="tab-devices" onclick="switchProfileTab('devices')"><i class="bi bi-grid-3x3"></i> DEVICES</div>
                                        <div class="tab-item" id="tab-tickets" onclick="switchProfileTab('tickets')"><i class="bi bi-ticket-detailed"></i> TICKETS</div>
                                    </div>
                            
                                    <div class="profile-grid" id="grid-devices">
                                        <% if (myDevices.isEmpty()) { %>
                                            <div style="grid-column: 1 / -1; text-align: center; padding: 40px; color: #888;">No devices registered</div>
                                        <% } else {
                                           for (NetworkDeviceDTO dev : myDevices) { %>
                                            <div class="grid-item-real" title="<%= dev.getDeviceName() %>" onclick="showPage('mydevices', null)">
                                                <i class="bi <%= dev.getDeviceType().equalsIgnoreCase("Smartphone") ? "bi-phone" : dev.getDeviceType().equalsIgnoreCase("Laptop") ? "bi-laptop" : "bi-router" %>"></i>
                                                <div class="label" style="max-width: 90%; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;"><%= dev.getDeviceName() %></div>
                                            </div>
                                        <% } } %>
                                    </div>

                                    <div class="profile-grid" id="grid-tickets" style="display: none;">
                                        <% if (myTickets.isEmpty()) { %>
                                            <div style="grid-column: 1 / -1; text-align: center; padding: 40px; color: #888;">No tickets submitted</div>
                                        <% } else {
                                           for (SupportTicketDTO t : myTickets) { %>
                                            <div class="grid-item-real" title="<%= t.getDescription() %>" onclick="showPage('tickets', null)">
                                                <i class="bi bi-ticket-perforated" style="color: <%= "Open".equalsIgnoreCase(t.getStatus()) ? "#f59e0b" : "In Progress".equalsIgnoreCase(t.getStatus()) ? "#60a5fa" : "#4ade80" %>"></i>
                                                <div class="label" style="max-width: 90%; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;"><%= t.getDescription() %></div>
                                            </div>
                                        <% } } %>
                                    </div>
                                    
                                    <script>
                                    function switchProfileTab(tab) {
                                        document.getElementById('tab-devices').classList.remove('active');
                                        document.getElementById('tab-tickets').classList.remove('active');
                                        document.getElementById('grid-devices').style.display = 'none';
                                        document.getElementById('grid-tickets').style.display = 'none';
                                        
                                        document.getElementById('tab-' + tab).classList.add('active');
                                        document.getElementById('grid-' + tab).style.display = 'grid';
                                    }
                                    </script>
                                </div>
                            </div>

                            <div class="page-section" id="page-mydevices">
                                <div class="section-card">
                                    <div class="section-card-header">
                                        <h6><i class="bi bi-phone me-2"></i>My Devices</h6>
                                    </div>
                                    <div class="section-card-body">
                                        <div class="table-responsive">
                                            <table class="table table-borderless table-hover text-white align-middle mb-0" style="font-size:13px;">
                                                <thead style="border-bottom: 1px solid var(--border); color:#7f8db4; text-transform: uppercase; font-size:11px;">
                                                    <tr>
                                                        <th class="pb-2">Device Name</th>
                                                        <th class="pb-2">MAC Address</th>
                                                        <th class="pb-2">IP Address</th>
                                                        <th class="pb-2">Type</th>
                                                        <th class="pb-2">Status</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <% if(myDevices.isEmpty()) { %>
                                                        <tr><td colspan="5" class="text-center py-4" style="color:#7f8db4;">No devices registered to your account.</td></tr>
                                                    <% } else {
                                                        for(NetworkDeviceDTO dev : myDevices) { %>
                                                    <tr>
                                                        <td><strong><%= dev.getDeviceName() %></strong></td>
                                                        <td style="font-family:monospace; color:#a5b4fc;"><%= dev.getMacAddress() %></td>
                                                        <td style="font-family:monospace; color:#86efac;"><%= dev.getIpAddress() %></td>
                                                        <td style="color:#d8c9ff;"><%= dev.getDeviceType() %></td>
                                                        <td>
                                                            <% if("ALLOWED".equalsIgnoreCase(dev.getStatus())) { %>
                                                                <span class="badge" style="background:rgba(34,197,94,0.16);color:#4ade80;font-weight:500;">Allowed</span>
                                                            <% } else { %>
                                                                <span class="badge" style="background:rgba(239,68,68,0.16);color:#f87171;font-weight:500;">Blocked</span>
                                                            <% } %>
                                                        </td>
                                                    </tr>
                                                    <%  }
                                                    } %>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="page-section" id="page-notifications">
                                <div class="section-card">
                                    <div class="section-card-header">
                                        <h6><i class="bi bi-bell me-2"></i>Notifications</h6>
                                        <button class="btn btn-sm btn-outline-secondary" style="font-size:12px; border-color:var(--border); color:#9fb0d9;">Mark all as read</button>
                                    </div>
                                    <div class="section-card-body" style="padding: 20px;">
                                        <div class="notification-list">
                                            <div class="notification-item unread">
                                                <div class="notification-icon success"><i class="bi bi-check-circle-fill"></i></div>
                                                <div class="notification-content">
                                                    <div class="notification-title">Thiết bị được phê duyệt</div>
                                                    <div class="notification-desc">Thiết bị <strong>Laptop ROG</strong> của bạn đã được quản trị viên cấp quyền truy cập vào mạng WiFi sinh viên.</div>
                                                    <div class="notification-time">2 phút trước</div>
                                                </div>
                                            </div>
                                            
                                            <div class="notification-item unread">
                                                <div class="notification-icon warning"><i class="bi bi-ticket-detailed-fill"></i></div>
                                                <div class="notification-content">
                                                    <div class="notification-title">Cập nhật Ticket #17</div>
                                                    <div class="notification-desc">Vé hỗ trợ <em>"Mất kết nối WiFi toàn bộ khu vực"</em> đã được chuyển trạng thái sang <strong>In Progress (Đang xử lý)</strong>.</div>
                                                    <div class="notification-time">1 giờ trước</div>
                                                </div>
                                            </div>

                                            <div class="notification-item">
                                                <div class="notification-icon info"><i class="bi bi-info-circle-fill"></i></div>
                                                <div class="notification-content">
                                                    <div class="notification-title">Thông báo bảo trì hệ thống</div>
                                                    <div class="notification-desc">Toàn bộ hệ thống mạng khu vực Tòa nhà A101 sẽ được bảo trì định kỳ từ 23:00 đến 01:00 rạng sáng mai. Vui lòng lưu ý.</div>
                                                    <div class="notification-time">Hôm qua lúc 15:30</div>
                                                </div>
                                            </div>

                                            <div class="notification-item">
                                                <div class="notification-icon danger"><i class="bi bi-shield-lock-fill"></i></div>
                                                <div class="notification-content">
                                                    <div class="notification-title">Cảnh báo bảo mật</div>
                                                    <div class="notification-desc">Phát hiện đăng nhập lạ vào tài khoản của bạn từ địa chỉ IP: 192.168.1.99. Hãy thay đổi mật khẩu ngay lập tức nếu đây không phải là bạn.</div>
                                                    <div class="notification-time">3 ngày trước</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="page-section" id="page-tickets">
                                <div class="section-card">
                                    <div class="section-card-header">
                                        <h6><i class="bi bi-ticket-perforated me-2"></i>My Tickets</h6>
                                    </div>
                                    <div class="section-card-body">
                                        <div class="table-responsive">
                                            <table class="table table-borderless table-hover text-white align-middle mb-0" style="font-size:13px;">
                                                <thead style="border-bottom: 1px solid var(--border); color:#7f8db4; text-transform: uppercase; font-size:11px;">
                                                    <tr>
                                                        <th class="pb-2">Ticket ID</th>
                                                        <th class="pb-2">Issue Description</th>
                                                        <th class="pb-2">Status</th>
                                                        <th class="pb-2">Created Date</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <% if(myTickets.isEmpty()) { %>
                                                        <tr><td colspan="4" class="text-center py-4" style="color:#7f8db4;">You haven't submitted any tickets.</td></tr>
                                                    <% } else {
                                                        for(SupportTicketDTO t : myTickets) { %>
                                                    <tr>
                                                        <td style="font-family:monospace; color:#9db0db;">#<%= t.getTicketId() %></td>
                                                        <td style="max-width: 300px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" title="<%= t.getDescription() %>"><strong><%= t.getDescription() %></strong></td>
                                                        <td>
                                                            <% if("Open".equalsIgnoreCase(t.getStatus())) { %>
                                                                <span class="badge" style="background:rgba(245,158,11,0.16);color:#f59e0b;font-weight:500;">Open</span>
                                                            <% } else if("In Progress".equalsIgnoreCase(t.getStatus())) { %>
                                                                <span class="badge" style="background:rgba(96,165,250,0.16);color:#60a5fa;font-weight:500;">In Progress</span>
                                                            <% } else { %>
                                                                <span class="badge" style="background:rgba(34,197,94,0.16);color:#4ade80;font-weight:500;"><%= t.getStatus() %></span>
                                                            <% } %>
                                                        </td>
                                                        <td style="color:#a5b4fc;"><%= t.getCreatedDate() != null ? sdf.format(t.getCreatedDate()) : "N/A" %></td>
                                                    </tr>
                                                    <%  }
                                                    } %>
                                                </tbody>
                                            </table>
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
                                        <form action="TicketServlet" method="POST" style="max-width:500px;">
                                            <input type="hidden" name="action" value="create">
                                            <div class="mb-3">
                                                <label class="form-label" style="font-size:12px;color:#9fb0d8;">Describe your issue</label>
                                                <textarea name="issueDescription" class="form-control" rows="4" required style="background:#0f162b;border-color:var(--border);color:#e7ecff;resize:none;" placeholder="E.g., I cannot connect to the campus WiFi from my dorm room..."></textarea>
                                            </div>
                                            <button type="submit" class="btn-theme" style="display:inline-flex;align-items:center;transition:all 0.2s;box-shadow: 0 4px 12px rgba(139,92,246,0.3);"><i class="bi bi-send me-2"></i> Submit Ticket</button>
                                        </form>
                                    </div>
                                </div>
                            </div>

                            <div class="page-section" id="page-editprofile">
                                <div class="section-card">
                                    <div class="section-card-header">
                                        <h6><i class="bi bi-person-badge me-2"></i>Edit Profile</h6>
                                    </div>
                                    <div class="section-card-body">
                                        <form action="UpdateProfileController" method="POST" enctype="multipart/form-data" style="max-width:500px;">
                                            <div class="mb-3">
                                                <label class="form-label" style="font-size:12px;color:#9fb0d8;">Full Name</label>
                                                <input type="text" name="fullName" class="form-control"
                                                    style="background:#0f162b;border-color:var(--border);color:#e7ecff;"
                                                    value="<%= currentUser.getFullName() %>" required>
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label" style="font-size:12px;color:#9fb0d8;">Avatar (Image)</label>
                                                <input type="file" name="avatar" accept="image/*" class="form-control"
                                                    style="background:#0f162b;border-color:var(--border);color:#e7ecff;">
                                            </div>
                                            <button type="submit" class="btn-theme"><i class="bi bi-save me-1"></i>Save Profile</button>
                                        </form>
                                    </div>
                                </div>
                            </div>

                            <div class="page-section" id="page-changepassword">
                                <div class="section-card">
                                    <div class="section-card-header">
                                        <h6><i class="bi bi-key me-2"></i>Change Password</h6>
                                    </div>
                                    <div class="section-card-body">
                                        <form style="max-width:500px;">
                                            <div class="mb-3">
                                                <label class="form-label" style="font-size:12px;color:#9fb0d8;">Current Password</label>
                                                <input type="password" class="form-control"
                                                    style="background:#0f162b;border-color:var(--border);color:#e7ecff;"
                                                    placeholder="Enter current password">
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label" style="font-size:12px;color:#9fb0d8;">New Password</label>
                                                <input type="password" class="form-control"
                                                    style="background:#0f162b;border-color:var(--border);color:#e7ecff;"
                                                    placeholder="Enter new password">
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label" style="font-size:12px;color:#9fb0d8;">Confirm New Password</label>
                                                <input type="password" class="form-control"
                                                    style="background:#0f162b;border-color:var(--border);color:#e7ecff;"
                                                    placeholder="Confirm new password">
                                            </div>
                                            <button type="button" class="btn-theme" onclick="alert('Password change logic goes here!')"><i class="bi bi-check2-circle me-1"></i>Update Password</button>
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
                            'changepassword': ['Settings', '/ Security'],
                            'editprofile': ['Edit Profile', '/ Account']
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
