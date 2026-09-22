IF DB_ID('maritime') IS NULL CREATE DATABASE maritime;
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'maritime_admin')
    CREATE LOGIN maritime_admin WITH PASSWORD = 'MaritimeAdmin123!', CHECK_POLICY = OFF;
GO

USE maritime;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'maritime_admin')
    CREATE USER maritime_admin FOR LOGIN maritime_admin;
GO

ALTER ROLE db_owner ADD MEMBER maritime_admin;
GO

IF SCHEMA_ID('fleet')   IS NULL EXEC ('CREATE SCHEMA fleet');
IF SCHEMA_ID('crew')    IS NULL EXEC ('CREATE SCHEMA crew');
IF SCHEMA_ID('finance') IS NULL EXEC ('CREATE SCHEMA finance');
IF SCHEMA_ID('app')     IS NULL EXEC ('CREATE SCHEMA app');
GO

CREATE TABLE fleet.ShipStatus
(
    ShipStatusId    TINYINT         NOT NULL,
    StatusCode      VARCHAR(20)     NOT NULL,
    StatusName      NVARCHAR(50)    NOT NULL,
    IsOperational   BIT             NOT NULL,
    CreatedAt       DATETIME2(3)    NOT NULL CONSTRAINT DF_ShipStatus_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy       NVARCHAR(100)   NOT NULL CONSTRAINT DF_ShipStatus_CreatedBy DEFAULT SUSER_SNAME(),
    ModifiedAt      DATETIME2(3)        NULL,
    ModifiedBy      NVARCHAR(100)       NULL,
    RowVersion      ROWVERSION      NOT NULL,
    CONSTRAINT PK_ShipStatus PRIMARY KEY CLUSTERED (ShipStatusId),
    CONSTRAINT UQ_ShipStatus_StatusCode UNIQUE (StatusCode)
);
GO

CREATE TABLE fleet.FiscalYearPattern
(
    FiscalYearCode      CHAR(4)         NOT NULL,
    StartMonth          TINYINT         NOT NULL,
    EndMonth            TINYINT         NOT NULL,
    SpansCalendarYears  AS (CASE WHEN StartMonth > EndMonth THEN CAST(1 AS BIT)
                                 ELSE CAST(0 AS BIT) END) PERSISTED,
    Description         NVARCHAR(50)    NOT NULL,
    CreatedAt           DATETIME2(3)    NOT NULL CONSTRAINT DF_FiscalYearPattern_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy           NVARCHAR(100)   NOT NULL CONSTRAINT DF_FiscalYearPattern_CreatedBy DEFAULT SUSER_SNAME(),
    ModifiedAt          DATETIME2(3)        NULL,
    ModifiedBy          NVARCHAR(100)       NULL,
    RowVersion          ROWVERSION      NOT NULL,
    CONSTRAINT PK_FiscalYearPattern PRIMARY KEY CLUSTERED (FiscalYearCode),
    CONSTRAINT CK_FiscalYearPattern_StartMonth CHECK (StartMonth BETWEEN 1 AND 12),
    CONSTRAINT CK_FiscalYearPattern_EndMonth   CHECK (EndMonth   BETWEEN 1 AND 12),
    CONSTRAINT CK_FiscalYearPattern_TwelveMonths
        CHECK (EndMonth = CASE WHEN StartMonth = 1 THEN 12 ELSE StartMonth - 1 END)
);
GO

CREATE SEQUENCE fleet.ShipIdSequence AS INT START WITH 1 INCREMENT BY 1;
GO

CREATE TABLE fleet.Ship
(
    ShipId          INT             NOT NULL
                    CONSTRAINT DF_Ship_ShipId DEFAULT (NEXT VALUE FOR fleet.ShipIdSequence),
    DisplayId       VARCHAR(20)     NOT NULL,
    ShipName        NVARCHAR(100)   NOT NULL,
    FiscalYearCode  CHAR(4)         NOT NULL,
    ShipStatusId    TINYINT         NOT NULL,
    IMONumber       CHAR(7)             NULL,
    CreatedAt       DATETIME2(3)    NOT NULL CONSTRAINT DF_Ship_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy       NVARCHAR(100)   NOT NULL CONSTRAINT DF_Ship_CreatedBy DEFAULT SUSER_SNAME(),
    ModifiedAt      DATETIME2(3)        NULL,
    ModifiedBy      NVARCHAR(100)       NULL,
    RowVersion      ROWVERSION      NOT NULL,
    CONSTRAINT PK_Ship PRIMARY KEY CLUSTERED (ShipId),
    CONSTRAINT UQ_Ship_DisplayId UNIQUE (DisplayId),
    CONSTRAINT UQ_Ship_ShipName UNIQUE (ShipName),
    CONSTRAINT FK_Ship_FiscalYearPattern FOREIGN KEY (FiscalYearCode)
        REFERENCES fleet.FiscalYearPattern (FiscalYearCode),
    CONSTRAINT FK_Ship_ShipStatus FOREIGN KEY (ShipStatusId)
        REFERENCES fleet.ShipStatus (ShipStatusId),
    CONSTRAINT CK_Ship_DisplayId CHECK (LEN(LTRIM(RTRIM(DisplayId))) > 0),
    CONSTRAINT CK_Ship_IMONumber CHECK (IMONumber IS NULL OR IMONumber NOT LIKE '%[^0-9]%')
);
GO

