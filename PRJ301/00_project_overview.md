---
title: "Project Overview — University Network Management System"
tags: [prj301, planning, overview]
created: 2026-05-26
updated: 2026-06-17
---

# Project Overview — University Network Management System

## 1. Project Information

| Item | Detail |
|---|---|
| **Course** | PRJ301 — Java Web Application Development |
| **Topic** | University Network Management System (Quan ly he thong mang trong truong dai hoc) |
| **Team** | 4 members — Member A, Member B, Member C, Member D |
| **Semester** | Spring 2026 |

---

## 2. System Description

This web application helps university IT staff manage and monitor the campus network infrastructure. It provides a centralized dashboard to track routers, access points, switches, and end-user devices across buildings and floors.

**Who uses the system?**

| Role | Description |
|---|---|
| **Admin** | Full control — manage users, assign roles, configure all devices |
| **Technician** | Handle maintenance tasks, resolve support tickets, update device status |
| **Viewer** | Read-only access — view dashboards, reports, and network status |

> ⚠️ Roles are **not** stored as a field on `User`. They are managed through the `UserRole` junction table (M:N relationship between `User` and `Role`). Every role check must use `SessionUtil.hasRole()`, not `user.getRole()`.

**What does it do?**

- Authenticate users with role-based access control (Admin / Technician / Viewer)
- Manage network devices: Routers, Access Points, Switches, and end-user devices
- Monitor bandwidth usage and WiFi analytics
- Manage VLANs, IP address allocation, and room infrastructure
- Track network alerts and support tickets
- Schedule maintenance windows
- Generate activity and performance reports

---

## 3. Tech Stack

| Component | Technology |
|---|---|
| IDE | NetBeans 13 |
| JDK | JDK 8 (Java 1.8) |
| Server | Apache Tomcat 9 |
| Backend | Java Servlet + JSP (`javax.servlet.*`) |
| Architecture | MVC-V2 with FrontController (DispatcherServlet) |
| Build Tool | Ant (NetBeans default) |
| **Database** | **SQL Server** (không dùng MySQL) |
| **JDBC Driver** | `mssql-jdbc-12.x.x.jre8.jar` (Microsoft JDBC Driver for SQL Server) |
| View Layer | JSP + JSTL 1.2 + EL |
| Security | BCrypt (jBCrypt) cho mã hoá mật khẩu, Google OAuth2 cho đăng nhập Google |
| Email | JavaMail API (Jakarta Mail) |
| Project Name | `NetworkSimulationManagement` |
| DB Name | `network_simulation_db` |

> [!warning]
> - Dùng **Tomcat 9**, không dùng Tomcat 10+ (Tomcat 10 dùng `jakarta.servlet.*` không tương thích).
> - Database là **SQL Server**, không phải MySQL. Dùng T-SQL (`IDENTITY`, `GETDATE()`, `NVARCHAR`, `GO`).
> - Tên database trong `Network2.sql` hiện là `network_simulation_db3` — cần đổi thành `network_simulation_db` trước khi chạy chung.
> - Các bảng `[User]` và `[Switch]` phải viết trong ngoặc vuông khi truy vấn SQL Server.

---

## 4. Database Summary

Schema theo `Network2.sql` gồm **20 bảng**: 16 bảng chính + 4 bảng junction.

| Nhóm | Bảng |
|---|---|
| Auth & Logging | `[User]`, `Role`, `UserRole`*, `AuthenticationLog`, `SystemLog` |
| Core Devices | `Router`, `AccessPoint`, `[Switch]`, `NetworkDevice` |
| Infrastructure & Support | `Room`, `VLAN`, `IPAddressManagement`, `SupportTicket` |
| Monitoring | `BandwidthUsage`, `WiFiAnalytics`, `NetworkAlert` |
| Maintenance | `MaintenanceSchedule`, `MaintenanceRouter`*, `MaintenanceAccessPoint`*, `MaintenanceSwitch`* |

*Bảng junction (composite PK, không có auto-increment ID riêng)

---

## 5. Architecture Overview (MVC-V2)

