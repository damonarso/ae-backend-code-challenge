using Ae.Maritime.Application.Common;
using Ae.Maritime.Application.Crew;

namespace Ae.Maritime.Api.Dtos;

public sealed record GetCrewListRequest
{
    public DateOnly? AsOfDate { get; init; }
    public string? Search { get; init; }
    public string SortBy { get; init; } = CrewSortColumns.RankName;
    public SortDirection SortDirection { get; init; } = SortDirection.Ascending;
    public int PageNumber { get; init; } = 1;
    public int PageSize { get; init; } = 25;
}
