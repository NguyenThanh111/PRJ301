IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'network_simulation_db3')
    CREATE DATABASE network_simulation_db3;
GO

USE network_simulation_db3;
GO

CREATE TABLE Role (
    role_id     INT IDENTITY(1,1) PRIMARY KEY,
    role_name   VARCHAR(50) NOT NULL UNIQUE,
    description NVARCHAR(255)
);
GO

CREATE TABLE [User] (
    user_id   INT IDENTITY(1,1) PRIMARY KEY,
    username  VARCHAR(50)  NOT NULL UNIQUE,
    password  VARCHAR(255) NOT NULL,
    full_name NVARCHAR(100) NOT NULL,
    email     VARCHAR(100),
    status    VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
);
GO

CREATE TABLE UserRole (
    user_id     INT NOT NULL,
    role_id     INT NOT NULL,
    assigned_at DATETIME NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_userrole_user FOREIGN KEY (user_id) REFERENCES [User](user_id) ON DELETE CASCADE,
    CONSTRAINT fk_userrole_role FOREIGN KEY (role_id) REFERENCES Role(role_id)
);
GO

CREATE TABLE Room (
    room_id   INT IDENTITY(1,1) PRIMARY KEY,
    room_name NVARCHAR(100) NOT NULL,
    building  NVARCHAR(100),
    floor     INT DEFAULT 1,
    capacity  INT DEFAULT 0
);
GO

CREATE TABLE Router (
    router_id   INT IDENTITY(1,1) PRIMARY KEY,
    router_name NVARCHAR(100) NOT NULL,
    ip_address  VARCHAR(45) UNIQUE,
    mac_address VARCHAR(50) UNIQUE,
    model       NVARCHAR(100),
    firmware    VARCHAR(100),
    status      VARCHAR(30) NOT NULL DEFAULT 'ONLINE',
    location    NVARCHAR(150),
    room_id     INT,
    CONSTRAINT fk_router_room FOREIGN KEY (room_id) REFERENCES Room(room_id)
);
GO

CREATE TABLE AccessPoint (
    ap_id           INT IDENTITY(1,1) PRIMARY KEY,
    ap_name         NVARCHAR(100) NOT NULL,
    ssid            NVARCHAR(100),
    ip_address      VARCHAR(45) UNIQUE,
    connected_users INT NOT NULL DEFAULT 0,
    status          VARCHAR(30) NOT NULL DEFAULT 'ONLINE',
    location        NVARCHAR(150),
    room_id         INT,
    CONSTRAINT fk_ap_room FOREIGN KEY (room_id) REFERENCES Room(room_id)
);
GO

CREATE TABLE [Switch] (
    switch_id   INT IDENTITY(1,1) PRIMARY KEY,
    switch_name NVARCHAR(100) NOT NULL,
    total_ports INT NOT NULL DEFAULT 0,
    used_ports  INT NOT NULL DEFAULT 0,
    ip_address  VARCHAR(45) UNIQUE,
    status      VARCHAR(30) NOT NULL DEFAULT 'ONLINE',
    room_id     INT,
    CONSTRAINT fk_switch_room FOREIGN KEY (room_id) REFERENCES Room(room_id)
);
GO

CREATE TABLE NetworkDevice (
    device_id   INT IDENTITY(1,1) PRIMARY KEY,
    device_name NVARCHAR(100) NOT NULL,
    mac_address VARCHAR(50) UNIQUE,
    ip_address  VARCHAR(45),
    owner       NVARCHAR(100),
    device_type NVARCHAR(50),
    status      VARCHAR(30) NOT NULL DEFAULT 'ALLOWED',
    room_id     INT,
    CONSTRAINT fk_device_room FOREIGN KEY (room_id) REFERENCES Room(room_id)
);
GO

CREATE TABLE VLAN (
    vlan_id   INT IDENTITY(1,1) PRIMARY KEY,
    vlan_name NVARCHAR(100) NOT NULL,
    subnet    VARCHAR(50),
    purpose   NVARCHAR(255),
    room_id   INT,
    CONSTRAINT fk_vlan_room FOREIGN KEY (room_id) REFERENCES Room(room_id)
);
GO

CREATE TABLE IPAddressManagement (
    ip_id      INT IDENTITY(1,1) PRIMARY KEY,
    ip_address VARCHAR(45) NOT NULL UNIQUE,
    status     VARCHAR(30) NOT NULL DEFAULT 'AVAILABLE',
    device_id  INT UNIQUE,
    CONSTRAINT fk_ip_device FOREIGN KEY (device_id) REFERENCES NetworkDevice(device_id)
);
GO

CREATE TABLE BandwidthUsage (
    usage_id       INT IDENTITY(1,1) PRIMARY KEY,
    upload_speed   FLOAT NOT NULL DEFAULT 0,
    download_speed FLOAT NOT NULL DEFAULT 0,
    record_time    DATETIME NOT NULL DEFAULT GETDATE(),
    device_id      INT NOT NULL,
    CONSTRAINT fk_bandwidth_device FOREIGN KEY (device_id) REFERENCES NetworkDevice(device_id)
);
GO

CREATE TABLE WiFiAnalytics (
    analytics_id   INT IDENTITY(1,1) PRIMARY KEY,
    total_users    INT NOT NULL DEFAULT 0,
    peak_users     INT NOT NULL DEFAULT 0,
    avg_speed      FLOAT NOT NULL DEFAULT 0,
    analytics_date DATE NOT NULL,
    ap_id          INT NOT NULL,
    CONSTRAINT fk_wifi_ap FOREIGN KEY (ap_id) REFERENCES AccessPoint(ap_id)
);
GO

