-- DB-Scripts

-- Check and create database if it does not exist
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = N'KoreAssignment_Shivam_Rana')
BEGIN
CREATE DATABASE KoreAssignment_Shivam_Rana;
END
GO

USE KoreAssignment_Shivam_Rana
GO

 -- Check and create stg schema if it does not exist
 IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'stg')
 BEGIN
 EXEC('CREATE SCHEMA stg');
 END
 GO

 -- Check and create prod schema if it does not exist
 IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'prod')
 BEGIN
 EXEC('CREATE SCHEMA prod');
 END
 GO


  -- Check and create config schema if it does not exist
 IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'config')
 BEGIN
 EXEC('CREATE SCHEMA config');
 END
 GO

  -- Check and create log schema if it does not exist
 IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'log')
 BEGIN
 EXEC('CREATE SCHEMA log');
 END
 GO

  -- Check and create dbo schema if it does not exist
 IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'dbo')
 BEGIN
 EXEC('CREATE SCHEMA dbo');
 END
 GO

 -- Check and create stg.Users table if it does not exist
 IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'stg.Users') AND type in (N'U'))
 BEGIN
 CREATE TABLE stg.Users (
 StgID INT IDENTITY(1,1) PRIMARY KEY,
 UserID INT,
 FullName NVARCHAR(255),
 Age INT,
 Email NVARCHAR(255),
 RegistrationDate DATE,
 LastLoginDate DATE,
 PurchaseTotal FLOAT
 );
 END
 GO

 -- Check and create prod.Users table if it does not exist
 IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'prod.Users') AND type in (N'U'))
 BEGIN
 CREATE TABLE prod.Users (
 ID INT IDENTITY(1,1) PRIMARY KEY,
 UserID INT,
 FullName NVARCHAR(255),
 Age INT,
 Email NVARCHAR(255),
 RegistrationDate DATE,
 LastLoginDate DATE,
 PurchaseTotal FLOAT,
 RecordLastUpdated DATETIME DEFAULT GETDATE()
 );
 END
 GO

 -- Check and create config.Package_Configurations table if it does not exist
 IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'config.Package_Configurations') AND type in (N'U'))
 BEGIN
 CREATE TABLE config.Package_Configurations (
 ID INT IDENTITY(1,1) PRIMARY KEY,
 PackageName NVARCHAR(255),
 PackageDesc NVARCHAR(255),
 ServerName NVARCHAR(255),
 DatabaseName NVARCHAR(255),
 ModifiedDate DATETIME
 );
 END
 GO
 

 -- Check and create log.RejectedRecords table if it does not exist
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'log.RejectedRecords') AND type in (N'U'))
BEGIN
CREATE TABLE log.RejectedRecords (
	UserID INT,
    FullName NVARCHAR(255),
    Age INT,
    Email NVARCHAR(255),
    RegistrationDate DATE,
    LastLoginDate DATE,
    PurchaseTotal DECIMAL(18, 2),
    RejectionReason NVARCHAR(255),
	Dated DATETIME DEFAULT GETDATE()
);
END
GO

 -- Check and create log.audit_log table if it does not exist
 IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'log.audit_log') AND type in (N'U'))
 BEGIN
 CREATE TABLE log.audit_log(
 ID INT IDENTITY(1,1) PRIMARY KEY,
 PackageName NVARCHAR(255),
 Status NVARCHAR(255),
 RecordsInserted INT,
 RecordsUpdated INT,
 ErrorMessage NVARCHAR(255),
 ModifiedDate DATETIME
 );
 END
 GO


IF (SELECT COUNT(*) FROM prod.Users) = 0
BEGIN
INSERT INTO prod.Users (UserID, FullName, Age, Email, RegistrationDate, LastLoginDate, PurchaseTotal)
VALUES
(101, 'John Doe', 30, 'johndoe@example.com', '2021-01-10', '2023-03-01', 150.00),
(102, 'Jane Smith', 25, 'janesmith@example.com', '2020-05-15', '2023-02-25', 200.00),
(103, 'Emily Johnson', 22, 'emilyjohnson@example.com', '2019-03-23', '2023-01-30', 120.50),
(104, 'Michael Brown', 35, 'michaelbrown@example.com', '2018-07-18', '2023-02-20', 300.75),
(105, 'Jessica Garcia', 28, 'jessicagarcia@example.com', '2022-08-05', '2023-02-18', 180.25),
(106, 'David Miller', 40, 'davidmiller@example.com', '2017-12-12', '2023-02-15', 220.40),
(107, 'Sarah Martinez', 33, 'sarahmartinez@example.com', '2018-11-30', '2023-02-10', 140.60),
(108, 'James Taylor', 29, 'jamestaylor@example.com', '2019-06-22', '2023-02-05', 210.00),
(109, 'Linda Anderson', 27, 'lindaanderson@example.com', '2021-04-16', '2023-01-25', 165.95),
(110, 'Robert Wilson', 31, 'robertwilson@example.com', '2020-02-20', '2023-01-20', 175.00);
END
GO


