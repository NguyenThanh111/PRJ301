-- Add an avatar column to the User table to support the profile picture change feature.
ALTER TABLE [User] ADD avatar VARCHAR(255) NULL;
GO
