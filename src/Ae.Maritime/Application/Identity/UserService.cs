using Ae.Maritime.Application.Abstractions;
using Ae.Maritime.Application.Common;
using FluentValidation;

namespace Ae.Maritime.Application.Identity;

public sealed class UserService : IUserService
{
    private readonly IUserRepository _repository;
    private readonly IValidator<UserListQuery> _listValidator;
    private readonly IValidator<CreateUserCommand> _createValidator;
    private readonly ICurrentUser _currentUser;

    public UserService(
        IUserRepository repository,
        IValidator<UserListQuery> listValidator,
        IValidator<CreateUserCommand> createValidator,
        ICurrentUser currentUser)
    {
        _repository = repository;
        _listValidator = listValidator;
        _createValidator = createValidator;
        _currentUser = currentUser;
    }

    public async Task<PagedResult<UserSummary>> GetUsersAsync(UserListQuery query, CancellationToken ct)
    {
        await _listValidator.ValidateAndThrowDomainAsync(query, ct);
        return await _repository.GetUsersAsync(query, ct);
    }

    public Task<UserDetail> GetUserByIdAsync(int userId, CancellationToken ct) =>
        _repository.GetUserByIdAsync(userId, ct);

    public async Task<UserDetail> CreateUserAsync(CreateUserCommand command, CancellationToken ct)
    {
        await _createValidator.ValidateAndThrowDomainAsync(command, ct);
        return await _repository.CreateUserAsync(command, _currentUser.Name, ct);
    }

    public Task<IReadOnlyList<AssignedShip>> GetShipsByUserAsync(int userId, bool activeOnly, CancellationToken ct) =>
        _repository.GetShipsByUserAsync(userId, activeOnly, ct);

    public Task<IReadOnlyList<AssignedShip>> AssignShipAsync(int userId, int shipId, CancellationToken ct) =>
        _repository.AssignShipAsync(userId, shipId, _currentUser.Name, ct);
}
