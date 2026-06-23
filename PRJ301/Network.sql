
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'network_simulation_db2')
    CREATE DATABASE network_simulation_db2;
GO

USE network_simulation_db2;
GO

GO


CREATE TABLE Role (
    role_id   INT IDENTITY(1,1) PRIMARY KEY,
    role_name VARCHAR(50)  NOT NULL UNIQUE,
    description VARCHAR(255)
);
GO

-- =====================
-- 2. User
-- =====================
CREATE TABLE [User] (
    user_id   INT IDENTITY(1,1) PRIMARY KEY,
    username  VARCHAR(50)  NOT NULL UNIQUE,
    password  VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email     VARCHAR(100),
    status    VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE'
);
GO

-- =====================
-- 3. UserRole  [M-M: User <-> Role]
-- =====================
CREATE TABLE UserRole (
    user_id     INT      NOT NULL,
    role_id     INT      NOT NULL,
    assigned_at DATETIME NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_userrole_user FOREIGN KEY (user_id) REFERENCES [User](user_id) ON DELETE CASCADE,
    CONSTRAINT fk_userrole_role FOREIGN KEY (role_id) REFERENCES Role(role_id)
);
GO

-- =====================
-- 4. Room
-- =====================
CREATE TABLE Room (
    room_id   INT IDENTITY(1,1) PRIMARY KEY,
    room_name VARCHAR(100) NOT NULL,
    building  VARCHAR(100),
    floor     INT          DEFAULT 1,
    capacity  INT          DEFAULT 0
);
GO

-- =====================
-- 5. Router  [1-M: Room -> Router]
-- =====================
CREATE TABLE Router (
    router_id   INT IDENTITY(1,1) PRIMARY KEY,
    router_name VARCHAR(100) NOT NULL,
    ip_address  VARCHAR(45)  UNIQUE,
    mac_address VARCHAR(50)  UNIQUE,
    model       VARCHAR(100),
    firmware    VARCHAR(100),
    status      VARCHAR(30)  NOT NULL DEFAULT 'ONLINE',
    location    VARCHAR(150),
    room_id     INT,
    CONSTRAINT fk_router_room FOREIGN KEY (room_id) REFERENCES Room(room_id)
);
GO

-- =====================
-- 6. AccessPoint  [1-M: Room -> AccessPoint]
-- =====================
CREATE TABLE AccessPoint (
    ap_id           INT IDENTITY(1,1) PRIMARY KEY,
    ap_name         VARCHAR(100) NOT NULL,
    ssid            VARCHAR(100),
    ip_address      VARCHAR(45)  UNIQUE,
    connected_users INT          NOT NULL DEFAULT 0,
    status          VARCHAR(30)  NOT NULL DEFAULT 'ONLINE',
    location        VARCHAR(150),
    room_id         INT,
    CONSTRAINT fk_ap_room FOREIGN KEY (room_id) REFERENCES Room(room_id)
);
GO

-- =====================
-- 7. Switch  [1-M: Room -> Switch]
-- =====================
CREATE TABLE [Switch] (
    switch_id   INT IDENTITY(1,1) PRIMARY KEY,
    switch_name VARCHAR(100) NOT NULL,
    total_ports INT          NOT NULL DEFAULT 0,
    used_ports  INT          NOT NULL DEFAULT 0,
    ip_address  VARCHAR(45)  UNIQUE,
    status      VARCHAR(30)  NOT NULL DEFAULT 'ONLINE',
    room_id     INT,
    CONSTRAINT fk_switch_room FOREIGN KEY (room_id) REFERENCES Room(room_id)
);
GO

-- =====================
-- 8. NetworkDevice  [1-M: Room -> NetworkDevice]
-- =====================
CREATE TABLE NetworkDevice (
    device_id   INT IDENTITY(1,1) PRIMARY KEY,
    device_name VARCHAR(100) NOT NULL,
    mac_address VARCHAR(50)  UNIQUE,
    ip_address  VARCHAR(45),
    owner       VARCHAR(100),
    device_type VARCHAR(50),
    status      VARCHAR(30)  NOT NULL DEFAULT 'ALLOWED',
    room_id     INT,
    CONSTRAINT fk_device_room FOREIGN KEY (room_id) REFERENCES Room(room_id)
);
GO

-- =====================
-- 9. VLAN  [1-M: Room -> VLAN]
-- =====================
CREATE TABLE VLAN (
    vlan_id   INT IDENTITY(1,1) PRIMARY KEY,
    vlan_name VARCHAR(100) NOT NULL,
    subnet    VARCHAR(50),
    purpose   VARCHAR(255),
    room_id   INT,
    CONSTRAINT fk_vlan_room FOREIGN KEY (room_id) REFERENCES Room(room_id)
);
GO

-- =====================
-- 10. IPAddressManagement  [1-1: NetworkDevice -> IPAddressManagement]
-- =====================
CREATE TABLE IPAddressManagement (
    ip_id      INT IDENTITY(1,1) PRIMARY KEY,
    ip_address VARCHAR(45) NOT NULL UNIQUE,
    status     VARCHAR(30) NOT NULL DEFAULT 'AVAILABLE',
    device_id  INT         UNIQUE,
    CONSTRAINT fk_ip_device FOREIGN KEY (device_id) REFERENCES NetworkDevice(device_id)
);
GO

-- =====================
-- 11. BandwidthUsage  [1-M: NetworkDevice -> BandwidthUsage]
-- =====================
CREATE TABLE BandwidthUsage (
    usage_id       INT IDENTITY(1,1) PRIMARY KEY,
    upload_speed   FLOAT    NOT NULL DEFAULT 0,
    download_speed FLOAT    NOT NULL DEFAULT 0,
    record_time    DATETIME NOT NULL DEFAULT GETDATE(),
    device_id      INT      NOT NULL,
    CONSTRAINT fk_bandwidth_device FOREIGN KEY (device_id) REFERENCES NetworkDevice(device_id)
);
GO