CREATE UNIQUE NONCLUSTERED INDEX UX_Ship_IMONumber
    ON fleet.Ship (IMONumber) WHERE IMONumber IS NOT NULL;
GO

CREATE TABLE crew.Nationality
(
    NationalityId   SMALLINT        IDENTITY(1,1) NOT NULL,
    CountryCode     CHAR(2)         NOT NULL,
    NationalityName NVARCHAR(60)    NOT NULL,
    CreatedAt       DATETIME2(3)    NOT NULL CONSTRAINT DF_Nationality_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy       NVARCHAR(100)   NOT NULL CONSTRAINT DF_Nationality_CreatedBy DEFAULT SUSER_SNAME(),
    ModifiedAt      DATETIME2(3)        NULL,
    ModifiedBy      NVARCHAR(100)       NULL,
    RowVersion      ROWVERSION      NOT NULL,
    CONSTRAINT PK_Nationality PRIMARY KEY CLUSTERED (NationalityId),
    CONSTRAINT UQ_Nationality_CountryCode UNIQUE (CountryCode),
    CONSTRAINT UQ_Nationality_Name UNIQUE (NationalityName)
);
GO

CREATE TABLE crew.CrewRank
(
    RankId              SMALLINT        IDENTITY(1,1) NOT NULL,
    RankCode            VARCHAR(20)     NOT NULL,
    RankName            NVARCHAR(60)    NOT NULL,
    Department          VARCHAR(20)     NOT NULL,
    SeniorityOrder      SMALLINT        NOT NULL,
    IsUniquePerContract BIT             NOT NULL CONSTRAINT DF_CrewRank_IsUnique DEFAULT 1,
    CreatedAt           DATETIME2(3)    NOT NULL CONSTRAINT DF_CrewRank_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy           NVARCHAR(100)   NOT NULL CONSTRAINT DF_CrewRank_CreatedBy DEFAULT SUSER_SNAME(),
    ModifiedAt          DATETIME2(3)        NULL,
    ModifiedBy          NVARCHAR(100)       NULL,
    RowVersion          ROWVERSION      NOT NULL,
    CONSTRAINT PK_CrewRank PRIMARY KEY CLUSTERED (RankId),
    CONSTRAINT UQ_CrewRank_RankCode UNIQUE (RankCode),
    CONSTRAINT UQ_CrewRank_RankName UNIQUE (RankName),
    CONSTRAINT CK_CrewRank_Department CHECK (Department IN ('Deck','Engine','Catering'))
);
GO

CREATE SEQUENCE crew.CrewMemberIdSequence AS INT START WITH 1 INCREMENT BY 1;
GO

CREATE TABLE crew.CrewMember
(
    CrewMemberId    INT             NOT NULL
                    CONSTRAINT DF_CrewMember_CrewMemberId DEFAULT (NEXT VALUE FOR crew.CrewMemberIdSequence),
    DisplayId       VARCHAR(20)     NOT NULL,
    FirstName       NVARCHAR(50)    NOT NULL,
    LastName        NVARCHAR(50)    NOT NULL,
    BirthDate       DATE            NOT NULL,
    NationalityId   SMALLINT        NOT NULL,
    Gender          CHAR(1)             NULL,
    CreatedAt       DATETIME2(3)    NOT NULL CONSTRAINT DF_CrewMember_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy       NVARCHAR(100)   NOT NULL CONSTRAINT DF_CrewMember_CreatedBy DEFAULT SUSER_SNAME(),
    ModifiedAt      DATETIME2(3)        NULL,
    ModifiedBy      NVARCHAR(100)       NULL,
    RowVersion      ROWVERSION      NOT NULL,
    CONSTRAINT PK_CrewMember PRIMARY KEY CLUSTERED (CrewMemberId),
    CONSTRAINT UQ_CrewMember_DisplayId UNIQUE (DisplayId),
    CONSTRAINT FK_CrewMember_Nationality FOREIGN KEY (NationalityId)
        REFERENCES crew.Nationality (NationalityId),
    CONSTRAINT CK_CrewMember_DisplayId CHECK (LEN(LTRIM(RTRIM(DisplayId))) > 0),
    CONSTRAINT CK_CrewMember_Gender CHECK (Gender IS NULL OR Gender IN ('M','F','X')),
    CONSTRAINT CK_CrewMember_BirthDate CHECK (BirthDate < '2020-01-01')
);
GO

