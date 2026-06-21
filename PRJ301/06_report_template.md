---
title: "Bao cao do an - Mau bao cao Tieng Viet (Da cap nhat SQL Server)"
tags: [prj301, planning, report, vietnamese]
created: 2026-05-26
updated: 2026-06-17
---

# Mau Bao Cao Do An PRJ301

> Day la mau bao cao cho do an PRJ301: **He thong Quan ly Mang trong Truong Dai hoc**.
> **Da cap nhat day du theo `Network2.sql`:** SQL Server, 20 bang, FrontController MVC-V2, BCrypt, Google OAuth2, JavaMail.

---

## Trang bia

```text
TRUONG DAI HOC ............
KHOA CONG NGHE THONG TIN

BAO CAO DO AN
MON: PRJ301 - Lap trinh Web voi Java

TEN DE TAI: He thong Quan ly Mang trong Truong Dai hoc
            (University Network Management System)

Giang vien huong dan: ................................
Sinh vien thuc hien:
  - Sinh vien A: ................................ (Member A)
  - Sinh vien B: ................................ (Member B)
  - Sinh vien C: ................................ (Member C)
  - Sinh vien D: ................................ (Member D)

Nam hoc: 2025-2026
```

---

## Loi cam on

Cam on giang vien huong dan, nha truong, khoa, va cac thanh vien trong nhom da ho tro trong qua trinh thuc hien do an.

---

## Muc luc

Tao muc luc tu dong trong Word bang Heading 1, Heading 2, Heading 3.

---

## Chuong 1: Gioi thieu de tai

### 1.1 Dat van de

Trong moi truong truong dai hoc, he thong mang la nen tang quan trong cho hoat dong giang day, nghien cuu va quan ly. Neu viec quan ly thiet bi, phong may, dia chi IP, canh bao va bao tri duoc thuc hien thu cong, nha truong se kho theo doi tinh trang he thong va xu ly su co kip thoi. De tai nay xay dung mot ung dung Web de quan ly va giam sat he thong mang theo mo hinh mo phong.

### 1.2 Muc tieu cua de tai

1. Xay dung he thong Web quan ly nguoi dung va phan quyen theo vai tro (Admin / Technician / Viewer) thong qua bang junction UserRole.
2. Quan ly thiet bi mang: Router, Access Point, Switch, Network Device.
3. Quan ly co so ha tang: Room, VLAN, IP Address Management.
4. Theo doi bang thong, WiFi analytics, canh bao mang.
5. Quan ly ticket ho tro va lich bao tri thiet bi.
6. Dam bao bao mat: ma hoa mat khau BCrypt, dang nhap Google OAuth2, phan quyen qua Filter.
7. Gui email xac nhan va thong bao qua JavaMail.

### 1.3 Pham vi va gioi han

```text
Pham vi:
- Quan ly du lieu mo phong cho he thong mang trong truong dai hoc
- CRUD cac bang chinh va xu ly cac chuc nang theo vai tro
- Ghi nhan login log (AuthenticationLog) va system log (SystemLog)
- Tich hop bao mat: BCrypt, Google OAuth2, CSRF protection
- Gui email: xac nhan tai khoan, reset mat khau

Gioi han:
- Khong ket noi truc tiep voi thiet bi that
- Khong tich hop SNMP
- Thanh toan (VNPay/MoMo) khong ap dung cho chu de quan ly mang
```

### 1.4 Cong nghe su dung

| Thanh phan | Cong nghe |
|---|---|
| IDE | NetBeans 13 |
| JDK | JDK 8 |
| Server | Apache Tomcat 9 |
| Backend | Servlet/JSP (`javax.servlet.*`) |
| Kien truc | MVC-V2 voi FrontController (DispatcherServlet) |
| Database | **SQL Server** (khong phai MySQL) |
| Build | Ant |
| JDBC | Microsoft JDBC Driver for SQL Server (`mssql-jdbc-12.x.x.jre8.jar`) |
| Bao mat mat khau | BCrypt (jBCrypt-0.4.jar) |
| Dang nhap Google | Google OAuth2 Client |
| Email | JavaMail API (jakarta.mail.jar) |
| Frontend | Bootstrap 5, JavaScript ES6+, JSTL 1.2, EL |

---

## Chuong 2: Phan tich yeu cau theo Computational Thinking

### 2.1 Decomposition

He thong duoc tach thanh 5 nhom chinh (20 bang tong cong):

1. **Authentication & Authorization:** `[User]`, `Role`, `UserRole`*, `AuthenticationLog`, `SystemLog`
   - `[User]` khong co field `role` — role quan ly qua bang junction `UserRole`
   - `UserRole` la bang M:N giua User va Role
   - `AuthenticationLog.user_id` nullable (null khi login that bai)

