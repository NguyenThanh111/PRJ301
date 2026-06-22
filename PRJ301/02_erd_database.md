---
title: "ERD and Database Design — 20 Tables (SQL Server)"
tags: [prj301, planning, database, erd]
created: 2026-05-26
updated: 2026-06-17
---

# ERD and Database Design — 20 Tables (SQL Server)

> **Nguồn sự thật:** File này được đồng bộ theo `Network2.sql`.
> Database: **SQL Server** (không phải MySQL).
> Tên database: `network_simulation_db` (file SQL gốc dùng `network_simulation_db3` — cần đổi trước khi chạy chung).
> Tổng: **20 bảng** — 16 bảng chính + 4 bảng junction.

---

## 1. ERD Diagram (Mermaid)

```mermaid
erDiagram
    User ||--o{ AuthenticationLog : "logs"
    User ||--o{ SystemLog : "performs"
    User ||--o{ SupportTicket : "creates (created_by INT FK)"
    User }o--o{ Role : "has via UserRole"
    UserRole }o--|| User : ""
    UserRole }o--|| Role : ""

    Router }o--o| Room : "located in"
    AccessPoint }o--o| Room : "located in"
    Switch }o--o| Room : "located in"
    NetworkDevice }o--o| Room : "connected to"
    VLAN }o--o| Room : "serves"

    NetworkDevice ||--o{ BandwidthUsage : "tracks"
    NetworkDevice |o--o| IPAddressManagement : "assigned (device_id UNIQUE FK)"

    WiFiAnalytics }o--|| AccessPoint : "analyzes (ap_id NOT NULL FK)"
    NetworkAlert }o--o| Router : "router_id nullable"
    NetworkAlert }o--o| AccessPoint : "ap_id nullable"
    NetworkAlert }o--o| Switch : "switch_id nullable"

    MaintenanceSchedule }o--o{ Router : "via MaintenanceRouter"
    MaintenanceSchedule }o--o{ AccessPoint : "via MaintenanceAccessPoint"
    MaintenanceSchedule }o--o{ Switch : "via MaintenanceSwitch"
    MaintenanceRouter }o--|| MaintenanceSchedule : ""
    MaintenanceRouter }o--|| Router : ""
    MaintenanceAccessPoint }o--|| MaintenanceSchedule : ""
    MaintenanceAccessPoint }o--|| AccessPoint : ""
    MaintenanceSwitch }o--|| MaintenanceSchedule : ""
    MaintenanceSwitch }o--|| Switch : ""

    SupportTicket }o--o| NetworkDevice : "device_id nullable FK"

    User {
        int user_id PK
        string username
        string password
        string full_name
        string email
        string status
    }

    Role {
        int role_id PK
        string role_name
        string description
    }

    UserRole {
        int user_id FK
        int role_id FK
        datetime assigned_at
    }

    Router {
        int router_id PK
        string router_name
        string ip_address
        string mac_address
        string model
        string firmware
        string status
        string location
        int room_id FK
    }

    AccessPoint {
        int ap_id PK
        string ap_name
        string ssid
        string ip_address
        int connected_users
        string status
        string location
        int room_id FK
    }

    Switch {
        int switch_id PK
        string switch_name
        int total_ports
        int used_ports
        string ip_address
        string status
        int room_id FK
    }

    NetworkDevice {
        int device_id PK
        string device_name
        string mac_address
        string ip_address
        string owner
        string device_type
        string status
        int room_id FK
    }

    Room {
        int room_id PK
        string room_name
        string building
        int floor
        int capacity
    }

    BandwidthUsage {
        int usage_id PK
        float upload_speed
        float download_speed
        datetime record_time
        int device_id FK
    }

    WiFiAnalytics {
        int analytics_id PK
        int total_users
        int peak_users
        float avg_speed
        date analytics_date
        int ap_id FK
    }

    NetworkAlert {
        int alert_id PK
        string alert_type
        string message
        string severity
        datetime created_at
        int router_id FK
        int ap_id FK
        int switch_id FK
    }

    SupportTicket {
        int ticket_id PK
        string title
        string description
        string status
        datetime created_date
        int created_by FK
        int device_id FK
    }

    MaintenanceSchedule {
        int maintenance_id PK
        string title
        string description
        datetime start_time
        datetime end_time
        string status
    }

    MaintenanceRouter {
        int maintenance_id FK
        int router_id FK
    }

    MaintenanceAccessPoint {
        int maintenance_id FK
        int ap_id FK
    }

    MaintenanceSwitch {
        int maintenance_id FK
        int switch_id FK
    }

    VLAN {
        int vlan_id PK
        string vlan_name
        string subnet
        string purpose
        int room_id FK
    }

    IPAddressManagement {
        int ip_id PK
        string ip_address
        string status
        int device_id FK
    }

    AuthenticationLog {
        int log_id PK
        string username
        string login_status
        string ip_address
        datetime login_time
        int user_id FK
    }

    SystemLog {
        int log_id PK
        string action
        datetime created_at
        string details
        int performed_by FK
    }
```

