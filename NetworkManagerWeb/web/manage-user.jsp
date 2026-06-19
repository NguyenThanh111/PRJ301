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
                    <title>Network Manager — Staff Dashboard</title>
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
                                        <% if (isAdmin) { %>
                                            <div class="page-section active" id="page-users">
                                                <div class="section-card">
                                                    <div class="section-card-header">
                                                        <h6><i class="bi bi-people me-2"></i>User Management</h6>
                                                        <div class="d-flex align-items-center gap-2">
                                                            <div class="pagination-controls">
                                                                <button class="page-btn" onclick="prevPage('users-table')" id="users-table-prev"><i class="bi bi-chevron-left"></i></button>
                                                                <span class="page-info" id="users-table-page-info">Page 1 of 1</span>
                                                                <button class="page-btn" onclick="nextPage('users-table')" id="users-table-next"><i class="bi bi-chevron-right"></i></button>
                                                            </div>
                                                            <button class="btn-theme" data-bs-toggle="modal" data-bs-target="#addUserModal"><i class="bi bi-person-plus me-1"></i>Add User</button>
                                                        </div>
                                                    </div>
                                                    <div class="section-card-body">
                                                        <div class="d-flex justify-content-between mb-3">
                                                            <form action="UserController" method="GET" class="d-flex align-items-center gap-2">
                                                                <input type="hidden" name="action" value="search">
                                                                <input type="text" name="keyword" class="form-control-dark" placeholder="Search by name, email..." value="${keyword}">
                                                                <button type="submit" class="btn-theme"><i class="bi bi-search me-1"></i>Search</button>
                                                                <c:if test="${not empty keyword}">
                                                                    <a href="UserController?action=list" class="btn btn-sm btn-outline-secondary" style="border-color: var(--border); color: #a5b2d8;">Clear</a>
                                                                </c:if>
                                                            </form>
                                                        </div>
                                                        <div class="table-responsive">
                                                            <table class="table-dark-custom" id="users-table">
                                                                <thead>
                                                                    <tr>
                                                                        <th>ID</th>
                                                                        <th>Username</th>
                                                                        <th>Full Name</th>
                                                                        <th>Email</th>
                                                                        <th>Role</th>
                                                                        <th>Status</th>
                                                                        <th>Actions</th>
                                                                    </tr>
                                                                </thead>
                                                                <tbody>
                                                                    <c:choose>
                                                                        <c:when test="${not empty userList}">
                                                                            <c:forEach var="user" items="${userList}">
                                                                                <tr>
                                                                                    <td>${user.userId}</td>
                                                                                    <td>${user.userName}</td>
                                                                                    <td>${user.fullName}</td>
                                                                                    <td>${user.email}</td>
                                                                                    <td>${roleMap[user.userId]}</td>
                                                                                    <td>
                                                                                        <span class="${user.active ? 'badge-status-active' : 'badge-status-inactive'}">
                                                                                            ${user.status}
                                                                                        </span>
                                                                                    </td>
                                                                                    <td>
                                                                                        <c:if test="${roleMap[user.userId] ne 'Admin'}">
                                                                                        <button type="button" class="btn-theme me-1" style="border-color: rgba(245, 158, 11, 0.5); background: rgba(245, 158, 11, 0.2); color: #fde68a; padding: 4px 8px; font-size: 11px;" data-bs-toggle="modal" data-bs-target="#editUserModal"
                                                                                                data-id="${user.userId}" data-username="${user.userName}" data-fullname="${user.fullName}" 
                                                                                                data-email="${user.email}" data-password="${user.password}" data-status="${user.active}" data-role="${roleMap[user.userId]}">
                                                                                            <i class="bi bi-pencil-square"></i> Edit
                                                                                        </button>
                                                                                        <form action="UserController" method="POST" style="display:inline;" onsubmit="return confirm('Are you sure you want to delete this user?');">
                                                                                            <input type="hidden" name="action" value="delete">
                                                                                            <input type="hidden" name="userId" value="${user.userId}">
                                                                                            <button type="submit" class="btn-theme" style="border-color: rgba(239, 68, 68, 0.5); background: rgba(239, 68, 68, 0.2); color: #fecaca; padding: 4px 8px; font-size: 11px;">
                                                                                                <i class="bi bi-trash"></i> Delete
                                                                                            </button>
                                                                                        </form>
                                                                                        </c:if>
                                                                                    </td>
                                                                                </tr>
                                                                            </c:forEach>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <tr><td colspan="7" class="text-center" style="color: var(--text-muted); padding: 30px;">No users found. Please use the Add User button.</td></tr>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </tbody>
                                                            </table>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>


                                            <% } %>
                        </div>
                    </div>

    <!-- Modals for User Management -->
    <!-- Add User Modal -->
    <div class="modal fade" id="addUserModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content modal-content-dark">
                <form action="UserController" method="POST">
                    <input type="hidden" name="action" value="add">
                    <div class="modal-header modal-header-dark">
                        <h5 class="modal-title">Add New User</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label" style="color: var(--text-muted); font-size: 13px;">Username</label>
                            <input type="text" name="username" class="form-control-dark w-100" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label" style="color: var(--text-muted); font-size: 13px;">Password</label>
                            <input type="password" name="password" class="form-control-dark w-100" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label" style="color: var(--text-muted); font-size: 13px;">Full Name</label>
                            <input type="text" name="fullName" class="form-control-dark w-100" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label" style="color: var(--text-muted); font-size: 13px;">Email</label>
                            <input type="email" name="email" class="form-control-dark w-100" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label" style="color: var(--text-muted); font-size: 13px;">Role</label>
                            <select name="roleId" class="form-control-dark w-100" required>
                                <option value="">-- Select Role --</option>
                                <c:forEach var="role" items="${roleList}">
                                    <option value="${role.roleId}">${role.roleName}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer modal-footer-dark">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn-theme" style="background: rgba(74, 222, 128, 0.2); border-color: rgba(74, 222, 128, 0.5); color: #4ade80;">Save User</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Edit User Modal -->
    <div class="modal fade" id="editUserModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content modal-content-dark">
                <form action="UserController" method="POST">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="userId" id="edit-id">
                    <div class="modal-header modal-header-dark">
                        <h5 class="modal-title">Edit User</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label" style="color: var(--text-muted); font-size: 13px;">Username</label>
                            <input type="text" name="username" id="edit-username" class="form-control-dark w-100" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label" style="color: var(--text-muted); font-size: 13px;">Password</label>
                            <input type="text" name="password" id="edit-password" class="form-control-dark w-100" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label" style="color: var(--text-muted); font-size: 13px;">Full Name</label>
                            <input type="text" name="fullName" id="edit-fullname" class="form-control-dark w-100" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label" style="color: var(--text-muted); font-size: 13px;">Email</label>
                            <input type="email" name="email" id="edit-email" class="form-control-dark w-100" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label" style="color: var(--text-muted); font-size: 13px;">Role</label>
                            <select name="roleId" id="edit-role" class="form-control-dark w-100">
                                <option value="">-- Select Role --</option>
                                <c:forEach var="role" items="${roleList}">
                                    <option value="${role.roleId}">${role.roleName}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="form-check mt-2">
                            <input class="form-check-input" type="checkbox" name="status" id="edit-status" value="true">
                            <label class="form-check-label" for="edit-status" style="color: var(--text-primary); font-size: 13px;">
                                Active Status
                            </label>
                        </div>
                    </div>
                    <div class="modal-footer modal-footer-dark">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn-theme" style="background: rgba(245, 158, 11, 0.2); border-color: rgba(245, 158, 11, 0.5); color: #fde68a;">Update User</button>
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



                        // Pagination
                        const PAGE_SIZE = 10;
                        const paginationState = {};

                        function initPagination(tableId) {
                            const tbody = document.querySelector('#' + tableId + ' tbody');
                            if (!tbody) return;
                            const rows = Array.from(tbody.querySelectorAll('tr'));
                            const total = Math.max(1, Math.ceil(rows.length / PAGE_SIZE));
                            paginationState[tableId] = { current: 1, total: total, rows: rows };
                            showPageForTable(tableId);
                        }

                        function showPageForTable(tableId) {
                            const state = paginationState[tableId];
                            if (!state) return;
                            const start = (state.current - 1) * PAGE_SIZE;
                            const end = start + PAGE_SIZE;
                            state.rows.forEach(function(r, i) {
                                r.style.display = (i >= start && i < end) ? '' : 'none';
                            });
                            document.getElementById(tableId + '-page-info').textContent = 'Page ' + state.current + ' of ' + state.total;
                            document.getElementById(tableId + '-prev').disabled = state.current <= 1;
                            document.getElementById(tableId + '-next').disabled = state.current >= state.total;
                        }

                        function prevPage(tableId) {
                            const state = paginationState[tableId];
                            if (state && state.current > 1) { state.current--; showPageForTable(tableId); }
                        }

                        function nextPage(tableId) {
                            const state = paginationState[tableId];
                            if (state && state.current < state.total) { state.current++; showPageForTable(tableId); }
                        }

                        // Populate Edit User Modal
                            document.addEventListener('DOMContentLoaded', function() {
                            initPagination('users-table');
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