2. **Core Devices:** `Router`, `AccessPoint`, `[Switch]`, `NetworkDevice`
   - Tat ca 4 bang deu co `room_id` FK tuy chon den `Room`
   - `[Switch]` phai viet trong ngoac vuong khi truy van SQL Server

3. **Infrastructure & Support:** `Room`, `VLAN`, `IPAddressManagement`, `SupportTicket`
   - `IPAddressManagement.device_id` la FK den `NetworkDevice` (UNIQUE, nullable)
   - `SupportTicket.created_by` la INT FK den `[User]` (khong phai VARCHAR)

4. **Monitoring:** `BandwidthUsage`, `WiFiAnalytics`, `NetworkAlert`
   - `BandwidthUsage.device_id` la INT FK den `NetworkDevice`
   - `WiFiAnalytics.ap_id` la INT NOT NULL FK den `AccessPoint`
   - `NetworkAlert` co 3 FK nullable: `router_id`, `ap_id`, `switch_id`

5. **Maintenance:** `MaintenanceSchedule`, `MaintenanceRouter`*, `MaintenanceAccessPoint`*, `MaintenanceSwitch`*
   - 3 bang junction dung composite PK, ON DELETE CASCADE tu MaintenanceSchedule

(*Bang junction)

### 2.2 Pattern Recognition

```text
Cac mau lap lai:
- CRUD pattern: insert, update, delete, findById, findAll
- Junction table pattern: UserRole, MaintenanceRouter, MaintenanceAccessPoint, MaintenanceSwitch
- Status pattern:
  [User]: ACTIVE / INACTIVE
  Router: ONLINE / OFFLINE / MAINTENANCE
  AccessPoint: ONLINE / OFFLINE
  [Switch]: ONLINE / OFFLINE / MAINTENANCE
  NetworkDevice: ALLOWED / BLOCKED
  SupportTicket: OPEN / IN_PROGRESS / RESOLVED / CLOSED
  MaintenanceSchedule: PLANNED / IN_PROGRESS / COMPLETED
  IPAddressManagement: AVAILABLE / ASSIGNED / RESERVED
  AuthenticationLog: SUCCESS / FAILED
  NetworkAlert severity: INFO / WARNING / CRITICAL
- Date tracking (SQL Server): assigned_at, login_time, created_at, record_time, analytics_date, start_time, end_time (dung GETDATE() thay CURRENT_TIMESTAMP)
- Nullable FK pattern: room_id (trong thiet bi), user_id (AuthenticationLog), router_id/ap_id/switch_id (NetworkAlert)
```

### 2.3 Abstraction

He thong su dung mo hinh MVC-V2 (yeu cau bat buoc cua de bai):

```text
JSP View (JSTL + EL, khong scriptlet lon)
  <- Servlet Controller (validate, goi DAO, set attribute)
      <- DAO Layer (SQL Server JDBC, PreparedStatement)
          <- DTO/Model (carry data between layers)
Ngang: Filter (Auth, Authz, Encoding) + Utility (DBContext, SessionUtil, PasswordUtil, MailUtil)
```

**Nguyen tac tach biet:**
- DAO khong biet ve HTTP
- Servlet khong biet ve SQL
- JSP khong co business logic

### 2.4 Algorithm Design

Can trinh bay flowchart cho cac thuat toan sau:

1. **Dang nhap va phan quyen:**
   - Xac thuc BCrypt → ghi `AuthenticationLog` → load role tu `UserRoleDAO` → luu session → redirect theo role

2. **Google OAuth2 flow:**
   - Redirect den Google → callback → tao hoac lay User → ghi session → redirect dashboard

3. **Chan/mo khoa thiet bi:**
   - `NetworkDeviceDAO.blockDevice()` → UPDATE status='BLOCKED' → ghi `SystemLog` → redirect

4. **Tao va loc canh bao:**
   - Tao `NetworkAlert` voi router_id/ap_id/switch_id tuong ung → filter theo severity

5. **Tao va cap nhat ticket ho tro:**
   - `created_by` = `session.loggedUser.userId` (INT FK) → update status → ghi SystemLog

6. **Tao lich bao tri:**
   - Insert `MaintenanceSchedule` → insert cac dong `MaintenanceRouter`/`MaintenanceAccessPoint`/`MaintenanceSwitch` tuong ung

---

## Chuong 3: Thiet ke he thong

### 3.1 ERD va co so du lieu

He thong gom **20 bang**: 16 bang chinh va 4 bang junction.

