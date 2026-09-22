namespace Ae.Maritime.Api.Dtos;

public sealed record GetUsersRequest
{
    public bool IncludeInactive { get; init; }
    public string? Search { get; init; }
    public int PageNumber { get; init; } = 1;
    public int PageSize { get; init; } = 25;
}

public sealed record GetShipsByUserRequest
{
    public bool ActiveOnly { get; init; } = true;
}