CREATE TABLE crew.CrewServiceHistory
(
    ServiceHistoryId    BIGINT          IDENTITY(1,1) NOT NULL,
    CrewMemberId        INT             NOT NULL,
    ShipId              INT             NOT NULL,
    RankId              SMALLINT        NOT NULL,
    SignOnDate          DATE            NOT NULL,
    SignOffDate         DATE                NULL,
    EndOfContractDate   DATE            NOT NULL,
    ContractReference   VARCHAR(30)         NULL,
    CreatedAt           DATETIME2(3)    NOT NULL CONSTRAINT DF_CrewServiceHistory_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy           NVARCHAR(100)   NOT NULL CONSTRAINT DF_CrewServiceHistory_CreatedBy DEFAULT SUSER_SNAME(),
    ModifiedAt          DATETIME2(3)        NULL,
    ModifiedBy          NVARCHAR(100)       NULL,
    RowVersion          ROWVERSION      NOT NULL,
    CONSTRAINT PK_CrewServiceHistory PRIMARY KEY CLUSTERED (ServiceHistoryId),
    CONSTRAINT FK_CrewServiceHistory_CrewMember FOREIGN KEY (CrewMemberId)
        REFERENCES crew.CrewMember (CrewMemberId),
    CONSTRAINT FK_CrewServiceHistory_Ship FOREIGN KEY (ShipId)
        REFERENCES fleet.Ship (ShipId),
    CONSTRAINT FK_CrewServiceHistory_CrewRank FOREIGN KEY (RankId)
        REFERENCES crew.CrewRank (RankId),
    CONSTRAINT CK_CrewServiceHistory_SignOff CHECK (SignOffDate IS NULL OR SignOffDate >= SignOnDate),
    CONSTRAINT CK_CrewServiceHistory_EndOfContract CHECK (EndOfContractDate >= SignOnDate)
);
GO

CREATE NONCLUSTERED INDEX IX_CrewServiceHistory_Ship_Active
    ON crew.CrewServiceHistory (ShipId, SignOnDate)
    INCLUDE (CrewMemberId, RankId, EndOfContractDate)
    WHERE SignOffDate IS NULL;
GO

CREATE NONCLUSTERED INDEX IX_CrewServiceHistory_CrewMember
    ON crew.CrewServiceHistory (CrewMemberId, SignOnDate DESC);
GO

CREATE TABLE app.AppRole
(
    RoleId      TINYINT         NOT NULL,
    RoleCode    VARCHAR(30)     NOT NULL,
    RoleName    NVARCHAR(50)    NOT NULL,
    CreatedAt   DATETIME2(3)    NOT NULL CONSTRAINT DF_AppRole_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy   NVARCHAR(100)   NOT NULL CONSTRAINT DF_AppRole_CreatedBy DEFAULT SUSER_SNAME(),
    ModifiedAt  DATETIME2(3)        NULL,
    ModifiedBy  NVARCHAR(100)       NULL,
    RowVersion  ROWVERSION      NOT NULL,
    CONSTRAINT PK_AppRole PRIMARY KEY CLUSTERED (RoleId),
    CONSTRAINT UQ_AppRole_RoleCode UNIQUE (RoleCode)
);
GO