| Nhom | Bang |
|---|---|
| Auth & Logging | `[User]`, `Role`, `UserRole`*, `AuthenticationLog`, `SystemLog` |
| Core Devices | `Router`, `AccessPoint`, `[Switch]`, `NetworkDevice` |
| Infrastructure & Support | `Room`, `VLAN`, `IPAddressManagement`, `SupportTicket` |
| Monitoring | `BandwidthUsage`, `WiFiAnalytics`, `NetworkAlert` |
| Maintenance | `MaintenanceSchedule`, `MaintenanceRouter`*, `MaintenanceAccessPoint`*, `MaintenanceSwitch`* |

(*Bang junction)

**Luu y quan trong khi trinh bay ERD:**
- `[User]` khong co field `role` — the hien quan he M:N qua `UserRole`
- `SupportTicket.created_by` la INT FK (khong phai VARCHAR username)
- `BandwidthUsage.device_id` la INT FK (khong phai device_name)
- `IPAddressManagement.device_id` la INT UNIQUE FK (khong phai assigned_to VARCHAR)
- `NetworkAlert` co 3 FK rieng biet: `router_id`, `ap_id`, `switch_id` (tat ca nullable)

Chen ERD tu `02_erd_database.md`.

### 3.2 Kien truc he thong (MVC-V2)

```text
Browser
  → FrontController (DispatcherServlet) — bat buoc theo de bai
      → AuthenticationFilter: kiem tra session
      → AuthorizationFilter: phan quyen theo role
      → Sub-Servlet → DAO → SQL Server
      → JSP View (JSTL + EL)
```

### 3.3 Cau truc thu muc

Chen cau truc thu muc tu `04_system_architecture.md`.

### 3.4 Bao mat

| Yeu cau | Giai phap |
|---|---|
| Ma hoa mat khau | BCrypt (jBCrypt) — `PasswordUtil.hash()` / `PasswordUtil.verify()` |
| Dang nhap Google | Google OAuth2 Client (`com.google.api-client`) |
| Chong CSRF | Hidden token trong form, verify tai Servlet |
| Validate server-side | Kiem tra input trong Servlet truoc khi goi DAO |
| Khong de lo stack trace | Custom error page — bat loi voi try/catch, forward error.jsp |

### 3.5 Thiet ke giao dien

Can screenshot cac trang sau:
- Trang dang nhap (form + nut dang nhap Google)
- Dashboard theo tung role (Admin / Technician / Viewer)
- Danh sach Router/AP/Switch/NetworkDevice
- Form them/sua thiet bi (co dropdown Room)
- Room/VLAN/IP Management
- Bang giam sat bandwidth va WiFi analytics
- Danh sach ticket
- Lich bao tri (kem danh sach thiet bi lien quan)
- Canh bao (loc theo severity)
- User/Role management
- System Log va Auth Log

---

## Chuong 4: Cai dat va trien khai

### 4.1 Moi truong phat trien

1. JDK 8
2. NetBeans 13
3. Apache Tomcat 9 (khong dung Tomcat 10+)
4. **SQL Server** (khong dung MySQL)
5. Microsoft JDBC Driver for SQL Server (`mssql-jdbc-12.x.x.jre8.jar`)
6. jBCrypt-0.4.jar
7. Jakarta Mail (jakarta.mail.jar)

### 4.2 Cai dat co so du lieu (SQL Server)

Script hien tai la `Network2.sql`. Luu y:
- Script dung T-SQL: `GO`, `IDENTITY(1,1)`, `GETDATE()`, `NVARCHAR`.
- Bang `[User]` va `[Switch]` can viet trong ngoac vuong khi truy van.
- Ten database trong script hien la `network_simulation_db3` — doi thanh `network_simulation_db` truoc khi chay chung.
- Thu tu tao bang phai tuan theo thu tu FK (xem `04_system_architecture.md` muc 5).
- Mat khau trong sample data la placeholder (`hashed_admin01`) — can update bang BCrypt khi chay that.

### 4.3 Cac buoc cai dat

```text
1. Cai JDK 8 va NetBeans 13
2. Dang ky Tomcat 9 trong NetBeans
3. Tao Java Web project dung Ant: NetworkSimulationManagement
4. Them vao Libraries: mssql-jdbc-12.x.x.jre8.jar, jstl-1.2.jar, jbcrypt-0.4.jar, jakarta.mail.jar
5. Mo SQL Server Management Studio, doi ten database thanh network_simulation_db
6. Chay Network2.sql de tao schema va du lieu mau
7. Cap nhat DBContext.java: URL (jdbc:sqlserver://...), username, password
8. Build va run project tren Tomcat 9
9. Kiem tra login bang tai khoan admin (can update password bang BCrypt)
```

