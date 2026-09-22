using Ae.Maritime.Domain.Common;
using Microsoft.Data.SqlClient;

namespace Ae.Maritime.Infrastructure.Errors;

internal static class SqlErrorTranslator
{
    private const int UserDefinedErrorFloor = 50000;

    private static readonly HashSet<int> NotFound = new()
    {
        50104,
        50110,
        50305,
        50306,
        50400
    };

    private static readonly HashSet<int> Conflict = new()
    {
        50115,
        50202,
        50205,
        50303
    };

    private static readonly HashSet<int> BusinessRule = new()
    {
        50010,
        50011,
        50105,
        50410,
        50411
    };

    public static Exception? Translate(SqlException exception)
    {
        foreach (SqlError error in exception.Errors)
        {
            if (error.Number < UserDefinedErrorFloor) continue;

            if (NotFound.Contains(error.Number))
                return new NotFoundException(error.Message);

            if (Conflict.Contains(error.Number))
                return new ConflictException(error.Message);

            if (BusinessRule.Contains(error.Number))
                return new BusinessRuleException(error.Message);

            return new InputValidationException("request", error.Message);
        }

        return null;
    }
}
