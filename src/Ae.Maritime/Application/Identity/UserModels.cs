using Ae.Maritime.Application.Common;
using FluentValidation;

namespace Ae.Maritime.Application.Identity;

public sealed record UserSummary(
    int UserId,
    string FullName,
    string Email,
    string RoleCode,
    string RoleName,
    bool IsActive,
    int AssignedShipCount);

public sealed record UserDetail(
    int UserId,
    string FullName,
    string Email,
    string RoleCode,
    string RoleName,
    bool IsActive,
    DateTimeOffset CreatedAt,
    DateTimeOffset? ModifiedAt);

public sealed record UserListQuery : PagedQuery
{
    public bool IncludeInactive { get; init; }
    public string? SearchTerm { get; init; }
}

public sealed class UserListQueryValidator : AbstractValidator<UserListQuery>
{
    public UserListQueryValidator()
    {
        Include(new PagedQueryValidator());
        RuleFor(x => x.SearchTerm).MaximumLength(100);
    }
}

public sealed record CreateUserCommand
{
    public required string FullName { get; init; }
    public required string Email { get; init; }
    public required string RoleCode { get; init; }
}

public sealed class CreateUserCommandValidator : AbstractValidator<CreateUserCommand>
{
    public CreateUserCommandValidator()
    {
        RuleFor(x => x.FullName).NotEmpty().MaximumLength(150);
        RuleFor(x => x.Email).NotEmpty().EmailAddress().MaximumLength(256);
        RuleFor(x => x.RoleCode).NotEmpty().MaximumLength(30);
    }
}

public sealed record AssignedShip(
    int ShipId,
    string DisplayId,
    string ShipName,
    string FiscalYearCode,
    string StatusCode,
    string StatusName,
    DateTimeOffset AssignedAt);