CREATE TABLE NetworkAlert (
    alert_id   INT IDENTITY(1,1) PRIMARY KEY,
    alert_type NVARCHAR(50) NOT NULL,
    message    NVARCHAR(255) NOT NULL,
    severity   VARCHAR(20) NOT NULL DEFAULT 'INFO',
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    router_id  INT,
    ap_id      INT,
    switch_id  INT,
    CONSTRAINT fk_alert_router FOREIGN KEY (router_id) REFERENCES Router(router_id),
    CONSTRAINT fk_alert_ap FOREIGN KEY (ap_id) REFERENCES AccessPoint(ap_id),
    CONSTRAINT fk_alert_switch FOREIGN KEY (switch_id) REFERENCES [Switch](switch_id)
);
GO

CREATE TABLE SupportTicket (
    ticket_id    INT IDENTITY(1,1) PRIMARY KEY,
    title        NVARCHAR(150) NOT NULL,
    description  NVARCHAR(MAX),
    status       VARCHAR(30) NOT NULL DEFAULT 'OPEN',
    created_date DATETIME NOT NULL DEFAULT GETDATE(),
    created_by   INT NOT NULL,
    device_id    INT,
    CONSTRAINT fk_ticket_user FOREIGN KEY (created_by) REFERENCES [User](user_id),
    CONSTRAINT fk_ticket_device FOREIGN KEY (device_id) REFERENCES NetworkDevice(device_id)
);
GO

CREATE TABLE MaintenanceSchedule (
    maintenance_id INT IDENTITY(1,1) PRIMARY KEY,
    title          NVARCHAR(150) NOT NULL,
    description    NVARCHAR(MAX),
    start_time     DATETIME NOT NULL,
    end_time       DATETIME,
    status         VARCHAR(30) NOT NULL DEFAULT 'PLANNED'
);
GO

CREATE TABLE MaintenanceRouter (
    maintenance_id INT NOT NULL,
    router_id      INT NOT NULL,
    PRIMARY KEY (maintenance_id, router_id),
    CONSTRAINT fk_maintrouter_maint FOREIGN KEY (maintenance_id) REFERENCES MaintenanceSchedule(maintenance_id) ON DELETE CASCADE,
    CONSTRAINT fk_maintrouter_router FOREIGN KEY (router_id) REFERENCES Router(router_id)
);
GO

CREATE TABLE MaintenanceAccessPoint (
    maintenance_id INT NOT NULL,
    ap_id          INT NOT NULL,
    PRIMARY KEY (maintenance_id, ap_id),
    CONSTRAINT fk_maintap_maint FOREIGN KEY (maintenance_id) REFERENCES MaintenanceSchedule(maintenance_id) ON DELETE CASCADE,
    CONSTRAINT fk_maintap_ap FOREIGN KEY (ap_id) REFERENCES AccessPoint(ap_id)
);
GO

CREATE TABLE MaintenanceSwitch (
    maintenance_id INT NOT NULL,
    switch_id      INT NOT NULL,
    PRIMARY KEY (maintenance_id, switch_id),
    CONSTRAINT fk_maintswitch_maint FOREIGN KEY (maintenance_id) REFERENCES MaintenanceSchedule(maintenance_id) ON DELETE CASCADE,
    CONSTRAINT fk_maintswitch_switch FOREIGN KEY (switch_id) REFERENCES [Switch](switch_id)
);
GO

CREATE TABLE AuthenticationLog (
    log_id       INT IDENTITY(1,1) PRIMARY KEY,
    username     VARCHAR(50) NOT NULL,
    login_status VARCHAR(20) NOT NULL,
    ip_address   VARCHAR(45),
    login_time   DATETIME NOT NULL DEFAULT GETDATE(),
    user_id      INT,
    CONSTRAINT fk_authlog_user FOREIGN KEY (user_id) REFERENCES [User](user_id)
);
GO

CREATE TABLE SystemLog (
    log_id       INT IDENTITY(1,1) PRIMARY KEY,
    action       NVARCHAR(100) NOT NULL,
    created_at   DATETIME NOT NULL DEFAULT GETDATE(),
    details      NVARCHAR(MAX),
    performed_by INT,
    CONSTRAINT fk_syslog_user FOREIGN KEY (performed_by) REFERENCES [User](user_id)
);
GO

INSERT INTO Role (role_name, description) VALUES
('Admin',      N'Toàn quyền truy cập hệ thống'),
('Technician', N'Quản lý, bảo trì và hỗ trợ thiết bị mạng'),
('Viewer',     N'Chỉ được xem thông tin và sử dụng chức năng cơ bản');
GO