CREATE TABLE app.AppUser
(
    UserId          INT             IDENTITY(1,1) NOT NULL,
    FullName        NVARCHAR(150)   NOT NULL,
    Email           NVARCHAR(256)   NOT NULL,
    RoleId          TINYINT         NOT NULL,
    PasswordHash    VARBINARY(256)      NULL,
    PasswordSalt    VARBINARY(128)      NULL,
    IsActive        BIT             NOT NULL CONSTRAINT DF_AppUser_IsActive DEFAULT 1,
    CreatedAt       DATETIME2(3)    NOT NULL CONSTRAINT DF_AppUser_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy       NVARCHAR(100)   NOT NULL CONSTRAINT DF_AppUser_CreatedBy DEFAULT SUSER_SNAME(),
    ModifiedAt      DATETIME2(3)        NULL,
    ModifiedBy      NVARCHAR(100)       NULL,
    RowVersion      ROWVERSION      NOT NULL,
    CONSTRAINT PK_AppUser PRIMARY KEY CLUSTERED (UserId),
    CONSTRAINT FK_AppUser_AppRole FOREIGN KEY (RoleId) REFERENCES app.AppRole (RoleId),
    CONSTRAINT CK_AppUser_Email CHECK (Email LIKE '_%@_%._%'),
    CONSTRAINT CK_AppUser_Credentials
        CHECK ((PasswordHash IS NULL AND PasswordSalt IS NULL)
            OR (PasswordHash IS NOT NULL AND PasswordSalt IS NOT NULL))
);
GO

CREATE UNIQUE NONCLUSTERED INDEX UX_AppUser_Email ON app.AppUser (Email);
GO

CREATE TABLE app.UserShipAssignment
(
    UserId      INT             NOT NULL,
    ShipId      INT             NOT NULL,
    AssignedAt  DATETIME2(3)    NOT NULL CONSTRAINT DF_UserShipAssignment_AssignedAt DEFAULT SYSUTCDATETIME(),
    AssignedBy  NVARCHAR(100)   NOT NULL CONSTRAINT DF_UserShipAssignment_AssignedBy DEFAULT SUSER_SNAME(),
    RowVersion  ROWVERSION      NOT NULL,
    CONSTRAINT PK_UserShipAssignment PRIMARY KEY CLUSTERED (UserId, ShipId),
    CONSTRAINT FK_UserShipAssignment_AppUser FOREIGN KEY (UserId)
        REFERENCES app.AppUser (UserId) ON DELETE CASCADE,
    CONSTRAINT FK_UserShipAssignment_Ship FOREIGN KEY (ShipId)
        REFERENCES fleet.Ship (ShipId)
);
GO

CREATE NONCLUSTERED INDEX IX_UserShipAssignment_Ship
    ON app.UserShipAssignment (ShipId, UserId);
GO

CREATE TABLE finance.Currency
(
    CurrencyCode    CHAR(3)         NOT NULL,
    CurrencyName    NVARCHAR(50)    NOT NULL,
    MinorUnits      TINYINT         NOT NULL CONSTRAINT DF_Currency_MinorUnits DEFAULT 2,
    CreatedAt       DATETIME2(3)    NOT NULL CONSTRAINT DF_Currency_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy       NVARCHAR(100)   NOT NULL CONSTRAINT DF_Currency_CreatedBy DEFAULT SUSER_SNAME(),
    ModifiedAt      DATETIME2(3)        NULL,
    ModifiedBy      NVARCHAR(100)       NULL,
    RowVersion      ROWVERSION      NOT NULL,
    CONSTRAINT PK_Currency PRIMARY KEY CLUSTERED (CurrencyCode),
    CONSTRAINT CK_Currency_MinorUnits CHECK (MinorUnits BETWEEN 0 AND 4)
);
GO

CREATE TABLE finance.ChartOfAccount
(
    AccountNumber       INT             NOT NULL,
    AccountDescription  NVARCHAR(200)   NOT NULL,
    ParentAccountNumber INT                 NULL,
    AccountLevel        TINYINT         NOT NULL,
    IsPostable          BIT             NOT NULL,
    AccountType         VARCHAR(20)     NOT NULL,
    IsActive            BIT             NOT NULL CONSTRAINT DF_ChartOfAccount_IsActive DEFAULT 1,
    CreatedAt           DATETIME2(3)    NOT NULL CONSTRAINT DF_ChartOfAccount_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy           NVARCHAR(100)   NOT NULL CONSTRAINT DF_ChartOfAccount_CreatedBy DEFAULT SUSER_SNAME(),
    ModifiedAt          DATETIME2(3)        NULL,
    ModifiedBy          NVARCHAR(100)       NULL,
    RowVersion          ROWVERSION      NOT NULL,
    CONSTRAINT PK_ChartOfAccount PRIMARY KEY CLUSTERED (AccountNumber),
    CONSTRAINT UQ_ChartOfAccount_Postable UNIQUE (AccountNumber, IsPostable),
    CONSTRAINT FK_ChartOfAccount_Parent FOREIGN KEY (ParentAccountNumber)
        REFERENCES finance.ChartOfAccount (AccountNumber),
    CONSTRAINT CK_ChartOfAccount_NotSelfParent CHECK (ParentAccountNumber <> AccountNumber),
    CONSTRAINT CK_ChartOfAccount_AccountNumber CHECK (AccountNumber > 0),
    CONSTRAINT CK_ChartOfAccount_AccountLevel CHECK (AccountLevel BETWEEN 1 AND 10),
    CONSTRAINT CK_ChartOfAccount_AccountType
        CHECK (AccountType IN ('Expense','Revenue','Asset','Liability')),
    CONSTRAINT CK_ChartOfAccount_RootLevel
        CHECK ((ParentAccountNumber IS NULL AND AccountLevel = 1)
            OR (ParentAccountNumber IS NOT NULL AND AccountLevel > 1))
);
GO