-- =====================
-- 12. WiFiAnalytics  [1-M: AccessPoint -> WiFiAnalytics]
-- =====================
CREATE TABLE WiFiAnalytics (
    analytics_id   INT IDENTITY(1,1) PRIMARY KEY,
    total_users    INT     NOT NULL DEFAULT 0,
    peak_users     INT     NOT NULL DEFAULT 0,
    avg_speed      FLOAT   NOT NULL DEFAULT 0,
    analytics_date DATE    NOT NULL,
    ap_id          INT     NOT NULL,
    CONSTRAINT fk_wifi_ap FOREIGN KEY (ap_id) REFERENCES AccessPoint(ap_id)
);
GO

-- =====================
-- 13. NetworkAlert  [1-M: Router/AccessPoint/Switch -> NetworkAlert]

-- =====================
CREATE TABLE NetworkAlert (
    alert_id   INT IDENTITY(1,1) PRIMARY KEY,
    alert_type VARCHAR(50)  NOT NULL,
    message    VARCHAR(255) NOT NULL,
    severity   VARCHAR(20)  NOT NULL DEFAULT 'INFO',
    created_at DATETIME     NOT NULL DEFAULT GETDATE(),
    router_id  INT,
    ap_id      INT,
    switch_id  INT,
    CONSTRAINT fk_alert_router FOREIGN KEY (router_id)  REFERENCES Router(router_id),
    CONSTRAINT fk_alert_ap     FOREIGN KEY (ap_id)      REFERENCES AccessPoint(ap_id),
    CONSTRAINT fk_alert_switch FOREIGN KEY (switch_id)  REFERENCES [Switch](switch_id)
);
GO

-- =====================
-- 14. SupportTicket  [1-M: User -> SupportTicket, NetworkDevice -> SupportTicket]
-- =====================
CREATE TABLE SupportTicket (
    ticket_id    INT IDENTITY(1,1) PRIMARY KEY,
    title        VARCHAR(150) NOT NULL,
    description  VARCHAR(MAX),
    status       VARCHAR(30)  NOT NULL DEFAULT 'OPEN',
    created_date DATETIME     NOT NULL DEFAULT GETDATE(),
    created_by   INT          NOT NULL,
    device_id    INT,
    CONSTRAINT fk_ticket_user   FOREIGN KEY (created_by) REFERENCES [User](user_id),
    CONSTRAINT fk_ticket_device FOREIGN KEY (device_id)  REFERENCES NetworkDevice(device_id)
);
GO

-- =====================
-- 15. MaintenanceSchedule
-- =====================
CREATE TABLE MaintenanceSchedule (
    maintenance_id INT IDENTITY(1,1) PRIMARY KEY,
    title          VARCHAR(150) NOT NULL,
    description    VARCHAR(MAX),
    start_time     DATETIME     NOT NULL,
    end_time       DATETIME,
    status         VARCHAR(30)  NOT NULL DEFAULT 'PLANNED'
);
GO

-- =====================
-- 16. MaintenanceRouter  [M-M: MaintenanceSchedule <-> Router]
-- =====================
CREATE TABLE MaintenanceRouter (
    maintenance_id INT NOT NULL,
    router_id      INT NOT NULL,
    PRIMARY KEY (maintenance_id, router_id),
    CONSTRAINT fk_maintrouter_maint  FOREIGN KEY (maintenance_id) REFERENCES MaintenanceSchedule(maintenance_id) ON DELETE CASCADE,
    CONSTRAINT fk_maintrouter_router FOREIGN KEY (router_id)      REFERENCES Router(router_id)
);
GO

-- =====================
-- 17. MaintenanceAccessPoint  [M-M: MaintenanceSchedule <-> AccessPoint]
-- =====================
CREATE TABLE MaintenanceAccessPoint (
    maintenance_id INT NOT NULL,
    ap_id          INT NOT NULL,
    PRIMARY KEY (maintenance_id, ap_id),
    CONSTRAINT fk_maintap_maint FOREIGN KEY (maintenance_id) REFERENCES MaintenanceSchedule(maintenance_id) ON DELETE CASCADE,
    CONSTRAINT fk_maintap_ap    FOREIGN KEY (ap_id)          REFERENCES AccessPoint(ap_id)
);
GO

-- =====================
-- 18. MaintenanceSwitch  [M-M: MaintenanceSchedule <-> Switch]
-- =====================
CREATE TABLE MaintenanceSwitch (
    maintenance_id INT NOT NULL,
    switch_id      INT NOT NULL,
    PRIMARY KEY (maintenance_id, switch_id),
    CONSTRAINT fk_maintswitch_maint  FOREIGN KEY (maintenance_id) REFERENCES MaintenanceSchedule(maintenance_id) ON DELETE CASCADE,
    CONSTRAINT fk_maintswitch_switch FOREIGN KEY (switch_id)      REFERENCES [Switch](switch_id)
);
GO

-- =====================
-- 19. AuthenticationLog  [1-M: User -> AuthenticationLog]
-- =====================
CREATE TABLE AuthenticationLog (
    log_id       INT IDENTITY(1,1) PRIMARY KEY,
    username     VARCHAR(50)  NOT NULL,
    login_status VARCHAR(20)  NOT NULL,
    ip_address   VARCHAR(45),
    login_time   DATETIME     NOT NULL DEFAULT GETDATE(),
    user_id      INT,
    CONSTRAINT fk_authlog_user FOREIGN KEY (user_id) REFERENCES [User](user_id)
);
GO

-- =====================
-- 20. SystemLog  [1-M: User -> SystemLog]
-- =====================
CREATE TABLE SystemLog (
    log_id       INT IDENTITY(1,1) PRIMARY KEY,
    action       VARCHAR(100) NOT NULL,
    created_at   DATETIME     NOT NULL DEFAULT GETDATE(),
    details      VARCHAR(MAX),
    performed_by INT,
    CONSTRAINT fk_syslog_user FOREIGN KEY (performed_by) REFERENCES [User](user_id)
);
GO

