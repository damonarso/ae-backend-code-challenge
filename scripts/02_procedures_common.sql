CREATE OR ALTER PROCEDURE crew.GetCrewList
    @ShipId         INT,
    @AsOfDate       DATE          = NULL,
    @SearchTerm     NVARCHAR(100) = NULL,
    @SortColumn     VARCHAR(30)   = 'RankName',
    @SortDirection  VARCHAR(4)    = 'ASC',
    @PageNumber     INT           = 1,
    @PageSize       INT           = 25
AS
BEGIN
    SET @AsOfDate      = ISNULL(@AsOfDate, CAST(SYSUTCDATETIME() AS DATE));
    SET @SearchTerm    = NULLIF(LTRIM(RTRIM(@SearchTerm)), '');
    SET @SortColumn    = ISNULL(NULLIF(LTRIM(RTRIM(@SortColumn)), ''), 'RankName');
    SET @SortDirection = UPPER(ISNULL(NULLIF(LTRIM(RTRIM(@SortDirection)), ''), 'ASC'));

    IF @PageNumber IS NULL OR @PageNumber < 1
        THROW 50100, 'PageNumber must be 1 or greater.', 1;

    IF @PageSize IS NULL OR @PageSize < 1 OR @PageSize > 200
        THROW 50101, 'PageSize must be between 1 and 200.', 1;

    IF @SortDirection NOT IN ('ASC','DESC')
        THROW 50102, 'SortDirection must be ASC or DESC.', 1;

    IF @SortColumn NOT IN ('RankName','DisplayId','FirstName','LastName',
                           'Age','Nationality','SignOnDate','Status')
        THROW 50103, 'SortColumn is not a sortable column.', 1;

    IF NOT EXISTS (SELECT 1 FROM fleet.Ship WHERE ShipId = @ShipId)
        THROW 50104, 'Ship not found.', 1;

    IF NOT EXISTS (SELECT 1
                   FROM fleet.Ship s
                   JOIN fleet.ShipStatus ss ON ss.ShipStatusId = s.ShipStatusId
                   WHERE s.ShipId = @ShipId AND ss.IsOperational = 1)
        THROW 50105, 'Ship is not active; operational queries are restricted to active ships.', 1;

    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    ;WITH ActiveService AS
    (
        SELECT  csh.ServiceHistoryId,
                cm.DisplayId,
                csh.SignOnDate,
                csh.EndOfContractDate,
                r.RankName,
                r.SeniorityOrder,
                cm.FirstName,
                cm.LastName,
                n.NationalityName AS Nationality,
                Age = DATEDIFF(YEAR, cm.BirthDate, @AsOfDate)
                      - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, cm.BirthDate, @AsOfDate),
                                          cm.BirthDate) > @AsOfDate
                             THEN 1 ELSE 0 END,
                [Status] = CASE
                               WHEN DATEDIFF(DAY, csh.EndOfContractDate, @AsOfDate) > 30
                                   THEN 'Relief Due'
                               ELSE 'Onboard'
                           END
        FROM crew.CrewServiceHistory csh
        JOIN crew.CrewMember  cm ON cm.CrewMemberId = csh.CrewMemberId
        JOIN crew.CrewRank    r  ON r.RankId        = csh.RankId
        JOIN crew.Nationality n  ON n.NationalityId = cm.NationalityId
        WHERE csh.ShipId       = @ShipId
          AND csh.SignOffDate IS NULL
          AND csh.SignOnDate  <= @AsOfDate
    ),
    Filtered AS
    (
        SELECT a.*,
               SignOnDateDisplay = FORMAT(a.SignOnDate, 'dd MMM yyyy', 'en-GB')
        FROM ActiveService a
        WHERE @SearchTerm IS NULL
           OR a.DisplayId                      LIKE '%' + @SearchTerm + '%'
           OR a.RankName                       LIKE '%' + @SearchTerm + '%'
           OR a.FirstName                      LIKE '%' + @SearchTerm + '%'
           OR a.LastName                       LIKE '%' + @SearchTerm + '%'
           OR a.Nationality                    LIKE '%' + @SearchTerm + '%'
           OR CAST(a.Age AS VARCHAR(3))        LIKE '%' + @SearchTerm + '%'
           OR FORMAT(a.SignOnDate, 'dd MMM yyyy', 'en-GB') LIKE '%' + @SearchTerm + '%'
           OR CONVERT(CHAR(10), a.SignOnDate, 23)          LIKE '%' + @SearchTerm + '%'
    )
    SELECT  [Rank Name]         = RankName,
            [Crew Member ID]    = DisplayId,
            [First Name]        = FirstName,
            [Last Name]         = LastName,
            Age,
            Nationality,
            SignOnDate,
            SignOnDateDisplay,
            [Status],
            TotalCount = COUNT(*) OVER ()
    FROM Filtered
    ORDER BY
        CASE WHEN @SortDirection = 'ASC' THEN
            CASE @SortColumn
                WHEN 'RankName'    THEN RankName
                WHEN 'DisplayId'   THEN DisplayId
                WHEN 'FirstName'   THEN FirstName
                WHEN 'LastName'    THEN LastName
                WHEN 'Nationality' THEN Nationality
                WHEN 'Status'      THEN [Status]
            END
        END ASC,
        CASE WHEN @SortDirection = 'DESC' THEN
            CASE @SortColumn
                WHEN 'RankName'    THEN RankName
                WHEN 'DisplayId'   THEN DisplayId
                WHEN 'FirstName'   THEN FirstName
                WHEN 'LastName'    THEN LastName
                WHEN 'Nationality' THEN Nationality
                WHEN 'Status'      THEN [Status]
            END
        END DESC,
        CASE WHEN @SortDirection = 'ASC'  AND @SortColumn = 'Age' THEN Age END ASC,
        CASE WHEN @SortDirection = 'DESC' AND @SortColumn = 'Age' THEN Age END DESC,
        CASE WHEN @SortDirection = 'ASC'  AND @SortColumn = 'SignOnDate' THEN SignOnDate END ASC,
        CASE WHEN @SortDirection = 'DESC' AND @SortColumn = 'SignOnDate' THEN SignOnDate END DESC,
        SeniorityOrder,
        ServiceHistoryId
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END;
GO

