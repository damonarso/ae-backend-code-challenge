namespace Ae.Maritime.Application.Common;

public enum SortDirection
{
    Ascending = 0,
    Descending = 1
}

public static class SortDirectionExtensions
{
    public static string ToSqlToken(this SortDirection direction) =>
        direction == SortDirection.Descending ? "DESC" : "ASC";
}
