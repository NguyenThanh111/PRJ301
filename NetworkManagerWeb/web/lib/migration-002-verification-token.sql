IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='VerificationToken' AND xtype='U')
BEGIN
    CREATE TABLE VerificationToken (
        id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL,
        token VARCHAR(255) NOT NULL,
        type VARCHAR(20) NOT NULL,
        expiry_date DATETIME NOT NULL,
        used BIT DEFAULT 0,
        created_at DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (user_id) REFERENCES [User](user_id)
    );

    CREATE UNIQUE INDEX idx_token ON VerificationToken(token);
    CREATE INDEX idx_user_id ON VerificationToken(user_id);
    CREATE INDEX idx_user_type ON VerificationToken(user_id, type);
END;
GO

-- Add UNIQUE constraint on email if not exists
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='uq_email' AND object_id = OBJECT_ID('[User]'))
BEGIN
    ALTER TABLE [User] ADD CONSTRAINT uq_email UNIQUE(email);
END;
GO
