namespace Ae.Maritime.Application.Finance;

public sealed record FinancialReportRow(
    int AccountNumber,
    string AccountDescription,
    int? ParentAccountNumber,
    byte AccountLevel,
    bool IsPostable,
    decimal? Actual,
    decimal? Budget,
    decimal Variance,
    decimal? ActualYtd,
    decimal? BudgetYtd,
    decimal VarianceYtd);

public sealed record FinancialReport(
    int ShipId,
    string PeriodCode,
    string FiscalYearStartCode,
    IReadOnlyList<FinancialReportRow> Rows);
