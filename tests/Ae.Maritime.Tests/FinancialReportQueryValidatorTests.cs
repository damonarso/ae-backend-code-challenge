using Ae.Maritime.Application.Finance;
using FluentAssertions;
using Xunit;

namespace Ae.Maritime.Tests;

public sealed class FinancialReportQueryValidatorTests
{
    private readonly FinancialReportQueryValidator _validator = new();

    [Theory]
    [InlineData("2025-01")]
    [InlineData("2024-12")]
    [InlineData("2025-04")]
    public void Accepts_a_well_formed_period(string period)
    {
        var result = _validator.Validate(new FinancialReportQuery { ShipId = 1, PeriodCode = period });
        result.IsValid.Should().BeTrue();
    }

    [Theory]
    [InlineData("2025-13")]
    [InlineData("2025-00")]
    [InlineData("2025-1")]
    [InlineData("202501")]
    [InlineData("Jan-2025")]
    [InlineData("")]
    public void Rejects_a_malformed_period(string period)
    {
        var result = _validator.Validate(new FinancialReportQuery { ShipId = 1, PeriodCode = period });
        result.IsValid.Should().BeFalse();
    }
}