INSERT INTO Role (role_name, description) VALUES
('Admin',      'Full system access'),
('Technician', 'Device maintenance and network support'),
('Viewer',     'Read-only dashboard access');
GO

-- =====================
-- User (15 rows)
-- =====================
INSERT INTO [User] (username, password, full_name, email, status) VALUES
('admin',     '310000:P7UZGhoXabjgr/+K58CdTg==:SJQFpsuxDDltbQYyIRekKgFVAzNPvdcZ/quoBrDG+eI=',  'System Administrator',  'admin@university.edu',      'ACTIVE'),
('tech01',    '310000:AUJd2wVYdTo1DhdkhLJbwg==:U/CF73lXSEHu2lw5JScpxNxun35OTmMudY5bCsOefT4=',  'Nguyen Van An',         'nv.an@university.edu',      'ACTIVE'),
('tech02',    '310000:fW7qDPxc92MuLe79lVf7Ww==:Vq8Bh9+TyTw65sKiE2sCcGst1PcxwU0JS54ICH5bU8s=',  'Tran Minh Duc',         'tm.duc@university.edu',     'ACTIVE'),
('tech03',    '310000:av1AaSBiNfgliwR84eWWOg==:QlnPGxUUqPVSNs9rjHRoGou0xcl1vLytsxq1n0aZxwc=',  'Le Thi Hoa',            'lt.hoa@university.edu',     'ACTIVE'),
('viewer01',  '310000:arM6JX5+O1ShygVJgWqqKQ==:6APl749vm3mVIl+VAxYo+oDCwIQ2qVq+lCUAD3fvLTw=',  'Pham Quoc Bao',         'pq.bao@university.edu',     'ACTIVE'),
('viewer02',  '310000:qH7ZmgojRhzL5Ub5jrPK7A==:7qGIjjHYidMDU/kWbAZq6TrYHOthUtcXdQVoQColo1c=',  'Hoang Thi Mai',         'ht.mai@university.edu',     'ACTIVE'),
('viewer03',  '310000:V6Fzr1VjvWqF+ufEe/dG5Q==:OoJNYAu5F2psQcbCGowPmvBZ5YhxKU0Tk4Ksiv1WvQM=',  'Vu Thanh Long',         'vt.long@university.edu',    'ACTIVE'),
('viewer04',  '310000:V2JLjQT88BfIbk9JkRG22A==:hDF0654t8uj11qGNXN10IoI6Zl7bypvb748tBFT1pjc=',  'Dang Thi Thu',          'dt.thu@university.edu',     'ACTIVE'),
('viewer05',  '310000:Zlsc3KiXijq/IsDqOy/4Mw==:JI3LbGiIL3vUeOgU+Ql5ZCKntZ7ObZmLCAS+wIpMcMs=',  'Bui Van Khanh',         'bv.khanh@university.edu',   'ACTIVE'),
('viewer06',  '310000:5t5TjWbYCrRh4e+a8O6LMQ==:JRwQn+yacw5YsCTn9z9zkBm5rNF37VLDSlsVf3zvhOc=',  'Ngo Thi Lan',           'nt.lan@university.edu',     'ACTIVE'),
('tech04',    '310000:n0n6c4zs9l7A/d1c6KhGNA==:7nl0gbps9PF68Gj+VkmFm4mpiN9g587OYcui69J2wmU=',  'Dinh Van Phuc',         'dv.phuc@university.edu',    'ACTIVE'),
('viewer07',  '310000:sv2YZ7jZ2sYxURmZqIxM9Q==:wAwgwyEwKsPKT+5cul9okPnpaRPNOf4trDk9XUhXOCg=',  'Truong Thi Ngoc',       'tt.ngoc@university.edu',    'INACTIVE'),
('viewer08',  '310000:lYcK74QivkKXpOXez4kZ8g==:HmFU3Bpnmpf6sTzy7+RZBqy902p36p4qUYLmON5erfI=',  'Cao Van Hieu',          'cv.hieu@university.edu',    'ACTIVE'),
('viewer09',  '310000:lfOFT2KomuqVYLknyQNZbw==:Fl6f2+THurDgB7XqhxIx14PyeNC9PCz53b24E1SWqHA=',  'Lam Thi Phuong',        'lt.phuong@university.edu',  'ACTIVE'),
('viewer10',  '310000:5ZCAYQV5XvU3CK2zriawIg==:ipjXSNDZdVPSe9Wy1wMTdmZ+ek/GZyO7ZjXohbLOrNc=',  'Mai Van Thanh',         'mv.thanh@university.edu',   'INACTIVE');
GO

-- =====================
-- UserRole
-- =====================
INSERT INTO UserRole (user_id, role_id) VALUES
(1,  1),  -- admin       -> Admin
(2,  2),  -- tech01      -> Technician
(3,  2),  -- tech02      -> Technician
(4,  2),  -- tech03      -> Technician
(11, 2),  -- tech04      -> Technician
(5,  3),  -- viewer01    -> Viewer
(6,  3),  -- viewer02    -> Viewer
(7,  3),  -- viewer03    -> Viewer
(8,  3),  -- viewer04    -> Viewer
(9,  3),  -- viewer05    -> Viewer
(10, 3),  -- viewer06    -> Viewer
(12, 3),  -- viewer07    -> Viewer
(13, 3),  -- viewer08    -> Viewer
(14, 3),  -- viewer09    -> Viewer
(15, 3);  -- viewer10    -> Viewer
GO

