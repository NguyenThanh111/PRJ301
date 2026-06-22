-- VNPAY payment tables for an existing network_simulation_db3 database.
-- Safe to run more than once.
USE network_simulation_db3;
GO

IF OBJECT_ID('dbo.PaymentTransaction', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PaymentTransaction (
        payment_id             BIGINT IDENTITY(1,1) PRIMARY KEY,
        txn_ref                VARCHAR(100) NOT NULL,
        user_id                INT NOT NULL,
        plan_code              VARCHAR(30) NOT NULL,
        plan_name              NVARCHAR(100) NOT NULL,
        duration_days          INT NOT NULL,
        amount                 BIGINT NOT NULL,
        currency               VARCHAR(3) NOT NULL CONSTRAINT DF_Payment_Currency DEFAULT 'VND',
        order_info             NVARCHAR(255) NOT NULL,
        status                 VARCHAR(20) NOT NULL CONSTRAINT DF_Payment_Status DEFAULT 'PENDING',
        client_ip              VARCHAR(45),
        bank_code              VARCHAR(30),
        card_type              VARCHAR(30),
        vnp_transaction_no     VARCHAR(50),
        response_code          VARCHAR(10),
        transaction_status     VARCHAR(10),
        pay_date               DATETIME2,
        gateway_data           NVARCHAR(MAX),
        created_at             DATETIME2 NOT NULL CONSTRAINT DF_Payment_Created DEFAULT SYSDATETIME(),
        updated_at             DATETIME2 NOT NULL CONSTRAINT DF_Payment_Updated DEFAULT SYSDATETIME(),
        confirmed_at           DATETIME2,
        CONSTRAINT UQ_Payment_TxnRef UNIQUE (txn_ref),
        CONSTRAINT FK_Payment_User FOREIGN KEY (user_id) REFERENCES dbo.[User](user_id),
        CONSTRAINT CK_Payment_Amount CHECK (amount > 0),
        CONSTRAINT CK_Payment_Duration CHECK (duration_days > 0),
        CONSTRAINT CK_Payment_Status CHECK (status IN ('PENDING','SUCCESS','FAILED','CANCELLED','EXPIRED'))
    );
END;
GO

IF OBJECT_ID('dbo.UserSubscription', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.UserSubscription (
        user_id       INT PRIMARY KEY,
        plan_code     VARCHAR(30) NOT NULL,
        plan_name     NVARCHAR(100) NOT NULL,
        status        VARCHAR(20) NOT NULL CONSTRAINT DF_Subscription_Status DEFAULT 'ACTIVE',
        started_at    DATETIME2 NOT NULL,
        expires_at    DATETIME2 NOT NULL,
        updated_at    DATETIME2 NOT NULL CONSTRAINT DF_Subscription_Updated DEFAULT SYSDATETIME(),
        CONSTRAINT FK_Subscription_User FOREIGN KEY (user_id) REFERENCES dbo.[User](user_id),
        CONSTRAINT CK_Subscription_Status CHECK (status IN ('ACTIVE','EXPIRED','CANCELLED')),
        CONSTRAINT CK_Subscription_Dates CHECK (expires_at > started_at)
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Payment_User_Created'
               AND object_id = OBJECT_ID('dbo.PaymentTransaction'))
    CREATE INDEX IX_Payment_User_Created ON dbo.PaymentTransaction(user_id, created_at DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Payment_Status'
               AND object_id = OBJECT_ID('dbo.PaymentTransaction'))
    CREATE INDEX IX_Payment_Status ON dbo.PaymentTransaction(status);
GO