INSERT INTO [User] (username, password, full_name, email, status) VALUES
('admin',     'hashed_admin01',  N'Quản trị viên hệ thống', 'admin@university.edu', 'ACTIVE'),
('tech01',    'hashed_tech01',   N'Nguyễn Văn An',          'nv.an@university.edu', 'ACTIVE'),
('tech02',    'hashed_tech02',   N'Trần Minh Đức',          'tm.duc@university.edu', 'ACTIVE'),
('tech03',    'hashed_tech03',   N'Lê Thị Hoa',             'lt.hoa@university.edu', 'ACTIVE'),
('viewer01',  'hashed_view01',   N'Phạm Quốc Bảo',          'pq.bao@university.edu', 'ACTIVE'),
('viewer02',  'hashed_view02',   N'Hoàng Thị Mai',          'ht.mai@university.edu', 'ACTIVE'),
('viewer03',  'hashed_view03',   N'Vũ Thanh Long',          'vt.long@university.edu', 'ACTIVE'),
('viewer04',  'hashed_view04',   N'Đặng Thị Thu',           'dt.thu@university.edu', 'ACTIVE'),
('viewer05',  'hashed_view05',   N'Bùi Văn Khánh',          'bv.khanh@university.edu', 'ACTIVE'),
('viewer06',  'hashed_view06',   N'Ngô Thị Lan',            'nt.lan@university.edu', 'ACTIVE'),
('tech04',    'hashed_tech04',   N'Đinh Văn Phúc',          'dv.phuc@university.edu', 'ACTIVE'),
('viewer07',  'hashed_view07',   N'Trương Thị Ngọc',        'tt.ngoc@university.edu', 'INACTIVE'),
('viewer08',  'hashed_view08',   N'Cao Văn Hiếu',           'cv.hieu@university.edu', 'ACTIVE'),
('viewer09',  'hashed_view09',   N'Lâm Thị Phương',         'lt.phuong@university.edu', 'ACTIVE'),
('viewer10',  'hashed_view10',   N'Mai Văn Thành',          'mv.thanh@university.edu', 'INACTIVE');
GO

INSERT INTO UserRole (user_id, role_id) VALUES
(1, 1),
(2, 2),
(3, 2),
(4, 2),
(11, 2),
(5, 3),
(6, 3),
(7, 3),
(8, 3),
(9, 3),
(10, 3),
(12, 3),
(13, 3),
(14, 3),
(15, 3);
GO

INSERT INTO Room (room_name, building, floor, capacity) VALUES
(N'Phòng A101', N'Tòa nhà A', 1, 40),
(N'Phòng A102', N'Tòa nhà A', 1, 35),
(N'Phòng A201', N'Tòa nhà A', 2, 40),
(N'Phòng A202', N'Tòa nhà A', 2, 30),
(N'Phòng A301', N'Tòa nhà A', 3, 25),
(N'Phòng B101', N'Tòa nhà B', 1, 50),
(N'Phòng B102', N'Tòa nhà B', 1, 45),
(N'Phòng B201', N'Tòa nhà B', 2, 40),
(N'Phòng B202', N'Tòa nhà B', 2, 35),
(N'Phòng C101', N'Tòa nhà C', 1, 60),
(N'Phòng C201', N'Tòa nhà C', 2, 55),
(N'Phòng C301', N'Tòa nhà C', 3, 50),
(N'Phòng máy chủ A', N'Tòa nhà A', 0, 10),
(N'Phòng máy chủ B', N'Tòa nhà B', 0, 10),
(N'Phòng thực hành mạng', N'Tòa nhà C', 1, 30);
GO

INSERT INTO Router (router_name, ip_address, mac_address, model, firmware, status, location, room_id) VALUES
(N'Core-Router-01',   '10.0.0.1',    'AA:00:00:00:00:01', N'Cisco ASR 1001',   '16.9', 'ONLINE',      N'Phòng máy chủ A', 13),
(N'Core-Router-02',   '10.0.0.2',    'AA:00:00:00:00:02', N'Cisco ASR 1001',   '16.9', 'ONLINE',      N'Phòng máy chủ B', 14),
(N'BldA-Router-01',   '192.168.1.1', 'AA:00:00:00:01:01', N'Cisco 2901',       '15.7', 'ONLINE',      N'Tòa nhà A', NULL),
(N'BldA-Router-02',   '192.168.1.2', 'AA:00:00:00:01:02', N'Cisco 2901',       '15.7', 'ONLINE',      N'Tòa nhà A', NULL),
(N'BldB-Router-01',   '192.168.2.1', 'AA:00:00:00:02:01', N'MikroTik RB750',   '6.49', 'ONLINE',      N'Tòa nhà B', NULL),
(N'BldB-Router-02',   '192.168.2.2', 'AA:00:00:00:02:02', N'MikroTik RB750',   '6.49', 'ONLINE',      N'Tòa nhà B', NULL),
(N'BldC-Router-01',   '192.168.3.1', 'AA:00:00:00:03:01', N'TP-Link TL-R600',  '1.3',  'ONLINE',      N'Tòa nhà C', NULL),
(N'BldC-Router-02',   '192.168.3.2', 'AA:00:00:00:03:02', N'TP-Link TL-R600',  '1.3',  'MAINTENANCE', N'Tòa nhà C', NULL),
(N'Lab-Router-01',    '192.168.4.1', 'AA:00:00:00:04:01', N'Cisco 1941',       '15.5', 'ONLINE',      N'Phòng thực hành mạng', 15),
(N'Lab-Router-02',    '192.168.4.2', 'AA:00:00:00:04:02', N'Cisco 1941',       '15.5', 'OFFLINE',     N'Phòng thực hành mạng', 15),
(N'BldA-Floor2-RT',   '192.168.1.3', 'AA:00:00:00:01:03', N'Ubiquiti ER-X',    '2.0',  'ONLINE',      N'Tòa nhà A - Tầng 2', NULL),
(N'BldA-Floor3-RT',   '192.168.1.4', 'AA:00:00:00:01:04', N'Ubiquiti ER-X',    '2.0',  'ONLINE',      N'Tòa nhà A - Tầng 3', NULL),
(N'BldB-Floor2-RT',   '192.168.2.3', 'AA:00:00:00:02:03', N'Ubiquiti ER-X',    '2.0',  'ONLINE',      N'Tòa nhà B - Tầng 2', NULL),
(N'BldC-Floor2-RT',   '192.168.3.3', 'AA:00:00:00:03:03', N'Ubiquiti ER-X',    '2.0',  'ONLINE',      N'Tòa nhà C - Tầng 2', NULL),
(N'Backup-Router-01', '10.0.1.1',    'AA:00:00:00:FF:01', N'Cisco 2911',       '15.6', 'OFFLINE',     N'Phòng máy chủ A', 13);
GO