CREATE NONCLUSTERED INDEX IX_ChartOfAccount_Parent
    ON finance.ChartOfAccount (ParentAccountNumber) INCLUDE (AccountLevel, IsPostable);
GO

CREATE TABLE finance.AccountingPeriod
(
    PeriodKey       INT             NOT NULL,
    PeriodCode      CHAR(7)         NOT NULL,
    PeriodStartDate DATE            NOT NULL,
    PeriodEndDate   DATE            NOT NULL,
    CalendarYear    SMALLINT        NOT NULL,
    CalendarMonth   TINYINT         NOT NULL,
    IsClosed        BIT             NOT NULL CONSTRAINT DF_AccountingPeriod_IsClosed DEFAULT 0,
    CreatedAt       DATETIME2(3)    NOT NULL CONSTRAINT DF_AccountingPeriod_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy       NVARCHAR(100)   NOT NULL CONSTRAINT DF_AccountingPeriod_CreatedBy DEFAULT SUSER_SNAME(),
    ModifiedAt      DATETIME2(3)        NULL,
    ModifiedBy      NVARCHAR(100)       NULL,
    RowVersion      ROWVERSION      NOT NULL,
    CONSTRAINT PK_AccountingPeriod PRIMARY KEY CLUSTERED (PeriodKey),
    CONSTRAINT UQ_AccountingPeriod_PeriodCode UNIQUE (PeriodCode),
    CONSTRAINT CK_AccountingPeriod_CalendarMonth CHECK (CalendarMonth BETWEEN 1 AND 12),
    CONSTRAINT CK_AccountingPeriod_PeriodKey
        CHECK (PeriodKey = CalendarYear * 100 + CalendarMonth),
    CONSTRAINT CK_AccountingPeriod_Dates CHECK (PeriodEndDate >= PeriodStartDate)
);
GO

WITH Months AS
(
    SELECT CAST('2023-01-01' AS DATE) AS MonthStart
    UNION ALL
    SELECT DATEADD(MONTH, 1, MonthStart) FROM Months WHERE MonthStart < '2027-12-01'
)
INSERT finance.AccountingPeriod
    (PeriodKey, PeriodCode, PeriodStartDate, PeriodEndDate, CalendarYear, CalendarMonth)
SELECT  YEAR(MonthStart) * 100 + MONTH(MonthStart),
        CONVERT(CHAR(7), MonthStart, 126),
        MonthStart,
        EOMONTH(MonthStart),
        YEAR(MonthStart),
        MONTH(MonthStart)
FROM Months
OPTION (MAXRECURSION 200);
GO