-- =====================
-- Room (15 rows)
-- =====================
INSERT INTO Room (room_name, building, floor, capacity) VALUES
('A101', 'Building A', 1, 40),
('A102', 'Building A', 1, 35),
('A201', 'Building A', 2, 40),
('A202', 'Building A', 2, 30),
('A301', 'Building A', 3, 25),
('B101', 'Building B', 1, 50),
('B102', 'Building B', 1, 45),
('B201', 'Building B', 2, 40),
('B202', 'Building B', 2, 35),
('C101', 'Building C', 1, 60),
('C201', 'Building C', 2, 55),
('C301', 'Building C', 3, 50),
('ServerRoom-A', 'Building A', 0, 10),
('ServerRoom-B', 'Building B', 0, 10),
('LabNetwork',   'Building C', 1, 30);
GO

-- =====================
-- Router (15 rows)
-- =====================
INSERT INTO Router (router_name, ip_address, mac_address, model, firmware, status, location, room_id) VALUES
('Core-Router-01',   '10.0.0.1',    'AA:00:00:00:00:01', 'Cisco ASR 1001',   '16.9',  'ONLINE',      'ServerRoom-A', 13),
('Core-Router-02',   '10.0.0.2',    'AA:00:00:00:00:02', 'Cisco ASR 1001',   '16.9',  'ONLINE',      'ServerRoom-B', 14),
('BldA-Router-01',   '192.168.1.1', 'AA:00:00:00:01:01', 'Cisco 2901',       '15.7',  'ONLINE',      'Building A',   NULL),
('BldA-Router-02',   '192.168.1.2', 'AA:00:00:00:01:02', 'Cisco 2901',       '15.7',  'ONLINE',      'Building A',   NULL),
('BldB-Router-01',   '192.168.2.1', 'AA:00:00:00:02:01', 'MikroTik RB750',   '6.49',  'ONLINE',      'Building B',   NULL),
('BldB-Router-02',   '192.168.2.2', 'AA:00:00:00:02:02', 'MikroTik RB750',   '6.49',  'ONLINE',      'Building B',   NULL),
('BldC-Router-01',   '192.168.3.1', 'AA:00:00:00:03:01', 'TP-Link TL-R600',  '1.3',   'ONLINE',      'Building C',   NULL),
('BldC-Router-02',   '192.168.3.2', 'AA:00:00:00:03:02', 'TP-Link TL-R600',  '1.3',   'MAINTENANCE', 'Building C',   NULL),
('Lab-Router-01',    '192.168.4.1', 'AA:00:00:00:04:01', 'Cisco 1941',       '15.5',  'ONLINE',      'LabNetwork',   15),
('Lab-Router-02',    '192.168.4.2', 'AA:00:00:00:04:02', 'Cisco 1941',       '15.5',  'OFFLINE',     'LabNetwork',   15),
('BldA-Floor2-RT',   '192.168.1.3', 'AA:00:00:00:01:03', 'Ubiquiti ER-X',    '2.0',   'ONLINE',      'Building A',   NULL),
('BldA-Floor3-RT',   '192.168.1.4', 'AA:00:00:00:01:04', 'Ubiquiti ER-X',    '2.0',   'ONLINE',      'Building A',   NULL),
('BldB-Floor2-RT',   '192.168.2.3', 'AA:00:00:00:02:03', 'Ubiquiti ER-X',    '2.0',   'ONLINE',      'Building B',   NULL),
('BldC-Floor2-RT',   '192.168.3.3', 'AA:00:00:00:03:03', 'Ubiquiti ER-X',    '2.0',   'ONLINE',      'Building C',   NULL),
('Backup-Router-01', '10.0.1.1',    'AA:00:00:00:FF:01', 'Cisco 2911',       '15.6',  'OFFLINE',     'ServerRoom-A', 13);
GO

-- =====================
-- AccessPoint (15 rows)
-- =====================
INSERT INTO AccessPoint (ap_name, ssid, ip_address, connected_users, status, location, room_id) VALUES
('AP-A1-01', 'UniWiFi-A1', '192.168.10.11', 22, 'ONLINE', 'Building A Room A101', 1),
('AP-A1-02', 'UniWiFi-A1', '192.168.10.12', 18, 'ONLINE', 'Building A Room A102', 2),
('AP-A2-01', 'UniWiFi-A2', '192.168.10.21', 30, 'ONLINE', 'Building A Room A201', 3),
('AP-A2-02', 'UniWiFi-A2', '192.168.10.22', 15, 'ONLINE', 'Building A Room A202', 4),
('AP-A3-01', 'UniWiFi-A3', '192.168.10.31',  8, 'ONLINE', 'Building A Room A301', 5),
('AP-B1-01', 'UniWiFi-B1', '192.168.10.41', 40, 'ONLINE', 'Building B Room B101', 6),
('AP-B1-02', 'UniWiFi-B1', '192.168.10.42', 35, 'ONLINE', 'Building B Room B102', 7),
('AP-B2-01', 'UniWiFi-B2', '192.168.10.51', 20, 'ONLINE', 'Building B Room B201', 8),
('AP-B2-02', 'UniWiFi-B2', '192.168.10.52',  5, 'OFFLINE','Building B Room B202', 9),
('AP-C1-01', 'UniWiFi-C1', '192.168.10.61', 50, 'ONLINE', 'Building C Room C101', 10),
('AP-C2-01', 'UniWiFi-C2', '192.168.10.71', 45, 'ONLINE', 'Building C Room C201', 11),
('AP-C3-01', 'UniWiFi-C3', '192.168.10.81', 28, 'ONLINE', 'Building C Room C301', 12),
('AP-Lab-01','UniWiFi-Lab','192.168.10.91', 12, 'ONLINE', 'LabNetwork',           15),
('AP-Lab-02','UniWiFi-Lab','192.168.10.92',  6, 'ONLINE', 'LabNetwork',           15),
('AP-Srv-01','UniWiFi-Srv','192.168.10.99',  2, 'ONLINE', 'Server Room',          13);
GO