CREATE OR ALTER   PROCEDURE [dbo].[usp_DataCleaning]
AS
BEGIN

    BEGIN TRY
        -- Begin transaction
        BEGIN TRANSACTION;

		--capturing rejected records into the log tables

		--capturing the duplicate records and keeping the record with the latest logindate (latest record)
		
		WITH Inserting_Duplicate_Record_CTE as( SELECT *,
					   ROW_NUMBER() OVER (PARTITION BY USERID, FULLNAME ORDER BY LastLoginDate desc) as rn
					   FROM STG.USERS )
		INSERT INTO log.RejectedRecords (UserID, FullName, Age, Email, RegistrationDate, LastLoginDate, PurchaseTotal, RejectionReason)
		SELECT UserID, FullName, Age, Email, RegistrationDate, LastLoginDate, PurchaseTotal,'Duplicate Record' from Inserting_Duplicate_Record_CTE where rn>1;
		
		

		--capturing invalid records
		INSERT INTO log.RejectedRecords (UserID, FullName, Age, Email, RegistrationDate, LastLoginDate, PurchaseTotal, RejectionReason)
        SELECT UserID, FullName, Age, Email, RegistrationDate, LastLoginDate, PurchaseTotal,
               CASE
                   WHEN (UserID IS NULL OR FullName IS NULL) THEN 'NULL User'
                   WHEN Age < 0 THEN 'Age cannot be negative'
				   WHEN (Email NOT LIKE '%_@__%.%' OR Email LIKE '%[^a-zA-Z0-9@._-]%') THEN 'Invalid Email Format'
                   
                   WHEN RegistrationDate ='2024-01-01' THEN 'Future Date'
                   WHEN RegistrationDate ='1920-01-01' THEN 'Too Old Date'
				   WHEN RegistrationDate ='1899-12-30' THEN 'Invalid Date Format'

				   WHEN LastLoginDate ='2024-01-01' THEN 'Future Date'
                   WHEN LastLoginDate='1920-01-01' THEN 'Too Old Date'
				   WHEN LastLoginDate ='1899-12-30' THEN 'Invalid Date Format'

				   WHEN PurchaseTotal>1000 THEN 'Value is too large'
                   ELSE 'Unknown Reason'
               END AS RejectionReason
        FROM STG.USERS
        WHERE 
            (UserID IS NULL OR FullName IS NULL)
            OR Age < 0
			OR (Email NOT LIKE '%_@__%.%' OR Email LIKE '%[^a-zA-Z0-9@._-]%')
            OR RegistrationDate in('2024-01-01','1920-01-01','1899-12-30')
			OR LastLoginDate in('2024-01-01','1920-01-01','1899-12-30')
			OR PurchaseTotal>1000;
			

		--deleting dulicate records from the staging tbl
		WITH Duplicate_Record_CTE as( SELECT *,
									  ROW_NUMBER() OVER (PARTITION BY USERID, FULLNAME ORDER BY LastLoginDate desc) as rn
									  FROM STG.USERS )
		DELETE from Duplicate_Record_CTE where rn>1;


		--deleting invalid records from staging tbl
		DELETE FROM STG.USERS
        WHERE 
        (UserID IS NULL OR FullName IS NULL)
        OR Age < 0
		OR (Email NOT LIKE '%_@__%.%' OR Email LIKE '%[^a-zA-Z0-9@._-]%')
        OR RegistrationDate in('2024-01-01','1920-01-01','1899-12-30')
		OR LastLoginDate in('2024-01-01','1920-01-01','1899-12-30')
		OR PurchaseTotal>1000;

		-- Update PurchaseTotal to handle empty or null values and round to 2 decimal places
        UPDATE STG.USERS
        SET PurchaseTotal = ROUND(ISNULL(PurchaseTotal, 0), 2);
        
		-- Update Age to handle 0 values 
        UPDATE STG.USERS
        SET Age = NULL where Age=0;

        -- Commit transaction
        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        -- Rollback transaction in case of error
        ROLLBACK TRANSACTION;
		THROW
    END CATCH
END
GO	    


CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateAndLog]
    @FullName NVARCHAR(255),
    @Age INT,
    @Email NVARCHAR(255),
    @RegistrationDate DATE,
    @LastLoginDate DATE,
    @PurchaseTotal FLOAT,
    @UserID INT	
AS
BEGIN 

    BEGIN TRY
        
	-- Begin transaction
    BEGIN TRANSACTION;

    -- Update the user record
    UPDATE PU
    SET PU.FullName = @FullName,
        PU.Age = @Age,
        PU.Email = @Email,
        PU.RegistrationDate = @RegistrationDate,
        PU.LastLoginDate = @LastLoginDate,
        PU.PurchaseTotal = @PurchaseTotal,
        PU.RecordLastUpdated = GETDATE()
    FROM prod.Users AS PU
    WHERE PU.UserID = @UserID;
	
	-- Commit transaction
    COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
    -- Rollback transaction in case of error
    ROLLBACK TRANSACTION;
	THROW
    END CATCH
END
GO




