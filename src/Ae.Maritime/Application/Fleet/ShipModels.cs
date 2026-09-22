using Ae.Maritime.Application.Common;
using FluentValidation;

namespace Ae.Maritime.Application.Fleet;

public sealed record ShipSummary(
    int ShipId,
    string DisplayId,
    string ShipName,
    string FiscalYearCode,
    string FiscalYearDescription,
    string StatusCode,
    string StatusName,
    string? ImoNumber);

public sealed record ShipDetail(
    int ShipId,
    string DisplayId,
    string ShipName,
    string FiscalYearCode,
    string FiscalYearDescription,
    byte FiscalYearStartMonth,
    byte FiscalYearEndMonth,
    string StatusCode,
    string StatusName,
    string? ImoNumber,
    DateTimeOffset CreatedAt,
    DateTimeOffset? ModifiedAt);

public sealed record ShipListQuery : PagedQuery
{
    public string? StatusCode { get; init; }
    public string? SearchTerm { get; init; }
}

public sealed class ShipListQueryValidator : AbstractValidator<ShipListQuery>
{
    public ShipListQueryValidator()
    {
        Include(new PagedQueryValidator());
        RuleFor(x => x.SearchTerm).MaximumLength(100);
        RuleFor(x => x.StatusCode).MaximumLength(20);
    }
}

public sealed record CreateShipCommand
{
    public required string ShipName { get; init; }
    public required string FiscalYearCode { get; init; }
    public string StatusCode { get; init; } = "ACTIVE";

    public string? DisplayId { get; init; }

    public string? ImoNumber { get; init; }
}

public sealed class CreateShipCommandValidator : AbstractValidator<CreateShipCommand>
{
    public CreateShipCommandValidator()
    {
        RuleFor(x => x.ShipName).NotEmpty().MaximumLength(100);

        RuleFor(x => x.FiscalYearCode)
            .NotEmpty()
            .Length(4)
            .Matches(@"^\d{4}$")
            .WithMessage("FiscalYearCode must be four digits, for example 0403 for April-March.");

        RuleFor(x => x.StatusCode).NotEmpty().MaximumLength(20);
        RuleFor(x => x.DisplayId).MaximumLength(20);

        RuleFor(x => x.ImoNumber)
            .Matches(@"^\d{7}$").When(x => !string.IsNullOrEmpty(x.ImoNumber))
            .WithMessage("ImoNumber must be exactly seven digits.");
    }
}