CREATE OR ALTER PROCEDURE fleet.GetShipById
    @ShipId INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM fleet.Ship WHERE ShipId = @ShipId)
        THROW 50104, 'Ship not found.', 1;

    SELECT  s.ShipId,
            s.DisplayId,
            s.ShipName,
            s.FiscalYearCode,
            f.Description AS FiscalYearDescription,
            f.StartMonth  AS FiscalYearStartMonth,
            f.EndMonth    AS FiscalYearEndMonth,
            ss.StatusCode,
            ss.StatusName,
            s.IMONumber,
            s.CreatedAt,
            s.ModifiedAt
    FROM fleet.Ship s
    JOIN fleet.ShipStatus        ss ON ss.ShipStatusId  = s.ShipStatusId
    JOIN fleet.FiscalYearPattern f  ON f.FiscalYearCode = s.FiscalYearCode
    WHERE s.ShipId = @ShipId;
END;
GO

CREATE OR ALTER PROCEDURE fleet.GetShips
    @StatusCode VARCHAR(20)   = NULL,
    @SearchTerm NVARCHAR(100) = NULL,
    @PageNumber INT           = 1,
    @PageSize   INT           = 25
AS
BEGIN
    IF @PageNumber IS NULL OR @PageNumber < 1
        THROW 50100, 'PageNumber must be 1 or greater.', 1;

    IF @PageSize IS NULL OR @PageSize < 1 OR @PageSize > 200
        THROW 50101, 'PageSize must be between 1 and 200.', 1;

    SET @SearchTerm = NULLIF(LTRIM(RTRIM(@SearchTerm)), '');

    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    SELECT  s.ShipId,
            s.DisplayId,
            s.ShipName,
            s.FiscalYearCode,
            f.Description AS FiscalYearDescription,
            ss.StatusCode,
            ss.StatusName,
            s.IMONumber,
            TotalCount = COUNT(*) OVER ()
    FROM fleet.Ship s
    JOIN fleet.ShipStatus        ss ON ss.ShipStatusId  = s.ShipStatusId
    JOIN fleet.FiscalYearPattern f  ON f.FiscalYearCode = s.FiscalYearCode
    WHERE (@StatusCode IS NULL OR ss.StatusCode = @StatusCode)
      AND (@SearchTerm IS NULL
           OR s.DisplayId LIKE '%' + @SearchTerm + '%'
           OR s.ShipName  LIKE '%' + @SearchTerm + '%')
    ORDER BY s.ShipId
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END;
GO