-- =====================
-- Switch (15 rows)
-- =====================
INSERT INTO [Switch] (switch_name, total_ports, used_ports, ip_address, status, room_id) VALUES
('SW-Core-01',   48, 40, '10.0.2.1',      'ONLINE',      13),
('SW-Core-02',   48, 38, '10.0.2.2',      'ONLINE',      14),
('SW-A1-01',     24, 18, '192.168.20.11', 'ONLINE',       1),
('SW-A1-02',     24, 12, '192.168.20.12', 'ONLINE',       2),
('SW-A2-01',     24, 20, '192.168.20.21', 'ONLINE',       3),
('SW-A3-01',     16,  8, '192.168.20.31', 'ONLINE',       5),
('SW-B1-01',     48, 36, '192.168.20.41', 'ONLINE',       6),
('SW-B1-02',     48, 30, '192.168.20.42', 'ONLINE',       7),
('SW-B2-01',     24, 15, '192.168.20.51', 'ONLINE',       8),
('SW-B2-02',     24,  5, '192.168.20.52', 'MAINTENANCE',  9),
('SW-C1-01',     48, 42, '192.168.20.61', 'ONLINE',      10),
('SW-C2-01',     48, 38, '192.168.20.71', 'ONLINE',      11),
('SW-C3-01',     24, 20, '192.168.20.81', 'ONLINE',      12),
('SW-Lab-01',    24, 14, '192.168.20.91', 'ONLINE',      15),
('SW-Srv-01',    16, 10, '192.168.20.99', 'ONLINE',      13);
GO

-- =====================
-- NetworkDevice (15 rows)
-- =====================
INSERT INTO NetworkDevice (device_name, mac_address, ip_address, owner, device_type, status, room_id) VALUES
('Laptop-NguyenVanAn',   'CC:00:00:00:01:01', '192.168.30.11', 'Nguyen Van An',    'Laptop',     'ALLOWED',  1),
('Laptop-TranMinhDuc',   'CC:00:00:00:01:02', '192.168.30.12', 'Tran Minh Duc',    'Laptop',     'ALLOWED',  1),
('Phone-LeThiHoa',       'CC:00:00:00:02:01', '192.168.30.21', 'Le Thi Hoa',       'Smartphone', 'ALLOWED',  3),
('Laptop-PhamQuocBao',   'CC:00:00:00:02:02', '192.168.30.22', 'Pham Quoc Bao',    'Laptop',     'ALLOWED',  3),
('Tablet-HoangThiMai',   'CC:00:00:00:03:01', '192.168.30.31', 'Hoang Thi Mai',    'Tablet',     'ALLOWED',  6),
('Laptop-VuThanhLong',   'CC:00:00:00:03:02', '192.168.30.32', 'Vu Thanh Long',    'Laptop',     'ALLOWED',  6),
('Phone-DangThiThu',     'CC:00:00:00:04:01', '192.168.30.41', 'Dang Thi Thu',     'Smartphone', 'ALLOWED',  8),
('Laptop-BuiVanKhanh',   'CC:00:00:00:04:02', '192.168.30.42', 'Bui Van Khanh',    'Laptop',     'ALLOWED',  8),
('Desktop-NgoThiLan',    'CC:00:00:00:05:01', '192.168.30.51', 'Ngo Thi Lan',      'Desktop',    'ALLOWED', 10),
('Laptop-DinhVanPhuc',   'CC:00:00:00:05:02', '192.168.30.52', 'Dinh Van Phuc',    'Laptop',     'ALLOWED', 10),
('Phone-TruongThiNgoc',  'CC:00:00:00:06:01', '192.168.30.61', 'Truong Thi Ngoc',  'Smartphone', 'BLOCKED', 11),
('Laptop-CaoVanHieu',    'CC:00:00:00:06:02', '192.168.30.62', 'Cao Van Hieu',     'Laptop',     'ALLOWED', 11),
('Tablet-LamThiPhuong',  'CC:00:00:00:07:01', '192.168.30.71', 'Lam Thi Phuong',   'Tablet',     'ALLOWED', 15),
('Laptop-MaiVanThanh',   'CC:00:00:00:07:02', '192.168.30.72', 'Mai Van Thanh',    'Laptop',     'ALLOWED', 15),
('Unknown-Device-01',    'CC:00:00:00:FF:01', '192.168.30.99', 'Unknown',          'Unknown',    'BLOCKED',  1);
GO

-- =====================
-- VLAN (15 rows)
-- =====================
INSERT INTO VLAN (vlan_name, subnet, purpose, room_id) VALUES
('VLAN-Admin',      '10.0.0.0/24',     'Admin management network',        NULL),
('VLAN-Staff-A',    '192.168.1.0/24',  'Staff network Building A',        NULL),
('VLAN-Staff-B',    '192.168.2.0/24',  'Staff network Building B',        NULL),
('VLAN-Staff-C',    '192.168.3.0/24',  'Staff network Building C',        NULL),
('VLAN-Student-A1', '192.168.10.0/24', 'Student WiFi Building A Floor 1',  1),
('VLAN-Student-A2', '192.168.11.0/24', 'Student WiFi Building A Floor 2',  3),
('VLAN-Student-B1', '192.168.12.0/24', 'Student WiFi Building B Floor 1',  6),
('VLAN-Student-B2', '192.168.13.0/24', 'Student WiFi Building B Floor 2',  8),
('VLAN-Student-C1', '192.168.14.0/24', 'Student WiFi Building C Floor 1', 10),
('VLAN-Lab',        '192.168.20.0/24', 'Lab network',                     15),
('VLAN-Server',     '10.0.1.0/24',     'Server infrastructure',           13),
('VLAN-CCTV',       '172.16.0.0/24',   'Security camera network',         NULL),
('VLAN-Printer',    '172.16.1.0/24',   'Printer network',                 NULL),
('VLAN-Guest',      '192.168.99.0/24', 'Guest WiFi isolated network',     NULL),
('VLAN-IoT',        '172.16.2.0/24',   'IoT device network',              NULL);
GO

