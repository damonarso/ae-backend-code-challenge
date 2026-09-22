using Ae.Maritime.Application.Abstractions;
using Ae.Maritime.Application.Common;
using FluentValidation;

namespace Ae.Maritime.Application.Fleet;

public sealed class ShipService : IShipService
{
    private readonly IShipRepository _repository;
    private readonly IValidator<ShipListQuery> _listValidator;
    private readonly IValidator<CreateShipCommand> _createValidator;
    private readonly ICurrentUser _currentUser;

    public ShipService(
        IShipRepository repository,
        IValidator<ShipListQuery> listValidator,
        IValidator<CreateShipCommand> createValidator,
        ICurrentUser currentUser)
    {
        _repository = repository;
        _listValidator = listValidator;
        _createValidator = createValidator;
        _currentUser = currentUser;
    }

    public async Task<PagedResult<ShipSummary>> GetShipsAsync(ShipListQuery query, CancellationToken ct)
    {
        await _listValidator.ValidateAndThrowDomainAsync(query, ct);
        return await _repository.GetShipsAsync(query, ct);
    }

    public Task<ShipDetail> GetShipByIdAsync(int shipId, CancellationToken ct) =>
        _repository.GetShipByIdAsync(shipId, ct);

    public async Task<ShipDetail> CreateShipAsync(CreateShipCommand command, CancellationToken ct)
    {
        await _createValidator.ValidateAndThrowDomainAsync(command, ct);
        return await _repository.CreateShipAsync(command, _currentUser.Name, ct);
    }
}