CREATE OR ALTER PROCEDURE fleet.CreateShip
    @ShipName       NVARCHAR(100),
    @FiscalYearCode CHAR(4),
    @StatusCode     VARCHAR(20)   = 'ACTIVE',
    @DisplayId      VARCHAR(20)   = NULL,
    @IMONumber      CHAR(7)       = NULL,
    @CreatedBy      NVARCHAR(100) = NULL
AS
BEGIN
    BEGIN TRY
        SET @ShipName  = NULLIF(LTRIM(RTRIM(@ShipName)), '');
        SET @DisplayId = NULLIF(LTRIM(RTRIM(@DisplayId)), '');

        IF @ShipName IS NULL THROW 50201, 'ShipName is required.', 1;

        IF NOT EXISTS (SELECT 1 FROM fleet.FiscalYearPattern WHERE FiscalYearCode = @FiscalYearCode)
            THROW 50203, 'Unknown fiscal year code.', 1;

        DECLARE @ShipStatusId TINYINT =
            (SELECT ShipStatusId FROM fleet.ShipStatus WHERE StatusCode = @StatusCode);

        IF @ShipStatusId IS NULL THROW 50204, 'Unknown ship status code.', 1;

        IF EXISTS (SELECT 1 FROM fleet.Ship WHERE ShipName = @ShipName)
            THROW 50205, 'A ship with this name already exists.', 1;

        IF @DisplayId IS NOT NULL
           AND EXISTS (SELECT 1 FROM fleet.Ship WHERE DisplayId = @DisplayId)
            THROW 50202, 'A ship with this display id already exists.', 1;

        DECLARE @ShipId INT = NEXT VALUE FOR fleet.ShipIdSequence;
        SET @DisplayId = ISNULL(@DisplayId, 'SHIP' + FORMAT(@ShipId, '00'));

        BEGIN TRANSACTION;

            INSERT fleet.Ship
                (ShipId, DisplayId, ShipName, FiscalYearCode, ShipStatusId, IMONumber, CreatedBy)
            VALUES
                (@ShipId, @DisplayId, @ShipName, @FiscalYearCode, @ShipStatusId, @IMONumber,
                 ISNULL(@CreatedBy, SUSER_SNAME()));

        COMMIT TRANSACTION;

        EXEC fleet.GetShipById @ShipId = @ShipId;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE app.GetUserById
    @UserId INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM app.AppUser WHERE UserId = @UserId)
        THROW 50305, 'User not found.', 1;

    SELECT  u.UserId, u.FullName, u.Email, r.RoleCode, r.RoleName,
            u.IsActive, u.CreatedAt, u.ModifiedAt
    FROM app.AppUser u
    JOIN app.AppRole r ON r.RoleId = u.RoleId
    WHERE u.UserId = @UserId;
END;
GO

CREATE OR ALTER PROCEDURE app.GetUsers
    @IncludeInactive BIT           = 0,
    @SearchTerm      NVARCHAR(100) = NULL,
    @PageNumber      INT           = 1,
    @PageSize        INT           = 25
AS
BEGIN
    IF @PageNumber IS NULL OR @PageNumber < 1
        THROW 50100, 'PageNumber must be 1 or greater.', 1;

    IF @PageSize IS NULL OR @PageSize < 1 OR @PageSize > 200
        THROW 50101, 'PageSize must be between 1 and 200.', 1;

    SET @SearchTerm = NULLIF(LTRIM(RTRIM(@SearchTerm)), '');

    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    SELECT  u.UserId,
            u.FullName,
            u.Email,
            r.RoleCode,
            r.RoleName,
            u.IsActive,
            AssignedShipCount = (SELECT COUNT(*) FROM app.UserShipAssignment a
                                 WHERE a.UserId = u.UserId),
            TotalCount = COUNT(*) OVER ()
    FROM app.AppUser u
    JOIN app.AppRole r ON r.RoleId = u.RoleId
    WHERE (@IncludeInactive = 1 OR u.IsActive = 1)
      AND (@SearchTerm IS NULL
           OR u.FullName LIKE '%' + @SearchTerm + '%'
           OR u.Email    LIKE '%' + @SearchTerm + '%')
    ORDER BY u.FullName, u.UserId
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END;
GO

