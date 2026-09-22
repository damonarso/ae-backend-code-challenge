namespace Ae.Maritime.Application.Common;

public sealed record PagedResult<T>(
    IReadOnlyList<T> Items,
    int PageNumber,
    int PageSize,
    int TotalCount)
{
    public int TotalPages => TotalCount == 0 ? 0 : (int)Math.Ceiling(TotalCount / (double)PageSize);
    public bool HasPreviousPage => PageNumber > 1;
    public bool HasNextPage => PageNumber < TotalPages;
}

public static class PagedResult
{
    public static PagedResult<T> Empty<T>(int pageNumber, int pageSize) =>
        new(Array.Empty<T>(), pageNumber, pageSize, 0);
}