-- =====================
-- IPAddressManagement (15 rows)
-- =====================
INSERT INTO IPAddressManagement (ip_address, status, device_id) VALUES
('192.168.30.11', 'ASSIGNED',  1),
('192.168.30.12', 'ASSIGNED',  2),
('192.168.30.21', 'ASSIGNED',  3),
('192.168.30.22', 'ASSIGNED',  4),
('192.168.30.31', 'ASSIGNED',  5),
('192.168.30.32', 'ASSIGNED',  6),
('192.168.30.41', 'ASSIGNED',  7),
('192.168.30.42', 'ASSIGNED',  8),
('192.168.30.51', 'ASSIGNED',  9),
('192.168.30.52', 'ASSIGNED', 10),
('192.168.30.61', 'ASSIGNED', 11),
('192.168.30.62', 'ASSIGNED', 12),
('192.168.30.71', 'ASSIGNED', 13),
('192.168.30.72', 'ASSIGNED', 14),
('192.168.30.99', 'ASSIGNED', 15);
GO

-- =====================
-- BandwidthUsage (15 rows — spread across devices)
-- =====================
INSERT INTO BandwidthUsage (upload_speed, download_speed, record_time, device_id) VALUES
(45.2,  120.5, DATEADD(MINUTE, -90, GETDATE()),  1),
(38.7,   95.3, DATEADD(MINUTE, -85, GETDATE()),  2),
(22.1,   55.8, DATEADD(MINUTE, -80, GETDATE()),  3),
(60.4,  180.2, DATEADD(MINUTE, -75, GETDATE()),  4),
(15.3,   40.1, DATEADD(MINUTE, -70, GETDATE()),  5),
(80.0,  250.0, DATEADD(MINUTE, -65, GETDATE()),  6),
(12.5,   30.7, DATEADD(MINUTE, -60, GETDATE()),  7),
(55.9,  140.3, DATEADD(MINUTE, -55, GETDATE()),  8),
(90.1,  300.5, DATEADD(MINUTE, -50, GETDATE()),  9),
(25.4,   70.2, DATEADD(MINUTE, -45, GETDATE()), 10),
( 5.1,   10.3, DATEADD(MINUTE, -40, GETDATE()), 11),
(70.3,  200.1, DATEADD(MINUTE, -35, GETDATE()), 12),
(33.6,   88.4, DATEADD(MINUTE, -30, GETDATE()), 13),
(48.2,  130.7, DATEADD(MINUTE, -25, GETDATE()), 14),
(18.9,   50.6, DATEADD(MINUTE, -20, GETDATE()),  1);
GO

-- =====================
-- WiFiAnalytics (15 rows — different APs and dates)
-- =====================
INSERT INTO WiFiAnalytics (total_users, peak_users, avg_speed, analytics_date, ap_id) VALUES
(22, 35,  85.5, CAST(DATEADD(DAY,  -14, GETDATE()) AS DATE),  1),
(18, 28,  72.3, CAST(DATEADD(DAY,  -13, GETDATE()) AS DATE),  2),
(30, 45,  90.1, CAST(DATEADD(DAY,  -12, GETDATE()) AS DATE),  3),
(15, 22,  65.8, CAST(DATEADD(DAY,  -11, GETDATE()) AS DATE),  4),
( 8, 12,  50.2, CAST(DATEADD(DAY,  -10, GETDATE()) AS DATE),  5),
(40, 58, 110.4, CAST(DATEADD(DAY,   -9, GETDATE()) AS DATE),  6),
(35, 50,  95.7, CAST(DATEADD(DAY,   -8, GETDATE()) AS DATE),  7),
(20, 30,  78.3, CAST(DATEADD(DAY,   -7, GETDATE()) AS DATE),  8),
( 5,  8,  40.1, CAST(DATEADD(DAY,   -6, GETDATE()) AS DATE),  9),
(50, 70, 125.6, CAST(DATEADD(DAY,   -5, GETDATE()) AS DATE), 10),
(45, 62, 115.2, CAST(DATEADD(DAY,   -4, GETDATE()) AS DATE), 11),
(28, 40,  88.9, CAST(DATEADD(DAY,   -3, GETDATE()) AS DATE), 12),
(12, 18,  60.4, CAST(DATEADD(DAY,   -2, GETDATE()) AS DATE), 13),
( 6, 10,  45.3, CAST(DATEADD(DAY,   -1, GETDATE()) AS DATE), 14),
( 2,  4,  30.0, CAST(GETDATE() AS DATE),                      15);
GO

-- =====================
-- NetworkAlert (15 rows — mix of router/ap/switch)
-- =====================
INSERT INTO NetworkAlert (alert_type, message, severity, router_id, ap_id, switch_id) VALUES
('OUTAGE',      'Core-Router-02 lost uplink connection',       'CRITICAL', 2,    NULL, NULL),
('OUTAGE',      'AP-B2-02 went offline unexpectedly',          'CRITICAL', NULL, 9,    NULL),
('OUTAGE',      'SW-B2-02 unresponsive after power fluctuation','CRITICAL', NULL, NULL, 10),
('PERFORMANCE', 'High CPU usage on BldA-Router-01',            'WARNING',  3,    NULL, NULL),
('PERFORMANCE', 'AP-C1-01 exceeding max connected users',      'WARNING',  NULL, 10,   NULL),
('PERFORMANCE', 'SW-Core-01 bandwidth usage above 90%',        'WARNING',  NULL, NULL, 1),
('PERFORMANCE', 'Lab-Router-02 packet loss detected',          'WARNING',  10,   NULL, NULL),
('SECURITY',    'Unknown device detected on VLAN-Student-A1',  'CRITICAL', NULL, 1,    NULL),
('SECURITY',    'Multiple failed logins via BldB-Router-01',   'WARNING',  5,    NULL, NULL),
('CONFIG',      'BldC-Router-02 firmware outdated',            'INFO',     8,    NULL, NULL),
('CONFIG',      'AP-A3-01 SSID broadcast disabled',            'INFO',     NULL, 5,    NULL),
('CONFIG',      'SW-A3-01 port configuration mismatch',        'INFO',     NULL, NULL, 6),
('OUTAGE',      'Backup-Router-01 offline — no failover active','WARNING',  15,   NULL, NULL),
('PERFORMANCE', 'AP-Lab-01 average speed dropped below 30 Mbps','WARNING', NULL, 13,   NULL),
('SECURITY',    'SW-C1-01 detected MAC flooding attempt',      'CRITICAL', NULL, NULL, 11);
GO

