namespace Ae.Maritime.Api.Dtos;

public sealed record GetShipsRequest
{
    public string? Status { get; init; }
    public string? Search { get; init; }
    public int PageNumber { get; init; } = 1;
    public int PageSize { get; init; } = 25;
}