Đề bài PDF **yêu cầu bắt buộc** kiến trúc MVC-V2 với FrontController — đây là 2/8 điểm back-end.

```text
Browser
  → FrontController (DispatcherServlet) — điều phối toàn bộ request
      → Session / Role Check (SessionUtil + AuthFilter)
          → Action Handler (trong từng Servlet hoặc Command class)
              → DAO Layer (SQL Server via JDBC)
              ← DTO / List
          ← setAttribute
      → JSP View (JSTL + EL, không scriptlet lớn)
  ← HTML Response
```

**Yêu cầu bắt buộc từ đề bài:**
- FrontController / DispatcherServlet — điều phối request
- DAO/Service layer riêng biệt — không viết SQL trong Servlet/JSP
- Filter: AuthenticationFilter, AuthorizationFilter, EncodingFilter
- BCrypt cho mã hoá mật khẩu
- Google OAuth2 cho đăng nhập Google
- JavaMail: gửi email xác nhận, reset mật khẩu

---

## 6. Computational Thinking Overview

### 6.1 Decomposition

We break the system into **5 major subsystems**:

1. **Authentication & Authorization** — Login, role management, session handling
2. **Device Management** — CRUD for Routers, APs, Switches, and end-user devices
3. **Network Monitoring** — Bandwidth tracking, WiFi analytics, alerts
4. **Infrastructure Management** — Rooms, VLANs, IP addresses
5. **Support & Maintenance** — Support tickets, maintenance schedules, system logs

### 6.2 Pattern Recognition

Nearly every feature follows the same **CRUD pattern**:

```text
JSP Form  →  Servlet Controller  →  DAO  →  SQL Server  →  Servlet  →  JSP List
```

Recognized repeating structures:
- Every model has `insert()`, `update()`, `delete()`, `findAll()` methods
- Status fields appear in Users, Routers, APs, Switches, Devices, Tickets, Maintenance
- Date/time tracking is consistent: `createdAt`, `loginTime`, `recordTime`, etc.
- Role-based filtering applies across all list views

### 6.3 Abstraction

| Layer | Responsibility | Examples |
|---|---|---|
| **Presentation** (JSP) | Display data, accept input | `login.jsp`, `router/list.jsp` |
| **Controller** (Servlet) | Handle HTTP, route logic | `DispatcherServlet`, `RouterServlet` |
| **Data Access** (DAO) | SQL Server operations via JDBC | `UserDAO`, `RouterDAO` |
| **Data Transfer** (DTO) | Carry data between layers | `User`, `Router`, `BandwidthUsage` |
| **Utility** | Shared helpers | `DBContext`, `SessionUtil` |

### 6.4 Algorithm Design

Key algorithms in the system:

1. **Login Flow** — Validate credentials → BCrypt verify → load roles from UserRole → create session → redirect by role → log to AuthenticationLog
2. **Device Block/Unblock** — Find device by MAC → update status → log action to SystemLog → alert if needed
3. **Alert Trigger** — Monitor device status → detect anomaly → create alert with router_id/ap_id/switch_id → notify dashboard
4. **Support Ticket Lifecycle** — Submit (created_by = current userId) → update status → resolve → close

---

## 7. Related Documents

| Document | Description |
|---|---|
| `01_CT_analysis.md` | Full Computational Thinking breakdown |
| `02_erd_database.md` | ERD diagram and SQL scripts (SQL Server) |
| `03_team_assignment_updated.md` | Member assignments and sprint plan |
| `04_system_architecture.md` | Architecture layers and folder structure |
| `05_feature_list.md` | Feature list grouped by role |
| `06_report_template.md` | Vietnamese-language report outline |
| `07_coding_guide.md` | Step-by-step coding guide with examples |
| `Network2.sql` | **Nguồn sự thật duy nhất** cho schema — luôn đối chiếu file này |

---

> [!tip]
> Bắt đầu với `03_team_assignment_updated.md` để biết ai làm gì, sau đó đọc `07_coding_guide.md` để xem cách implement một model từ đầu đến cuối. Luôn đối chiếu `Network2.sql` khi có nghi ngờ về schema.
