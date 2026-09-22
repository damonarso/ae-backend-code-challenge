using Ae.Maritime.Infrastructure.Errors;
using Ae.Maritime.Infrastructure.Persistence;
using Microsoft.Data.SqlClient;

namespace Ae.Maritime.Infrastructure.Repositories;

public abstract class RepositoryBase
{
    protected MaritimeDbContext Db { get; }

    protected RepositoryBase(MaritimeDbContext db) => Db = db;

    protected static async Task<T> TranslatingSqlErrors<T>(Func<Task<T>> work)
    {
        try
        {
            return await work();
        }
        catch (SqlException ex)
        {
            throw SqlErrorTranslator.Translate(ex) ?? (Exception)ex;
        }
    }

    protected static async Task TranslatingSqlErrors(Func<Task> work)
    {
        try
        {
            await work();
        }
        catch (SqlException ex)
        {
            throw SqlErrorTranslator.Translate(ex) ?? (Exception)ex;
        }
    }

    protected static DateTimeOffset AsUtc(DateTime value) =>
        new(DateTime.SpecifyKind(value, DateTimeKind.Utc));

    protected static DateTimeOffset? AsUtc(DateTime? value) =>
        value.HasValue ? AsUtc(value.Value) : null;
}