INSERT INTO AccessPoint (ap_name, ssid, ip_address, connected_users, status, location, room_id) VALUES
(N'AP-A1-01',  N'UniWiFi-A1',  '192.168.10.11', 22, 'ONLINE',  N'Tòa nhà A - Phòng A101', 1),
(N'AP-A1-02',  N'UniWiFi-A1',  '192.168.10.12', 18, 'ONLINE',  N'Tòa nhà A - Phòng A102', 2),
(N'AP-A2-01',  N'UniWiFi-A2',  '192.168.10.21', 30, 'ONLINE',  N'Tòa nhà A - Phòng A201', 3),
(N'AP-A2-02',  N'UniWiFi-A2',  '192.168.10.22', 15, 'ONLINE',  N'Tòa nhà A - Phòng A202', 4),
(N'AP-A3-01',  N'UniWiFi-A3',  '192.168.10.31', 8,  'ONLINE',  N'Tòa nhà A - Phòng A301', 5),
(N'AP-B1-01',  N'UniWiFi-B1',  '192.168.10.41', 40, 'ONLINE',  N'Tòa nhà B - Phòng B101', 6),
(N'AP-B1-02',  N'UniWiFi-B1',  '192.168.10.42', 35, 'ONLINE',  N'Tòa nhà B - Phòng B102', 7),
(N'AP-B2-01',  N'UniWiFi-B2',  '192.168.10.51', 20, 'ONLINE',  N'Tòa nhà B - Phòng B201', 8),
(N'AP-B2-02',  N'UniWiFi-B2',  '192.168.10.52', 5,  'OFFLINE', N'Tòa nhà B - Phòng B202', 9),
(N'AP-C1-01',  N'UniWiFi-C1',  '192.168.10.61', 50, 'ONLINE',  N'Tòa nhà C - Phòng C101', 10),
(N'AP-C2-01',  N'UniWiFi-C2',  '192.168.10.71', 45, 'ONLINE',  N'Tòa nhà C - Phòng C201', 11),
(N'AP-C3-01',  N'UniWiFi-C3',  '192.168.10.81', 28, 'ONLINE',  N'Tòa nhà C - Phòng C301', 12),
(N'AP-Lab-01', N'UniWiFi-Lab', '192.168.10.91', 12, 'ONLINE',  N'Phòng thực hành mạng', 15),
(N'AP-Lab-02', N'UniWiFi-Lab', '192.168.10.92', 6,  'ONLINE',  N'Phòng thực hành mạng', 15),
(N'AP-Srv-01', N'UniWiFi-Srv', '192.168.10.99', 2,  'ONLINE',  N'Phòng máy chủ A', 13);
GO

INSERT INTO [Switch] (switch_name, total_ports, used_ports, ip_address, status, room_id) VALUES
(N'SW-Core-01', 48, 40, '10.0.2.1',      'ONLINE',      13),
(N'SW-Core-02', 48, 38, '10.0.2.2',      'ONLINE',      14),
(N'SW-A1-01',   24, 18, '192.168.20.11', 'ONLINE',       1),
(N'SW-A1-02',   24, 12, '192.168.20.12', 'ONLINE',       2),
(N'SW-A2-01',   24, 20, '192.168.20.21', 'ONLINE',       3),
(N'SW-A3-01',   16, 8,  '192.168.20.31', 'ONLINE',       5),
(N'SW-B1-01',   48, 36, '192.168.20.41', 'ONLINE',       6),
(N'SW-B1-02',   48, 30, '192.168.20.42', 'ONLINE',       7),
(N'SW-B2-01',   24, 15, '192.168.20.51', 'ONLINE',       8),
(N'SW-B2-02',   24, 5,  '192.168.20.52', 'MAINTENANCE',  9),
(N'SW-C1-01',   48, 42, '192.168.20.61', 'ONLINE',      10),
(N'SW-C2-01',   48, 38, '192.168.20.71', 'ONLINE',      11),
(N'SW-C3-01',   24, 20, '192.168.20.81', 'ONLINE',      12),
(N'SW-Lab-01',  24, 14, '192.168.20.91', 'ONLINE',      15),
(N'SW-Srv-01',  16, 10, '192.168.20.99', 'ONLINE',      13);
GO