CREATE OR ALTER PROCEDURE app.CreateUser
    @FullName     NVARCHAR(150),
    @Email        NVARCHAR(256),
    @RoleCode     VARCHAR(30),
    @PasswordHash VARBINARY(256) = NULL,
    @PasswordSalt VARBINARY(128) = NULL,
    @CreatedBy    NVARCHAR(100)  = NULL
AS
BEGIN
    BEGIN TRY
        SET @FullName = NULLIF(LTRIM(RTRIM(@FullName)), '');
        SET @Email    = LOWER(NULLIF(LTRIM(RTRIM(@Email)), ''));

        IF @FullName IS NULL THROW 50300, 'FullName is required.', 1;
        IF @Email    IS NULL THROW 50301, 'Email is required.', 1;
        IF @Email NOT LIKE '_%@_%._%' THROW 50302, 'Email format is invalid.', 1;

        IF (@PasswordHash IS NULL AND @PasswordSalt IS NOT NULL)
        OR (@PasswordHash IS NOT NULL AND @PasswordSalt IS NULL)
            THROW 50307, 'PasswordHash and PasswordSalt must be supplied together.', 1;

        IF EXISTS (SELECT 1 FROM app.AppUser WHERE Email = @Email)
            THROW 50303, 'A user with this email already exists.', 1;

        DECLARE @RoleId TINYINT = (SELECT RoleId FROM app.AppRole WHERE RoleCode = @RoleCode);
        IF @RoleId IS NULL THROW 50304, 'Unknown role code.', 1;

        DECLARE @NewUserId INT;

        BEGIN TRANSACTION;

            INSERT app.AppUser (FullName, Email, RoleId, PasswordHash, PasswordSalt, CreatedBy)
            VALUES (@FullName, @Email, @RoleId, @PasswordHash, @PasswordSalt,
                    ISNULL(@CreatedBy, SUSER_SNAME()));

            SET @NewUserId = CAST(SCOPE_IDENTITY() AS INT);

        COMMIT TRANSACTION;

        EXEC app.GetUserById @UserId = @NewUserId;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE app.GetShipsByUser
    @UserId          INT,
    @ActiveShipsOnly BIT = 1
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM app.AppUser WHERE UserId = @UserId)
        THROW 50305, 'User not found.', 1;

    SELECT  s.ShipId,
            s.DisplayId,
            s.ShipName,
            s.FiscalYearCode,
            ss.StatusCode,
            ss.StatusName,
            a.AssignedAt
    FROM app.UserShipAssignment a
    JOIN fleet.Ship       s  ON s.ShipId        = a.ShipId
    JOIN fleet.ShipStatus ss ON ss.ShipStatusId = s.ShipStatusId
    WHERE a.UserId = @UserId
      AND (@ActiveShipsOnly = 0 OR ss.IsOperational = 1)
    ORDER BY s.ShipId;
END;
GO

CREATE OR ALTER PROCEDURE app.AssignShip
    @UserId     INT,
    @ShipId     INT,
    @AssignedBy NVARCHAR(100) = NULL
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM app.AppUser WHERE UserId = @UserId AND IsActive = 1)
            THROW 50305, 'User not found or inactive.', 1;

        IF NOT EXISTS (SELECT 1 FROM fleet.Ship WHERE ShipId = @ShipId)
            THROW 50104, 'Ship not found.', 1;

        BEGIN TRANSACTION;

            IF NOT EXISTS (SELECT 1 FROM app.UserShipAssignment
                           WHERE UserId = @UserId AND ShipId = @ShipId)
            BEGIN
                INSERT app.UserShipAssignment (UserId, ShipId, AssignedBy)
                VALUES (@UserId, @ShipId, ISNULL(@AssignedBy, SUSER_SNAME()));
            END

        COMMIT TRANSACTION;

        EXEC app.GetShipsByUser @UserId = @UserId, @ActiveShipsOnly = 0;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

PRINT 'Common procedures created.';
GO
