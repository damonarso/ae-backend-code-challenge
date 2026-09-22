namespace Ae.Maritime.Domain.Common;

public abstract class DomainException : Exception
{
    protected DomainException(string message) : base(message) { }
}

public sealed class NotFoundException : DomainException
{
    public NotFoundException(string message) : base(message) { }

    public static NotFoundException For(string entity, object id) =>
        new($"{entity} '{id}' was not found.");
}

public sealed class BusinessRuleException : DomainException
{
    public BusinessRuleException(string message) : base(message) { }
}

public sealed class ConflictException : DomainException
{
    public ConflictException(string message) : base(message) { }
}

public sealed class InputValidationException : DomainException
{
    public IReadOnlyDictionary<string, string[]> Errors { get; }

    public InputValidationException(IReadOnlyDictionary<string, string[]> errors)
        : base("One or more validation errors occurred.") => Errors = errors;

    public InputValidationException(string member, string error)
        : this(new Dictionary<string, string[]> { [member] = new[] { error } }) { }
}