---

## 2. Các điểm sai lệch đã sửa so với phiên bản cũ

| Vấn đề cũ | Đã sửa thành |
|---|---|
| `User` có field `role VARCHAR(30)` | Đã xóa — role quản lý qua `UserRole` junction table |
| Schema dùng MySQL (`AUTO_INCREMENT`, `CURRENT_TIMESTAMP`, `TEXT`) | Schema dùng SQL Server (`IDENTITY(1,1)`, `GETDATE()`, `NVARCHAR`, `NVARCHAR(MAX)`) |
| `IPAddressManagement.assigned_to VARCHAR` | Đổi thành `device_id INT UNIQUE FK → NetworkDevice` |
| `BandwidthUsage.device_name VARCHAR` | Đổi thành `device_id INT NOT NULL FK → NetworkDevice` |
| `SupportTicket.created_by VARCHAR` | Đổi thành `created_by INT NOT NULL FK → [User]` |
| `SystemLog.performed_by VARCHAR` | Đổi thành `performed_by INT FK → [User]` |
| `AuthenticationLog` không có `user_id` | Thêm `user_id INT nullable FK → [User]` (null khi login thất bại) |
| `WiFiAnalytics` không có `ap_id` | Thêm `ap_id INT NOT NULL FK → AccessPoint` |
| `NetworkAlert` không có FK thiết bị | Thêm `router_id`, `ap_id`, `switch_id` (đều nullable) |
| Thiếu 4 bảng junction | Thêm `UserRole`, `MaintenanceRouter`, `MaintenanceAccessPoint`, `MaintenanceSwitch` |
| Sample data dùng MySQL syntax | Sample data đã dùng T-SQL (xem `Network2.sql`) |

---

## 3. Schema SQL Server (tham khảo từ Network2.sql)

Script đầy đủ xem trong `Network2.sql`. Các lưu ý quan trọng khi viết DAO:

```sql
-- Bảng đặc biệt phải viết trong ngoặc vuông
SELECT * FROM [User]
SELECT * FROM [Switch]

-- Nullable FK: dùng rs.wasNull() sau rs.getInt()
int roomId = rs.getInt("room_id");
router.setRoomId(rs.wasNull() ? null : roomId);

-- Set null cho nullable FK
if (router.getRoomId() == null) {
    ps.setNull(8, Types.INTEGER);
} else {
    ps.setInt(8, router.getRoomId());
}
```

---

## 4. Status Values (theo Network2.sql)

| Table | Status Values |
|---|---|
| `[User]` | `ACTIVE`, `INACTIVE` |
| `Router` | `ONLINE`, `OFFLINE`, `MAINTENANCE` |
| `AccessPoint` | `ONLINE`, `OFFLINE` |
| `[Switch]` | `ONLINE`, `OFFLINE`, `MAINTENANCE` |
| `NetworkDevice` | `ALLOWED`, `BLOCKED` |
| `SupportTicket` | `OPEN`, `IN_PROGRESS`, `RESOLVED`, `CLOSED` |
| `MaintenanceSchedule` | `PLANNED`, `IN_PROGRESS`, `COMPLETED` |
| `IPAddressManagement` | `AVAILABLE`, `ASSIGNED`, `RESERVED` |
| `AuthenticationLog` | `SUCCESS`, `FAILED` |
| `NetworkAlert` | severity: `INFO`, `WARNING`, `CRITICAL` |