INSERT INTO NetworkDevice (device_name, mac_address, ip_address, owner, device_type, status, room_id) VALUES
(N'Laptop-NguyễnVănAn',   'CC:00:00:00:01:01', '192.168.30.11', N'Nguyễn Văn An',    N'Laptop',        'ALLOWED', 1),
(N'Laptop-TrầnMinhĐức',   'CC:00:00:00:01:02', '192.168.30.12', N'Trần Minh Đức',    N'Laptop',        'ALLOWED', 1),
(N'Phone-LêThịHoa',       'CC:00:00:00:02:01', '192.168.30.21', N'Lê Thị Hoa',       N'Điện thoại',    'ALLOWED', 3),
(N'Laptop-PhạmQuốcBảo',   'CC:00:00:00:02:02', '192.168.30.22', N'Phạm Quốc Bảo',    N'Laptop',        'ALLOWED', 3),
(N'Tablet-HoàngThịMai',   'CC:00:00:00:03:01', '192.168.30.31', N'Hoàng Thị Mai',    N'Máy tính bảng', 'ALLOWED', 6),
(N'Laptop-VũThanhLong',   'CC:00:00:00:03:02', '192.168.30.32', N'Vũ Thanh Long',    N'Laptop',        'ALLOWED', 6),
(N'Phone-ĐặngThịThu',     'CC:00:00:00:04:01', '192.168.30.41', N'Đặng Thị Thu',     N'Điện thoại',    'ALLOWED', 8),
(N'Laptop-BùiVănKhánh',   'CC:00:00:00:04:02', '192.168.30.42', N'Bùi Văn Khánh',    N'Laptop',        'ALLOWED', 8),
(N'Desktop-NgôThịLan',    'CC:00:00:00:05:01', '192.168.30.51', N'Ngô Thị Lan',      N'Máy tính bàn',  'ALLOWED', 10),
(N'Laptop-ĐinhVănPhúc',   'CC:00:00:00:05:02', '192.168.30.52', N'Đinh Văn Phúc',    N'Laptop',        'ALLOWED', 10),
(N'Phone-TrươngThịNgọc',  'CC:00:00:00:06:01', '192.168.30.61', N'Trương Thị Ngọc',  N'Điện thoại',    'BLOCKED', 11),
(N'Laptop-CaoVănHiếu',    'CC:00:00:00:06:02', '192.168.30.62', N'Cao Văn Hiếu',     N'Laptop',        'ALLOWED', 11),
(N'Tablet-LâmThịPhương',  'CC:00:00:00:07:01', '192.168.30.71', N'Lâm Thị Phương',   N'Máy tính bảng', 'ALLOWED', 15),
(N'Laptop-MaiVănThành',   'CC:00:00:00:07:02', '192.168.30.72', N'Mai Văn Thành',    N'Laptop',        'ALLOWED', 15),
(N'Thiết-bị-lạ-01',       'CC:00:00:00:FF:01', '192.168.30.99', N'Không xác định',   N'Không xác định','BLOCKED', 1);
GO

INSERT INTO VLAN (vlan_name, subnet, purpose, room_id) VALUES
(N'VLAN-Admin',      '10.0.0.0/24',     N'Mạng quản trị hệ thống', NULL),
(N'VLAN-Staff-A',    '192.168.1.0/24',  N'Mạng nhân viên tòa nhà A', NULL),
(N'VLAN-Staff-B',    '192.168.2.0/24',  N'Mạng nhân viên tòa nhà B', NULL),
(N'VLAN-Staff-C',    '192.168.3.0/24',  N'Mạng nhân viên tòa nhà C', NULL),
(N'VLAN-Student-A1', '192.168.10.0/24', N'Mạng WiFi sinh viên tòa nhà A tầng 1', 1),
(N'VLAN-Student-A2', '192.168.11.0/24', N'Mạng WiFi sinh viên tòa nhà A tầng 2', 3),
(N'VLAN-Student-B1', '192.168.12.0/24', N'Mạng WiFi sinh viên tòa nhà B tầng 1', 6),
(N'VLAN-Student-B2', '192.168.13.0/24', N'Mạng WiFi sinh viên tòa nhà B tầng 2', 8),
(N'VLAN-Student-C1', '192.168.14.0/24', N'Mạng WiFi sinh viên tòa nhà C tầng 1', 10),
(N'VLAN-Lab',        '192.168.20.0/24', N'Mạng phòng thực hành', 15),
(N'VLAN-Server',     '10.0.1.0/24',     N'Mạng hạ tầng máy chủ', 13),
(N'VLAN-CCTV',       '172.16.0.0/24',   N'Mạng camera an ninh', NULL),
(N'VLAN-Printer',    '172.16.1.0/24',   N'Mạng máy in', NULL),
(N'VLAN-Guest',      '192.168.99.0/24', N'Mạng WiFi khách được cô lập', NULL),
(N'VLAN-IoT',        '172.16.2.0/24',   N'Mạng thiết bị IoT', NULL);
GO

INSERT INTO IPAddressManagement (ip_address, status, device_id) VALUES
('192.168.30.11', 'ASSIGNED', 1),
('192.168.30.12', 'ASSIGNED', 2),
('192.168.30.21', 'ASSIGNED', 3),
('192.168.30.22', 'ASSIGNED', 4),
('192.168.30.31', 'ASSIGNED', 5),
('192.168.30.32', 'ASSIGNED', 6),
('192.168.30.41', 'ASSIGNED', 7),
('192.168.30.42', 'ASSIGNED', 8),
('192.168.30.51', 'ASSIGNED', 9),
('192.168.30.52', 'ASSIGNED', 10),
('192.168.30.61', 'ASSIGNED', 11),
('192.168.30.62', 'ASSIGNED', 12),
('192.168.30.71', 'ASSIGNED', 13),
('192.168.30.72', 'ASSIGNED', 14),
('192.168.30.99', 'ASSIGNED', 15);
GO

INSERT INTO BandwidthUsage (upload_speed, download_speed, record_time, device_id) VALUES
(45.2, 120.5, DATEADD(MINUTE, -90, GETDATE()), 1),
(38.7, 95.3, DATEADD(MINUTE, -85, GETDATE()), 2),
(22.1, 55.8, DATEADD(MINUTE, -80, GETDATE()), 3),
(60.4, 180.2, DATEADD(MINUTE, -75, GETDATE()), 4),
(15.3, 40.1, DATEADD(MINUTE, -70, GETDATE()), 5),
(80.0, 250.0, DATEADD(MINUTE, -65, GETDATE()), 6),
(12.5, 30.7, DATEADD(MINUTE, -60, GETDATE()), 7),
(55.9, 140.3, DATEADD(MINUTE, -55, GETDATE()), 8),
(90.1, 300.5, DATEADD(MINUTE, -50, GETDATE()), 9),
(25.4, 70.2, DATEADD(MINUTE, -45, GETDATE()), 10),
(5.1, 10.3, DATEADD(MINUTE, -40, GETDATE()), 11),
(70.3, 200.1, DATEADD(MINUTE, -35, GETDATE()), 12),
(33.6, 88.4, DATEADD(MINUTE, -30, GETDATE()), 13),
(48.2, 130.7, DATEADD(MINUTE, -25, GETDATE()), 14),
(18.9, 50.6, DATEADD(MINUTE, -20, GETDATE()), 1);
GO