-- =====================
-- SupportTicket (15 rows)
-- =====================
INSERT INTO SupportTicket (title, description, status, created_by, device_id) VALUES
('WiFi slow in A101',            'Students report low speed during peak hours',          'OPEN',        5,  NULL),
('Cannot connect to UniWiFi-B1', 'Phone unable to authenticate on B1 network',           'IN_PROGRESS', 6,  3),
('Eduroam auth failure',         'eduroam SSID returns 802.1X error',                   'OPEN',        7,  NULL),
('IP conflict in Lab',           'Two devices assigned same IP 192.168.30.71',           'RESOLVED',    8,  13),
('Laptop blocked unexpectedly',  'Laptop CC:00:FF was blocked without notice',           'OPEN',        9,  2),
('Switch port not working',      'Port 12 on SW-A1-01 has no link',                     'IN_PROGRESS', 10, NULL),
('No signal in A301',            'AP-A3-01 signal very weak at far end of room',         'OPEN',        5,  NULL),
('Router reboot loop',           'Lab-Router-02 keeps rebooting every 10 minutes',       'RESOLVED',    6,  NULL),
('VLAN misconfiguration',        'Devices on VLAN-Lab cannot reach VLAN-Server',         'OPEN',        7,  NULL),
('Unknown device alert',         'Unknown-Device-01 appeared on network, please check',  'IN_PROGRESS', 8,  15),
('Bandwidth throttled',          'Download speed capped at 10 Mbps on device',           'OPEN',        9,  8),
('AP offline B202',              'AP-B2-02 has been offline since this morning',         'OPEN',        10, NULL),
('Cannot print via network',     'Printer unreachable from VLAN-Staff-A',               'RESOLVED',    5,  NULL),
('Slow connection C301',         'Intermittent packet drops on floor 3 Building C',      'OPEN',        6,  NULL),
('MAC address blocked',          'My device MAC CC:00:00:00:06:01 was blocked',          'IN_PROGRESS', 7,  11);
GO

-- =====================
-- MaintenanceSchedule (15 rows)
-- =====================
INSERT INTO MaintenanceSchedule (title, description, start_time, end_time, status) VALUES
('Core Router firmware upgrade',    'Upgrade Core-Router-01 and 02 to latest IOS',       '2026-06-01 22:00', '2026-06-02 01:00', 'PLANNED'),
('BldA switch replacement',         'Replace SW-A1-02 with new 48-port unit',             '2026-06-03 08:00', '2026-06-03 12:00', 'PLANNED'),
('AP-B2-02 hardware inspection',    'Inspect and repair AP-B2-02 after outage',           '2026-05-28 09:00', '2026-05-28 11:00', 'COMPLETED'),
('Lab router reboot maintenance',   'Scheduled reboot for Lab-Router-02 after patch',     '2026-05-27 22:00', '2026-05-27 23:00', 'COMPLETED'),
('BldC router firmware update',     'Update BldC-Router-02 firmware to fix CVE-2026-001', '2026-06-05 20:00', '2026-06-05 22:00', 'PLANNED'),
('SW-B2-02 power check',            'Inspect UPS and power supply for SW-B2-02',          '2026-06-04 14:00', '2026-06-04 16:00', 'PLANNED'),
('Network cable audit Building A',  'Full cable inspection and labeling in Building A',   '2026-06-07 08:00', '2026-06-07 17:00', 'PLANNED'),
('AP firmware batch update',        'Update all APs to firmware v3.2.1',                  '2026-06-08 22:00', '2026-06-09 02:00', 'PLANNED'),
('Backup router activation test',   'Test failover with Backup-Router-01',               '2026-06-10 10:00', '2026-06-10 12:00', 'PLANNED'),
('SW-Core-01 port audit',           'Audit and clean up unused ports on SW-Core-01',      '2026-06-06 09:00', '2026-06-06 11:00', 'PLANNED'),
('VLAN reconfiguration Lab',        'Reconfigure VLAN-Lab to support new subnet',         '2026-06-11 20:00', '2026-06-11 23:00', 'PLANNED'),
('BldB AP signal survey',           'Conduct wireless site survey in Building B',         '2026-06-12 08:00', '2026-06-12 17:00', 'PLANNED'),
('Server room cooling check',       'Inspect cooling system in ServerRoom-A',             '2026-05-30 10:00', '2026-05-30 12:00', 'IN_PROGRESS'),
('IP address pool cleanup',         'Remove stale DHCP leases and update IP table',       '2026-06-02 09:00', '2026-06-02 11:00', 'PLANNED'),
('Security patch all switches',     'Apply security patch to all switches',               '2026-06-15 22:00', '2026-06-16 02:00', 'PLANNED');
GO

