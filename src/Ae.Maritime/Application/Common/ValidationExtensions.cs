using Ae.Maritime.Domain.Common;
using FluentValidation;

namespace Ae.Maritime.Application.Common;

public static class ValidationExtensions
{
    public static async Task ValidateAndThrowDomainAsync<T>(
        this IValidator<T> validator, T instance, CancellationToken ct)
    {
        var result = await validator.ValidateAsync(instance, ct);
        if (result.IsValid) return;

        var errors = result.Errors
            .GroupBy(e => e.PropertyName)
            .ToDictionary(g => g.Key, g => g.Select(e => e.ErrorMessage).ToArray());

        throw new InputValidationException(errors);
    }
}