INSERT INTO WiFiAnalytics (total_users, peak_users, avg_speed, analytics_date, ap_id) VALUES
(22, 35, 85.5, CAST(DATEADD(DAY, -14, GETDATE()) AS DATE), 1),
(18, 28, 72.3, CAST(DATEADD(DAY, -13, GETDATE()) AS DATE), 2),
(30, 45, 90.1, CAST(DATEADD(DAY, -12, GETDATE()) AS DATE), 3),
(15, 22, 65.8, CAST(DATEADD(DAY, -11, GETDATE()) AS DATE), 4),
(8, 12, 50.2, CAST(DATEADD(DAY, -10, GETDATE()) AS DATE), 5),
(40, 58, 110.4, CAST(DATEADD(DAY, -9, GETDATE()) AS DATE), 6),
(35, 50, 95.7, CAST(DATEADD(DAY, -8, GETDATE()) AS DATE), 7),
(20, 30, 78.3, CAST(DATEADD(DAY, -7, GETDATE()) AS DATE), 8),
(5, 8, 40.1, CAST(DATEADD(DAY, -6, GETDATE()) AS DATE), 9),
(50, 70, 125.6, CAST(DATEADD(DAY, -5, GETDATE()) AS DATE), 10),
(45, 62, 115.2, CAST(DATEADD(DAY, -4, GETDATE()) AS DATE), 11),
(28, 40, 88.9, CAST(DATEADD(DAY, -3, GETDATE()) AS DATE), 12),
(12, 18, 60.4, CAST(DATEADD(DAY, -2, GETDATE()) AS DATE), 13),
(6, 10, 45.3, CAST(DATEADD(DAY, -1, GETDATE()) AS DATE), 14),
(2, 4, 30.0, CAST(GETDATE() AS DATE), 15);
GO

INSERT INTO NetworkAlert (alert_type, message, severity, router_id, ap_id, switch_id) VALUES
(N'Mất kết nối', N'Core-Router-02 bị mất kết nối đường truyền chính', 'CRITICAL', 2, NULL, NULL),
(N'Mất kết nối', N'AP-B2-02 bị ngắt kết nối bất thường', 'CRITICAL', NULL, 9, NULL),
(N'Mất kết nối', N'SW-B2-02 không phản hồi sau sự cố nguồn điện', 'CRITICAL', NULL, NULL, 10),
(N'Hiệu năng', N'CPU của BldA-Router-01 đang sử dụng ở mức cao', 'WARNING', 3, NULL, NULL),
(N'Hiệu năng', N'AP-C1-01 vượt quá số lượng người dùng kết nối tối đa', 'WARNING', NULL, 10, NULL),
(N'Hiệu năng', N'Băng thông của SW-Core-01 vượt quá 90%', 'WARNING', NULL, NULL, 1),
(N'Hiệu năng', N'Lab-Router-02 phát hiện mất gói dữ liệu', 'WARNING', 10, NULL, NULL),
(N'Bảo mật', N'Phát hiện thiết bị lạ trong VLAN-Student-A1', 'CRITICAL', NULL, 1, NULL),
(N'Bảo mật', N'Nhiều lần đăng nhập thất bại qua BldB-Router-01', 'WARNING', 5, NULL, NULL),
(N'Cấu hình', N'Firmware của BldC-Router-02 đã lỗi thời', 'INFO', 8, NULL, NULL),
(N'Cấu hình', N'AP-A3-01 bị tắt phát SSID', 'INFO', NULL, 5, NULL),
(N'Cấu hình', N'SW-A3-01 bị sai cấu hình cổng mạng', 'INFO', NULL, NULL, 6),
(N'Mất kết nối', N'Backup-Router-01 đang ngoại tuyến, chưa kích hoạt dự phòng', 'WARNING', 15, NULL, NULL),
(N'Hiệu năng', N'Tốc độ trung bình của AP-Lab-01 giảm dưới 30 Mbps', 'WARNING', NULL, 13, NULL),
(N'Bảo mật', N'SW-C1-01 phát hiện hành vi MAC flooding', 'CRITICAL', NULL, NULL, 11);
GO