-- =====================
-- MaintenanceRouter (15 rows)
-- =====================
INSERT INTO MaintenanceRouter (maintenance_id, router_id) VALUES
(1,  1),   -- Core firmware -> Core-Router-01
(1,  2),   -- Core firmware -> Core-Router-02
(4,  10),  -- Lab reboot    -> Lab-Router-02
(5,  8),   -- BldC firmware -> BldC-Router-02
(9,  15),  -- Backup test   -> Backup-Router-01
(3,  7),   -- AP inspection (router side) -> BldC-Router-01
(6,  5),   -- SW power check (router side) -> BldB-Router-01
(7,  3),   -- Cable audit   -> BldA-Router-01
(7,  4),   -- Cable audit   -> BldA-Router-02
(10, 1),   -- Port audit    -> Core-Router-01
(11, 9),   -- VLAN reconfig -> Lab-Router-01
(12, 6),   -- Site survey   -> BldB-Router-02
(13, 15),  -- Server room   -> Backup-Router-01 (nằm trong ServerRoom-A)
(14, 3),   -- IP cleanup    -> BldA-Router-01
(15, 2);   -- Security patch -> Core-Router-02
GO

-- =====================
-- MaintenanceAccessPoint (15 rows)
-- =====================
INSERT INTO MaintenanceAccessPoint (maintenance_id, ap_id) VALUES
(3,  9),   -- AP-B2-02 inspection
(8,  1),   -- Batch AP update -> AP-A1-01
(8,  2),   -- Batch AP update -> AP-A1-02
(8,  3),   -- Batch AP update -> AP-A2-01
(8,  6),   -- Batch AP update -> AP-B1-01
(8,  10),  -- Batch AP update -> AP-C1-01
(12, 6),   -- BldB survey -> AP-B1-01
(12, 7),   -- BldB survey -> AP-B1-02
(12, 8),   -- BldB survey -> AP-B2-01
(12, 9),   -- BldB survey -> AP-B2-02
(7,  1),   -- Cable audit -> AP-A1-01
(7,  3),   -- Cable audit -> AP-A2-01
(11, 13),  -- VLAN reconfig -> AP-Lab-01
(14, 15),  -- IP cleanup -> AP-Srv-01
(9,  13);  -- Backup test -> AP-Lab-01
GO

-- =====================
-- MaintenanceSwitch (15 rows)
-- =====================
INSERT INTO MaintenanceSwitch (maintenance_id, switch_id) VALUES
(2,  4),   -- BldA replacement -> SW-A1-02
(6,  10),  -- SW-B2-02 power check
(10, 1),   -- SW-Core-01 port audit
(15, 1),   -- Security patch -> SW-Core-01
(15, 2),   -- Security patch -> SW-Core-02
(15, 3),   -- Security patch -> SW-A1-01
(15, 7),   -- Security patch -> SW-B1-01
(15, 11),  -- Security patch -> SW-C1-01
(7,  3),   -- Cable audit -> SW-A1-01
(7,  4),   -- Cable audit -> SW-A1-02
(11, 14),  -- VLAN reconfig -> SW-Lab-01
(12, 7),   -- BldB survey -> SW-B1-01
(12, 8),   -- BldB survey -> SW-B1-02
(13, 15),  -- Server room -> SW-Srv-01
(14, 3);   -- IP cleanup -> SW-A1-01
GO

-- =====================
-- AuthenticationLog (15 rows)
-- =====================
INSERT INTO AuthenticationLog (username, login_status, ip_address, user_id) VALUES
('admin',    'SUCCESS', '192.168.1.100',  1),
('tech01',   'SUCCESS', '192.168.1.101',  2),
('tech02',   'SUCCESS', '192.168.2.101',  3),
('tech03',   'SUCCESS', '192.168.2.102',  4),
('viewer01', 'SUCCESS', '192.168.3.101',  5),
('viewer02', 'SUCCESS', '192.168.3.102',  6),
('viewer03', 'SUCCESS', '192.168.10.50',  7),
('admin',    'SUCCESS', '192.168.1.100',  1),
('tech01',   'FAILED',  '192.168.1.101',  NULL),
('hacker01', 'FAILED',  '10.10.10.1',     NULL),
('hacker01', 'FAILED',  '10.10.10.1',     NULL),
('hacker02', 'FAILED',  '10.10.10.2',     NULL),
('viewer07', 'SUCCESS', '192.168.3.107',  12),
('tech04',   'SUCCESS', '192.168.2.111',  11),
('unknown',  'FAILED',  '172.16.99.1',    NULL);
GO

-- =====================
-- SystemLog (15 rows)
-- =====================
INSERT INTO SystemLog (action, details, performed_by) VALUES
('LOGIN',           'Admin logged in from 192.168.1.100',                    1),
('LOGIN',           'tech01 logged in from 192.168.1.101',                   2),
('UPDATE_DEVICE',   'Updated AP-B2-02 status to OFFLINE',                    2),
('UPDATE_DEVICE',   'Updated SW-B2-02 status to MAINTENANCE',                3),
('CREATE_ALERT',    'Generated CRITICAL alert for Core-Router-02 outage',     1),
('CREATE_TICKET',   'Support ticket created: WiFi slow in A101',              5),
('RESOLVE_TICKET',  'Ticket ID 4 resolved: IP conflict fixed in Lab',         2),
('UPDATE_ROUTER',   'Updated BldC-Router-02 firmware to 1.3.1',              4),
('CREATE_SCHEDULE', 'Maintenance scheduled: Core Router firmware upgrade',    1),
('BLOCK_DEVICE',    'Device CC:00:00:00:FF:01 blocked — unknown MAC',         2),
('BLOCK_DEVICE',    'Device CC:00:00:00:06:01 blocked — policy violation',    3),
('UPDATE_VLAN',     'VLAN-Lab subnet updated to 192.168.20.0/24',             1),
('DELETE_IP',       'Stale IP 192.168.30.99 flagged for review',              4),
('LOGIN',           'tech04 logged in from 192.168.2.111',                   11),
('LOGOUT',          'Admin session closed after 2h inactivity',               1);
GO