### 4.4 Ma nguon cac lop chinh

Can trinh bay:
- `DBContext.java` — ket noi SQL Server (jdbc:sqlserver://...)
- `PasswordUtil.java` — BCrypt wrapper
- `MailUtil.java` — JavaMail helper
- `UserDAO.java`, `UserRoleDAO.java` — quan ly user va role
- `LoginServlet.java` — xac thuc, BCrypt verify, load roles tu UserRole
- `DispatcherServlet.java` — FrontController
- `AuthenticationFilter.java`, `AuthorizationFilter.java` — bao mat
- `Router.java` (DTO), `RouterDAO.java`, `RouterServlet.java` — vi du CRUD day du
- `MaintenanceRouterDAO.java` — vi du junction DAO

---

## Chuong 5: Ket qua va danh gia

### 5.1 Ket qua thuc hien

```text
- Hoan thanh 20 DTO/model theo schema Network2.sql (SQL Server)
- Hoan thanh DAO cho 16 bang chinh va 4 bang junction
- FrontController (DispatcherServlet) dieu phoi request
- AuthenticationFilter + AuthorizationFilter hoat dong dung
- Dang nhap va phan quyen qua UserRole hoat dong
- BCrypt ma hoa mat khau
- Google OAuth2 dang nhap Google
- JavaMail gui email xac nhan va reset mat khau
- CRUD cho thiet bi, phong, VLAN, IP, ticket, bao tri
- Monitoring va alert co the xem/loc du lieu
- Ghi AuthenticationLog (nullable user_id khi that bai) va SystemLog (INT FK performed_by)
```

### 5.2 Huong dan su dung

Mo ta cach su dung theo vai tro:
- **Admin:** quan ly toan bo he thong — user, role, thiet bi, co so ha tang, monitoring, ticket, log.
- **Technician:** cap nhat trang thai thiet bi, block/unblock, xu ly ticket, xem monitoring.
- **Viewer:** xem trang thai mang, gui ticket, xem lich bao tri.

### 5.3 Huong phat trien

1. Ket noi thiet bi that qua SNMP.
2. Them Chart.js / ApexCharts cho dashboard.
3. Them truong `assigned_to`, `resolved_at`, `resolution_note` cho ticket.
4. Them `status`, `resolved_by`, `resolved_at` cho NetworkAlert.
5. Xuat bao cao PDF/Excel (Apache POI hoac iText).
6. Thanh toan truc tuyen neu chuyen sang he thong thu phi dich vu.
7. Da ngon ngu (VI / EN) bang ResourceBundle.

### 5.4 Bai hoc rut ra

```text
- Can dong bo schema SQL Server voi tai lieu truoc khi code
- User.role da xoa — moi role check phai qua UserRole (SessionUtil.hasRole)
- Nullable FK phai xu ly rs.wasNull() va ps.setNull() rieng
- Bang junction [User], [Switch] phai viet trong ngoac vuong trong SQL Server
- FrontController giup quan ly URL tap trung va de bao tri hon
- BCrypt an toan hon MD5/SHA1 cho mat khau
- DAO giup tach SQL khoi Servlet/JSP — bao ve kien truc MVC
- Filter tach biet logic bao mat khoi business logic
```

---

## Tai lieu tham khao

1. Java Servlet Specification 3.1
2. Microsoft JDBC Driver for SQL Server Documentation
3. SQL Server Documentation (T-SQL Reference)
4. Apache Tomcat 9 Documentation
5. NetBeans IDE Documentation
6. jBCrypt Documentation (org.mindrot.jbcrypt)
7. Google OAuth2 Client for Java Documentation
8. JavaMail API Documentation
9. Bai giang PRJ301

---

## Phu luc

- Phu luc A: Script SQL day du `Network2.sql` (SQL Server)
- Phu luc B: Ma nguon cac lop chinh (DBContext, PasswordUtil, MailUtil, UserDAO, UserRoleDAO, LoginServlet, DispatcherServlet, RouterDAO, RouterServlet)
- Phu luc C: Screenshot he thong (toi thieu 15 screenshot)
- Phu luc D: Phan cong cong viec chi tiet (Member A/B/C/D voi 4+ bang moi nguoi)

---

## Huong dan trinh bay

- Dung Heading 1 cho moi chuong.
- Dung Heading 2/3 cho cac muc con.
- Chen hinh anh voi caption ro rang.
- Font Times New Roman, size 13.
- Can le theo yeu cau cua giang vien.
- **Da loai bo toan bo noi dung MySQL cu** — tat ca SQL example dung SQL Server T-SQL.
