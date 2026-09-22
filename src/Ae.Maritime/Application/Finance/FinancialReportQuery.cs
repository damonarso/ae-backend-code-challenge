using FluentValidation;
using System.Text.RegularExpressions;

namespace Ae.Maritime.Application.Finance;

public sealed record FinancialReportQuery
{
    public required int ShipId { get; init; }

    public required string PeriodCode { get; init; }

    public bool IncludeZeroRows { get; init; }
}

public sealed partial class FinancialReportQueryValidator : AbstractValidator<FinancialReportQuery>
{
    public FinancialReportQueryValidator()
    {
        RuleFor(x => x.ShipId)
            .GreaterThan(0).WithMessage("ShipId must be a positive integer.");

        RuleFor(x => x.PeriodCode)
            .NotEmpty().WithMessage("PeriodCode is required.")
            .Must(p => p is not null && PeriodPattern().IsMatch(p))
            .WithMessage("PeriodCode must be in YYYY-MM format, for example 2025-02.");
    }

    [GeneratedRegex(@"^\d{4}-(0[1-9]|1[0-2])$")]
    private static partial Regex PeriodPattern();
}

public sealed record FinancialSummaryQuery
{
    public required int ShipId { get; init; }
    public required string PeriodCode { get; init; }
    public byte MaxLevel { get; init; } = 2;
}

public sealed class FinancialSummaryQueryValidator : AbstractValidator<FinancialSummaryQuery>
{
    public FinancialSummaryQueryValidator()
    {
        RuleFor(x => x.ShipId).GreaterThan(0);
        RuleFor(x => x.MaxLevel).InclusiveBetween((byte)1, (byte)10);
        RuleFor(x => x.PeriodCode).NotEmpty();
    }
}