INSERT INTO SupportTicket (title, description, status, created_by, device_id) VALUES
(N'WiFi chậm tại phòng A101', N'Sinh viên phản ánh tốc độ mạng thấp vào giờ cao điểm', 'OPEN', 5, NULL),
(N'Không kết nối được UniWiFi-B1', N'Điện thoại không thể xác thực vào mạng B1', 'IN_PROGRESS', 6, 3),
(N'Lỗi xác thực Eduroam', N'SSID eduroam trả về lỗi xác thực 802.1X', 'OPEN', 7, NULL),
(N'Trùng địa chỉ IP trong phòng Lab', N'Hai thiết bị đang dùng cùng IP 192.168.30.71', 'RESOLVED', 8, 13),
(N'Laptop bị chặn bất thường', N'Laptop bị chặn truy cập mạng mà không có thông báo', 'OPEN', 9, 2),
(N'Cổng switch không hoạt động', N'Cổng số 12 trên SW-A1-01 không có tín hiệu', 'IN_PROGRESS', 10, NULL),
(N'Mất tín hiệu tại phòng A301', N'Tín hiệu AP-A3-01 rất yếu ở cuối phòng', 'OPEN', 5, NULL),
(N'Router khởi động lại liên tục', N'Lab-Router-02 tự khởi động lại mỗi 10 phút', 'RESOLVED', 6, NULL),
(N'Sai cấu hình VLAN', N'Thiết bị trong VLAN-Lab không truy cập được VLAN-Server', 'OPEN', 7, NULL),
(N'Cảnh báo thiết bị lạ', N'Unknown-Device-01 xuất hiện trong mạng, cần kiểm tra', 'IN_PROGRESS', 8, 15),
(N'Băng thông bị giới hạn', N'Tốc độ tải xuống của thiết bị bị giới hạn còn 10 Mbps', 'OPEN', 9, 8),
(N'AP B202 ngoại tuyến', N'AP-B2-02 đã ngoại tuyến từ sáng nay', 'OPEN', 10, NULL),
(N'Không in được qua mạng', N'Máy in không truy cập được từ VLAN-Staff-A', 'RESOLVED', 5, NULL),
(N'Kết nối chậm tại C301', N'Mạng tầng 3 tòa nhà C bị mất gói không ổn định', 'OPEN', 6, NULL),
(N'Địa chỉ MAC bị chặn', N'Thiết bị có MAC CC:00:00:00:06:01 bị chặn truy cập mạng', 'IN_PROGRESS', 7, 11);
GO

INSERT INTO MaintenanceSchedule (title, description, start_time, end_time, status) VALUES
(N'Nâng cấp firmware Core Router', N'Nâng cấp Core-Router-01 và Core-Router-02 lên phiên bản IOS mới nhất', '2026-06-01 22:00', '2026-06-02 01:00', 'PLANNED'),
(N'Thay thế switch tòa nhà A', N'Thay SW-A1-02 bằng thiết bị switch 48 cổng mới', '2026-06-03 08:00', '2026-06-03 12:00', 'PLANNED'),
(N'Kiểm tra phần cứng AP-B2-02', N'Kiểm tra và sửa chữa AP-B2-02 sau sự cố mất kết nối', '2026-05-28 09:00', '2026-05-28 11:00', 'COMPLETED'),
(N'Bảo trì router phòng Lab', N'Khởi động lại Lab-Router-02 theo lịch sau khi cập nhật bản vá', '2026-05-27 22:00', '2026-05-27 23:00', 'COMPLETED'),
(N'Cập nhật firmware router tòa nhà C', N'Cập nhật BldC-Router-02 để vá lỗi bảo mật', '2026-06-05 20:00', '2026-06-05 22:00', 'PLANNED'),
(N'Kiểm tra nguồn SW-B2-02', N'Kiểm tra UPS và bộ nguồn của SW-B2-02', '2026-06-04 14:00', '2026-06-04 16:00', 'PLANNED'),
(N'Kiểm tra dây mạng tòa nhà A', N'Kiểm tra và dán nhãn toàn bộ dây mạng tại tòa nhà A', '2026-06-07 08:00', '2026-06-07 17:00', 'PLANNED'),
(N'Cập nhật firmware hàng loạt AP', N'Cập nhật toàn bộ Access Point lên firmware v3.2.1', '2026-06-08 22:00', '2026-06-09 02:00', 'PLANNED'),
(N'Kiểm tra router dự phòng', N'Thử nghiệm chuyển đổi dự phòng với Backup-Router-01', '2026-06-10 10:00', '2026-06-10 12:00', 'PLANNED'),
(N'Kiểm tra cổng SW-Core-01', N'Kiểm tra và dọn dẹp các cổng mạng không sử dụng trên SW-Core-01', '2026-06-06 09:00', '2026-06-06 11:00', 'PLANNED'),
(N'Cấu hình lại VLAN phòng Lab', N'Cấu hình lại VLAN-Lab để hỗ trợ subnet mới', '2026-06-11 20:00', '2026-06-11 23:00', 'PLANNED'),
(N'Khảo sát tín hiệu AP tòa nhà B', N'Khảo sát vùng phủ sóng WiFi trong tòa nhà B', '2026-06-12 08:00', '2026-06-12 17:00', 'PLANNED'),
(N'Kiểm tra làm mát phòng máy chủ', N'Kiểm tra hệ thống làm mát tại phòng máy chủ A', '2026-05-30 10:00', '2026-05-30 12:00', 'IN_PROGRESS'),
(N'Dọn dẹp vùng địa chỉ IP', N'Xóa DHCP lease cũ và cập nhật bảng quản lý IP', '2026-06-02 09:00', '2026-06-02 11:00', 'PLANNED'),
(N'Cập nhật bảo mật toàn bộ switch', N'Cài đặt bản vá bảo mật cho toàn bộ switch', '2026-06-15 22:00', '2026-06-16 02:00', 'PLANNED');
GO

INSERT INTO MaintenanceRouter (maintenance_id, router_id) VALUES
(1, 1),
(1, 2),
(4, 10),
(5, 8),
(9, 15),
(3, 7),
(6, 5),
(7, 3),
(7, 4),
(10, 1),
(11, 9),
(12, 6),
(13, 15),
(14, 3),
(15, 2);
GO

INSERT INTO MaintenanceAccessPoint (maintenance_id, ap_id) VALUES
(3, 9),
(8, 1),
(8, 2),
(8, 3),
(8, 6),
(8, 10),
(12, 6),
(12, 7),
(12, 8),
(12, 9),
(7, 1),
(7, 3),
(11, 13),
(14, 15),
(9, 13);
GO

