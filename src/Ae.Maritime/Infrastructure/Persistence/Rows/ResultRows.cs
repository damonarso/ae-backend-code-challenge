namespace Ae.Maritime.Infrastructure.Persistence.Rows;

internal sealed class CrewListRow
{
    public string RankName { get; set; } = null!;
    public string CrewMemberDisplayId { get; set; } = null!;
    public string FirstName { get; set; } = null!;
    public string LastName { get; set; } = null!;
    public int Age { get; set; }
    public string Nationality { get; set; } = null!;
    public DateOnly SignOnDate { get; set; }
    public string SignOnDateDisplay { get; set; } = null!;
    public string Status { get; set; } = null!;
    public int TotalCount { get; set; }
}

internal sealed class ShipSummaryRow
{
    public int ShipId { get; set; }
    public string DisplayId { get; set; } = null!;
    public string ShipName { get; set; } = null!;
    public string FiscalYearCode { get; set; } = null!;
    public string FiscalYearDescription { get; set; } = null!;
    public string StatusCode { get; set; } = null!;
    public string StatusName { get; set; } = null!;
    public string? ImoNumber { get; set; }
    public int TotalCount { get; set; }
}

internal sealed class ShipDetailRow
{
    public int ShipId { get; set; }
    public string DisplayId { get; set; } = null!;
    public string ShipName { get; set; } = null!;
    public string FiscalYearCode { get; set; } = null!;
    public string FiscalYearDescription { get; set; } = null!;
    public byte FiscalYearStartMonth { get; set; }
    public byte FiscalYearEndMonth { get; set; }
    public string StatusCode { get; set; } = null!;
    public string StatusName { get; set; } = null!;
    public string? ImoNumber { get; set; }

    public DateTime CreatedAt { get; set; }
    public DateTime? ModifiedAt { get; set; }
}

internal sealed class UserSummaryRow
{
    public int UserId { get; set; }
    public string FullName { get; set; } = null!;
    public string Email { get; set; } = null!;
    public string RoleCode { get; set; } = null!;
    public string RoleName { get; set; } = null!;
    public bool IsActive { get; set; }
    public int AssignedShipCount { get; set; }
    public int TotalCount { get; set; }
}

internal sealed class UserDetailRow
{
    public int UserId { get; set; }
    public string FullName { get; set; } = null!;
    public string Email { get; set; } = null!;
    public string RoleCode { get; set; } = null!;
    public string RoleName { get; set; } = null!;
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? ModifiedAt { get; set; }
}

internal sealed class AssignedShipRow
{
    public int ShipId { get; set; }
    public string DisplayId { get; set; } = null!;
    public string ShipName { get; set; } = null!;
    public string FiscalYearCode { get; set; } = null!;
    public string StatusCode { get; set; } = null!;
    public string StatusName { get; set; } = null!;
    public DateTime AssignedAt { get; set; }
}

internal sealed class FinancialReportDetailRow
{
    public string AccountDescription { get; set; } = null!;
    public int AccountNumber { get; set; }
    public int? ParentAccountNumber { get; set; }
    public byte AccountLevel { get; set; }
    public bool IsPostable { get; set; }

    public decimal? Actual { get; set; }
    public decimal? Budget { get; set; }
    public decimal Variance { get; set; }
    public decimal? ActualYtd { get; set; }
    public decimal? BudgetYtd { get; set; }
    public decimal VarianceYtd { get; set; }

    public string PeriodCode { get; set; } = null!;
    public string FiscalYearStartCode { get; set; } = null!;
}

internal sealed class FinancialReportSummaryRow
{
    public string AccountDescription { get; set; } = null!;
    public int AccountNumber { get; set; }
    public byte AccountLevel { get; set; }
    public decimal? Actual { get; set; }
    public decimal? Budget { get; set; }
    public decimal Variance { get; set; }
    public decimal? ActualYtd { get; set; }
    public decimal? BudgetYtd { get; set; }
    public decimal VarianceYtd { get; set; }
    public string PeriodCode { get; set; } = null!;
}
