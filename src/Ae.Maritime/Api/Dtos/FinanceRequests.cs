namespace Ae.Maritime.Api.Dtos;

public sealed record GetFinancialReportDetailRequest
{
    public required string Period { get; init; }
    public bool IncludeZeroRows { get; init; }
}

public sealed record GetFinancialReportSummaryRequest
{
    public required string Period { get; init; }
    public byte MaxLevel { get; init; } = 2;
}
