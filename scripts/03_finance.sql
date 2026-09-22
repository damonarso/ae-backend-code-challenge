CREATE OR ALTER FUNCTION finance.GetFiscalYearStart
(
    @FiscalYearCode CHAR(4),
    @PeriodKey      INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT FiscalYearStartKey =
           CASE WHEN (@PeriodKey % 100) >= f.StartMonth
                THEN (@PeriodKey / 100)
                ELSE (@PeriodKey / 100) - 1
           END * 100 + f.StartMonth
    FROM fleet.FiscalYearPattern f
    WHERE f.FiscalYearCode = @FiscalYearCode
);
GO

CREATE OR ALTER FUNCTION finance.GetAccountDescendants
(
    @AccountNumber INT
)
RETURNS TABLE
AS
RETURN
(
    WITH Tree AS
    (
        SELECT c.AccountNumber, c.AccountLevel
        FROM finance.ChartOfAccount c
        WHERE c.AccountNumber = @AccountNumber

        UNION ALL

        SELECT child.AccountNumber, child.AccountLevel
        FROM finance.ChartOfAccount child
        JOIN Tree parent ON parent.AccountNumber = child.ParentAccountNumber
    )
    SELECT AccountNumber, AccountLevel FROM Tree
);
GO

CREATE OR ALTER PROCEDURE finance.GetReportDetail
    @ShipId          INT,
    @PeriodCode      CHAR(7),
    @IncludeZeroRows BIT = 0
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM fleet.Ship WHERE ShipId = @ShipId)
        THROW 50104, 'Ship not found.', 1;

    DECLARE @FiscalYearCode CHAR(4);

    SELECT @FiscalYearCode = s.FiscalYearCode
    FROM fleet.Ship s
    JOIN fleet.ShipStatus ss ON ss.ShipStatusId = s.ShipStatusId
    WHERE s.ShipId = @ShipId AND ss.IsOperational = 1;

    IF @FiscalYearCode IS NULL
        THROW 50105, 'Ship is not active; operational queries are restricted to active ships.', 1;

    DECLARE @PeriodKey INT =
        (SELECT PeriodKey FROM finance.AccountingPeriod WHERE PeriodCode = @PeriodCode);

    IF @PeriodKey IS NULL
        THROW 50400, 'Unknown accounting period. Expected format YYYY-MM within the defined calendar.', 1;

    DECLARE @FiscalYearStartKey INT =
        (SELECT FiscalYearStartKey FROM finance.GetFiscalYearStart(@FiscalYearCode, @PeriodKey));

    ;WITH BudgetLeaf AS
    (
        SELECT  b.AccountNumber,
                BudgetPeriod = SUM(CASE WHEN b.PeriodKey = @PeriodKey THEN b.BudgetValue END),
                BudgetYtd    = SUM(b.BudgetValue)
        FROM finance.BudgetEntry b
        WHERE b.ShipId    = @ShipId
          AND b.PeriodKey BETWEEN @FiscalYearStartKey AND @PeriodKey
        GROUP BY b.AccountNumber
    ),
    ActualLeaf AS
    (
        SELECT  t.AccountNumber,
                ActualPeriod = SUM(CASE WHEN t.PeriodKey = @PeriodKey THEN t.ActualValue END),
                ActualYtd    = SUM(t.ActualValue)
        FROM finance.AccountTransaction t
        WHERE t.ShipId    = @ShipId
          AND t.PeriodKey BETWEEN @FiscalYearStartKey AND @PeriodKey
        GROUP BY t.AccountNumber
    ),
    Leaf AS
    (
        SELECT  AccountNumber = COALESCE(b.AccountNumber, a.AccountNumber),
                b.BudgetPeriod, b.BudgetYtd,
                a.ActualPeriod, a.ActualYtd
        FROM BudgetLeaf b
        FULL OUTER JOIN ActualLeaf a ON a.AccountNumber = b.AccountNumber
    ),
    Rolled AS
    (
        SELECT  coa.AccountNumber,
                coa.AccountDescription,
                coa.ParentAccountNumber,
                coa.AccountLevel,
                coa.IsPostable,
                agg.ActualPeriod, agg.BudgetPeriod,
                agg.ActualYtd,    agg.BudgetYtd
        FROM finance.ChartOfAccount coa
        OUTER APPLY
        (
            SELECT  ActualPeriod = SUM(l.ActualPeriod),
                    BudgetPeriod = SUM(l.BudgetPeriod),
                    ActualYtd    = SUM(l.ActualYtd),
                    BudgetYtd    = SUM(l.BudgetYtd)
            FROM finance.GetAccountDescendants(coa.AccountNumber) d
            JOIN Leaf l ON l.AccountNumber = d.AccountNumber
        ) agg
        WHERE coa.IsActive = 1
    )
    SELECT  [COA Description]   = r.AccountDescription,
            [Account Number]    = r.AccountNumber,
            ParentAccountNumber = r.ParentAccountNumber,
            AccountLevel        = r.AccountLevel,
            IsPostable          = r.IsPostable,
            [Actual]            = r.ActualPeriod,
            [Budget]            = r.BudgetPeriod,
            [Variance]          = ISNULL(r.ActualPeriod, 0) - ISNULL(r.BudgetPeriod, 0),
            [Actual YTD]        = r.ActualYtd,
            [Budget YTD]        = r.BudgetYtd,
            [Variance YTD]      = ISNULL(r.ActualYtd, 0) - ISNULL(r.BudgetYtd, 0),
            PeriodCode          = @PeriodCode,
            FiscalYearStartCode = (SELECT PeriodCode FROM finance.AccountingPeriod
                                   WHERE PeriodKey = @FiscalYearStartKey)
    FROM Rolled r
    WHERE @IncludeZeroRows = 1
       OR ISNULL(r.ActualPeriod, 0) <> 0
       OR ISNULL(r.BudgetPeriod, 0) <> 0
       OR ISNULL(r.ActualYtd, 0)    <> 0
       OR ISNULL(r.BudgetYtd, 0)    <> 0
    ORDER BY r.AccountNumber;
