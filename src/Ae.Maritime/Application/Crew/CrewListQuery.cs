using Ae.Maritime.Application.Common;
using FluentValidation;

namespace Ae.Maritime.Application.Crew;

public sealed record CrewListQuery : PagedQuery
{
    public required int ShipId { get; init; }
    public DateOnly? AsOfDate { get; init; }
    public string? SearchTerm { get; init; }
    public string SortColumn { get; init; } = CrewSortColumns.RankName;
    public SortDirection SortDirection { get; init; } = SortDirection.Ascending;
}

public static class CrewSortColumns
{
    public const string RankName = "RankName";
    public const string DisplayId = "DisplayId";
    public const string FirstName = "FirstName";
    public const string LastName = "LastName";
    public const string Age = "Age";
    public const string Nationality = "Nationality";
    public const string SignOnDate = "SignOnDate";
    public const string Status = "Status";

    public static readonly IReadOnlySet<string> All = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
    {
        RankName, DisplayId, FirstName, LastName, Age, Nationality, SignOnDate, Status
    };
}

public sealed class CrewListQueryValidator : AbstractValidator<CrewListQuery>
{
    public CrewListQueryValidator()
    {
        Include(new PagedQueryValidator());

        RuleFor(x => x.ShipId)
            .GreaterThan(0).WithMessage("ShipId must be a positive integer.");

        RuleFor(x => x.SortColumn)
            .Must(CrewSortColumns.All.Contains!)
            .WithMessage($"SortColumn must be one of: {string.Join(", ", CrewSortColumns.All)}.");

        RuleFor(x => x.SearchTerm)
            .MaximumLength(100)
            .WithMessage("SearchTerm must be 100 characters or fewer.");
    }
}