CREATE TABLE finance.BudgetEntry
(
    BudgetEntryId   BIGINT          IDENTITY(1,1) NOT NULL,
    ShipId          INT             NOT NULL,
    AccountNumber   INT             NOT NULL,
    PeriodKey       INT             NOT NULL,
    BudgetValue     DECIMAL(19,4)   NOT NULL,
    CurrencyCode    CHAR(3)         NOT NULL CONSTRAINT DF_BudgetEntry_CurrencyCode DEFAULT 'USD',
    BudgetVersion   SMALLINT        NOT NULL CONSTRAINT DF_BudgetEntry_BudgetVersion DEFAULT 1,
    Remarks         NVARCHAR(250)       NULL,
    TargetIsPostable BIT            NOT NULL
                     CONSTRAINT DF_BudgetEntry_TargetIsPostable DEFAULT 1,
    CreatedAt       DATETIME2(3)    NOT NULL CONSTRAINT DF_BudgetEntry_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy       NVARCHAR(100)   NOT NULL CONSTRAINT DF_BudgetEntry_CreatedBy DEFAULT SUSER_SNAME(),
    ModifiedAt      DATETIME2(3)        NULL,
    ModifiedBy      NVARCHAR(100)       NULL,
    RowVersion      ROWVERSION      NOT NULL,
    CONSTRAINT PK_BudgetEntry PRIMARY KEY CLUSTERED (BudgetEntryId),
    CONSTRAINT FK_BudgetEntry_Ship FOREIGN KEY (ShipId) REFERENCES fleet.Ship (ShipId),
    CONSTRAINT FK_BudgetEntry_PostableAccount
        FOREIGN KEY (AccountNumber, TargetIsPostable)
        REFERENCES finance.ChartOfAccount (AccountNumber, IsPostable),
    CONSTRAINT FK_BudgetEntry_AccountingPeriod FOREIGN KEY (PeriodKey)
        REFERENCES finance.AccountingPeriod (PeriodKey),
    CONSTRAINT FK_BudgetEntry_Currency FOREIGN KEY (CurrencyCode)
        REFERENCES finance.Currency (CurrencyCode),
    CONSTRAINT CK_BudgetEntry_BudgetValue CHECK (BudgetValue >= 0),
    CONSTRAINT CK_BudgetEntry_BudgetVersion CHECK (BudgetVersion > 0),
    CONSTRAINT CK_BudgetEntry_TargetIsPostable CHECK (TargetIsPostable = 1)
);
GO

CREATE NONCLUSTERED INDEX IX_BudgetEntry_Ship_Period_Account
    ON finance.BudgetEntry (ShipId, PeriodKey, AccountNumber) INCLUDE (BudgetValue);
GO

CREATE TABLE finance.AccountTransaction
(
    AccountTransactionId    BIGINT          IDENTITY(1,1) NOT NULL,
    ShipId                  INT             NOT NULL,
    AccountNumber           INT             NOT NULL,
    PeriodKey               INT             NOT NULL,
    TransactionDate         DATE                NULL,
    ActualValue             DECIMAL(19,4)   NOT NULL,
    CurrencyCode            CHAR(3)         NOT NULL CONSTRAINT DF_AccountTransaction_CurrencyCode DEFAULT 'USD',
    VoucherReference        VARCHAR(40)         NULL,
    Description             NVARCHAR(250)       NULL,
    TargetIsPostable        BIT             NOT NULL
                            CONSTRAINT DF_AccountTransaction_TargetIsPostable DEFAULT 1,
    CreatedAt               DATETIME2(3)    NOT NULL CONSTRAINT DF_AccountTransaction_CreatedAt DEFAULT SYSUTCDATETIME(),
    CreatedBy               NVARCHAR(100)   NOT NULL CONSTRAINT DF_AccountTransaction_CreatedBy DEFAULT SUSER_SNAME(),
    ModifiedAt              DATETIME2(3)        NULL,
    ModifiedBy              NVARCHAR(100)       NULL,
    RowVersion              ROWVERSION      NOT NULL,
    CONSTRAINT PK_AccountTransaction PRIMARY KEY CLUSTERED (AccountTransactionId),
    CONSTRAINT FK_AccountTransaction_Ship FOREIGN KEY (ShipId) REFERENCES fleet.Ship (ShipId),
    CONSTRAINT FK_AccountTransaction_PostableAccount
        FOREIGN KEY (AccountNumber, TargetIsPostable)
        REFERENCES finance.ChartOfAccount (AccountNumber, IsPostable),
    CONSTRAINT FK_AccountTransaction_AccountingPeriod FOREIGN KEY (PeriodKey)
        REFERENCES finance.AccountingPeriod (PeriodKey),
    CONSTRAINT FK_AccountTransaction_Currency FOREIGN KEY (CurrencyCode)
        REFERENCES finance.Currency (CurrencyCode),
    CONSTRAINT CK_AccountTransaction_ActualValue CHECK (ActualValue >= 0),
    CONSTRAINT CK_AccountTransaction_TargetIsPostable CHECK (TargetIsPostable = 1)
);
GO

CREATE NONCLUSTERED INDEX IX_AccountTransaction_Ship_Period_Account
    ON finance.AccountTransaction (ShipId, PeriodKey, AccountNumber) INCLUDE (ActualValue);
GO

PRINT 'Schema created.';
GO