INSERT INTO MaintenanceSwitch (maintenance_id, switch_id) VALUES
(2, 4),
(6, 10),
(10, 1),
(15, 1),
(15, 2),
(15, 3),
(15, 7),
(15, 11),
(7, 3),
(7, 4),
(11, 14),
(12, 7),
(12, 8),
(13, 15),
(14, 3);
GO

INSERT INTO AuthenticationLog (username, login_status, ip_address, user_id) VALUES
('admin',    'SUCCESS', '192.168.1.100', 1),
('tech01',   'SUCCESS', '192.168.1.101', 2),
('tech02',   'SUCCESS', '192.168.2.101', 3),
('tech03',   'SUCCESS', '192.168.2.102', 4),
('viewer01', 'SUCCESS', '192.168.3.101', 5),
('viewer02', 'SUCCESS', '192.168.3.102', 6),
('viewer03', 'SUCCESS', '192.168.10.50', 7),
('admin',    'SUCCESS', '192.168.1.100', 1),
('tech01',   'FAILED',  '192.168.1.101', NULL),
('hacker01', 'FAILED',  '10.10.10.1', NULL),
('hacker01', 'FAILED',  '10.10.10.1', NULL),
('hacker02', 'FAILED',  '10.10.10.2', NULL),
('viewer07', 'SUCCESS', '192.168.3.107', 12),
('tech04',   'SUCCESS', '192.168.2.111', 11),
('unknown',  'FAILED',  '172.16.99.1', NULL);
GO

INSERT INTO SystemLog (action, details, performed_by) VALUES
(N'Đăng nhập', N'Admin đăng nhập từ địa chỉ 192.168.1.100', 1),
(N'Đăng nhập', N'tech01 đăng nhập từ địa chỉ 192.168.1.101', 2),
(N'Cập nhật thiết bị', N'Cập nhật trạng thái AP-B2-02 thành OFFLINE', 2),
(N'Cập nhật thiết bị', N'Cập nhật trạng thái SW-B2-02 thành MAINTENANCE', 3),
(N'Tạo cảnh báo', N'Tạo cảnh báo CRITICAL cho sự cố Core-Router-02', 1),
(N'Tạo ticket', N'Tạo ticket hỗ trợ: WiFi chậm tại phòng A101', 5),
(N'Xử lý ticket', N'Ticket ID 4 đã được xử lý: sửa lỗi trùng IP trong phòng Lab', 2),
(N'Cập nhật router', N'Cập nhật firmware BldC-Router-02 lên phiên bản 1.3.1', 4),
(N'Tạo lịch bảo trì', N'Tạo lịch bảo trì: Nâng cấp firmware Core Router', 1),
(N'Chặn thiết bị', N'Chặn thiết bị CC:00:00:00:FF:01 do MAC không xác định', 2),
(N'Chặn thiết bị', N'Chặn thiết bị CC:00:00:00:06:01 do vi phạm chính sách', 3),
(N'Cập nhật VLAN', N'Cập nhật subnet VLAN-Lab thành 192.168.20.0/24', 1),
(N'Xóa IP', N'Đánh dấu IP 192.168.30.99 là IP cũ cần kiểm tra', 4),
(N'Đăng nhập', N'tech04 đăng nhập từ địa chỉ 192.168.2.111', 11),
(N'Đăng xuất', N'Phiên đăng nhập của Admin đã đóng sau 2 giờ không hoạt động', 1);
GO

-- VNPAY payment and service activation tables
CREATE TABLE PaymentTransaction (
    payment_id         BIGINT IDENTITY(1,1) PRIMARY KEY,
    txn_ref            VARCHAR(100) NOT NULL UNIQUE,
    user_id            INT NOT NULL,
    plan_code          VARCHAR(30) NOT NULL,
    plan_name          NVARCHAR(100) NOT NULL,
    duration_days      INT NOT NULL CHECK (duration_days > 0),
    amount             BIGINT NOT NULL CHECK (amount > 0),
    currency           VARCHAR(3) NOT NULL DEFAULT 'VND',
    order_info         NVARCHAR(255) NOT NULL,
    status             VARCHAR(20) NOT NULL DEFAULT 'PENDING'
                       CHECK (status IN ('PENDING','SUCCESS','FAILED','CANCELLED','EXPIRED')),
    client_ip          VARCHAR(45),
    bank_code          VARCHAR(30),
    card_type          VARCHAR(30),
    vnp_transaction_no VARCHAR(50),
    response_code      VARCHAR(10),
    transaction_status VARCHAR(10),
    pay_date           DATETIME2,
    gateway_data       NVARCHAR(MAX),
    created_at         DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    updated_at         DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    confirmed_at       DATETIME2,
    CONSTRAINT fk_payment_user FOREIGN KEY (user_id) REFERENCES [User](user_id)
);
GO

CREATE INDEX IX_Payment_User_Created ON PaymentTransaction(user_id, created_at DESC);
CREATE INDEX IX_Payment_Status ON PaymentTransaction(status);
GO

CREATE TABLE UserSubscription (
    user_id       INT PRIMARY KEY,
    plan_code     VARCHAR(30) NOT NULL,
    plan_name     NVARCHAR(100) NOT NULL,
    status        VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
                  CHECK (status IN ('ACTIVE','EXPIRED','CANCELLED')),
    started_at    DATETIME2 NOT NULL,
    expires_at    DATETIME2 NOT NULL,
    updated_at    DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT fk_subscription_user FOREIGN KEY (user_id) REFERENCES [User](user_id),
    CONSTRAINT ck_subscription_dates CHECK (expires_at > started_at)
);
GO