END;
GO

CREATE OR ALTER PROCEDURE finance.GetReportSummary
    @ShipId     INT,
    @PeriodCode CHAR(7),
    @MaxLevel   TINYINT = 2
AS
BEGIN
    IF @MaxLevel IS NULL OR @MaxLevel < 1
        THROW 50401, 'MaxLevel must be 1 or greater.', 1;

    IF NOT EXISTS (SELECT 1 FROM fleet.Ship WHERE ShipId = @ShipId)
        THROW 50104, 'Ship not found.', 1;

    DECLARE @FiscalYearCode CHAR(4);

    SELECT @FiscalYearCode = s.FiscalYearCode
    FROM fleet.Ship s
    JOIN fleet.ShipStatus ss ON ss.ShipStatusId = s.ShipStatusId
    WHERE s.ShipId = @ShipId AND ss.IsOperational = 1;

    IF @FiscalYearCode IS NULL
        THROW 50105, 'Ship is not active; operational queries are restricted to active ships.', 1;

    DECLARE @PeriodKey INT =
        (SELECT PeriodKey FROM finance.AccountingPeriod WHERE PeriodCode = @PeriodCode);

    IF @PeriodKey IS NULL
        THROW 50400, 'Unknown accounting period. Expected format YYYY-MM within the defined calendar.', 1;

    DECLARE @FiscalYearStartKey INT =
        (SELECT FiscalYearStartKey FROM finance.GetFiscalYearStart(@FiscalYearCode, @PeriodKey));

    ;WITH Leaf AS
    (
        SELECT  AccountNumber = COALESCE(b.AccountNumber, a.AccountNumber),
                b.BudgetPeriod, b.BudgetYtd, a.ActualPeriod, a.ActualYtd
        FROM
        (
            SELECT  b.AccountNumber,
                    BudgetPeriod = SUM(CASE WHEN b.PeriodKey = @PeriodKey THEN b.BudgetValue END),
                    BudgetYtd    = SUM(b.BudgetValue)
            FROM finance.BudgetEntry b
            WHERE b.ShipId    = @ShipId
              AND b.PeriodKey BETWEEN @FiscalYearStartKey AND @PeriodKey
            GROUP BY b.AccountNumber
        ) b
        FULL OUTER JOIN
        (
            SELECT  t.AccountNumber,
                    ActualPeriod = SUM(CASE WHEN t.PeriodKey = @PeriodKey THEN t.ActualValue END),
                    ActualYtd    = SUM(t.ActualValue)
            FROM finance.AccountTransaction t
            WHERE t.ShipId    = @ShipId
              AND t.PeriodKey BETWEEN @FiscalYearStartKey AND @PeriodKey
            GROUP BY t.AccountNumber
        ) a ON a.AccountNumber = b.AccountNumber
    )
    SELECT  [COA Description] = coa.AccountDescription,
            [Account Number]  = coa.AccountNumber,
            AccountLevel      = coa.AccountLevel,
            [Actual]          = agg.ActualPeriod,
            [Budget]          = agg.BudgetPeriod,
            [Variance]        = ISNULL(agg.ActualPeriod, 0) - ISNULL(agg.BudgetPeriod, 0),
            [Actual YTD]      = agg.ActualYtd,
            [Budget YTD]      = agg.BudgetYtd,
            [Variance YTD]    = ISNULL(agg.ActualYtd, 0) - ISNULL(agg.BudgetYtd, 0),
            PeriodCode        = @PeriodCode
    FROM finance.ChartOfAccount coa
    OUTER APPLY
    (
        SELECT  ActualPeriod = SUM(l.ActualPeriod),
                BudgetPeriod = SUM(l.BudgetPeriod),
                ActualYtd    = SUM(l.ActualYtd),
                BudgetYtd    = SUM(l.BudgetYtd)
        FROM finance.GetAccountDescendants(coa.AccountNumber) d
        JOIN Leaf l ON l.AccountNumber = d.AccountNumber
    ) agg
    WHERE coa.IsActive     = 1
      AND coa.IsPostable   = 0
      AND coa.AccountLevel <= @MaxLevel
      AND (ISNULL(agg.ActualPeriod, 0) <> 0 OR ISNULL(agg.BudgetPeriod, 0) <> 0
        OR ISNULL(agg.ActualYtd, 0)    <> 0 OR ISNULL(agg.BudgetYtd, 0)    <> 0)
    ORDER BY coa.AccountNumber;
END;
GO

PRINT 'Finance objects created.';
GO