---

## 5. Relationship Explanations (đã sửa)

| Relationship | Type | Description |
|---|---|---|
| User ↔ Role | Many-to-Many | Qua `UserRole` junction table — không có `role` field trực tiếp trên `User` |
| Router → Room | Many-to-One | Nullable FK — router có thể không gắn room |
| AccessPoint → Room | Many-to-One | Nullable FK |
| Switch → Room | Many-to-One | Nullable FK |
| NetworkDevice → Room | Many-to-One | Nullable FK |
| VLAN → Room | Many-to-One | Nullable FK |
| NetworkDevice → BandwidthUsage | One-to-Many | `device_id NOT NULL FK` |
| NetworkDevice → IPAddressManagement | One-to-One | `device_id UNIQUE nullable FK` |
| AccessPoint → WiFiAnalytics | One-to-Many | `ap_id NOT NULL FK` |
| NetworkAlert → Router/AP/Switch | Many-to-One (optional) | Ba FK đều nullable — một alert chỉ liên quan một loại thiết bị |
| SupportTicket → User | Many-to-One | `created_by INT NOT NULL FK` |
| SupportTicket → NetworkDevice | Many-to-One | `device_id nullable FK` |
| AuthenticationLog → User | Many-to-One | `user_id nullable FK` — null khi username không tồn tại |
| SystemLog → User | Many-to-One | `performed_by INT nullable FK` |
| MaintenanceSchedule ↔ Router/AP/Switch | Many-to-Many | Qua 3 junction tables |

---

## 6. Indexing Strategy

| Table | Index | Reason |
|---|---|---|
| `[User]` | `username` (UNIQUE) | Fast login lookup |
| `NetworkDevice` | `mac_address` (UNIQUE) | Fast MAC-based device search |
| `Router` | `ip_address` (UNIQUE), `mac_address` (UNIQUE) | Prevent duplicate |
| `AccessPoint` | `ip_address` (UNIQUE) | Prevent duplicate |
| `[Switch]` | `ip_address` (UNIQUE) | Prevent duplicate |
| `IPAddressManagement` | `ip_address` (UNIQUE), `device_id` (UNIQUE) | Prevent duplicate IP + one device one IP |
| `BandwidthUsage` | `record_time` | Fast date-range queries |
| `AuthenticationLog` | `login_time`, `username` | Fast log search |
| `SystemLog` | `created_at`, `performed_by` | Fast audit trail search |
| `NetworkAlert` | `created_at`, `severity` | Fast alert filtering |

---

## 7. Table Creation Order (FK-safe)

```text
1. Role
2. [User]
3. UserRole          ← FK: User, Role
4. Room
5. Router            ← FK: Room
6. AccessPoint       ← FK: Room
7. [Switch]          ← FK: Room
8. NetworkDevice     ← FK: Room
9. VLAN              ← FK: Room
10. IPAddressManagement  ← FK: NetworkDevice
11. BandwidthUsage   ← FK: NetworkDevice
12. WiFiAnalytics    ← FK: AccessPoint
13. NetworkAlert     ← FK: Router, AccessPoint, Switch
14. SupportTicket    ← FK: User, NetworkDevice
15. MaintenanceSchedule
16. MaintenanceRouter       ← FK: MaintenanceSchedule, Router
17. MaintenanceAccessPoint  ← FK: MaintenanceSchedule, AccessPoint
18. MaintenanceSwitch       ← FK: MaintenanceSchedule, Switch
19. AuthenticationLog ← FK: User
20. SystemLog         ← FK: User
```

---

## 8. Related Documents

- `Network2.sql` — Nguồn sự thật cho schema (SQL Server T-SQL)
- `03_team_assignment_updated.md` — Who owns which tables
- `07_coding_guide.md` — How to implement DAO for these tables
