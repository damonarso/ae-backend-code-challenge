using Ae.Maritime.Application.Common;
using Ae.Maritime.Application.Crew;
using Ae.Maritime.Application.Finance;
using Ae.Maritime.Application.Fleet;
using Ae.Maritime.Application.Identity;

namespace Ae.Maritime.Application.Abstractions;

public interface ICrewRepository
{
    Task<PagedResult<CrewListItem>> GetCrewListAsync(CrewListQuery query, CancellationToken ct);
}

public interface IShipRepository
{
    Task<PagedResult<ShipSummary>> GetShipsAsync(ShipListQuery query, CancellationToken ct);
    Task<ShipDetail> GetShipByIdAsync(int shipId, CancellationToken ct);
    Task<ShipDetail> CreateShipAsync(CreateShipCommand command, string createdBy, CancellationToken ct);
}

public interface IUserRepository
{
    Task<PagedResult<UserSummary>> GetUsersAsync(UserListQuery query, CancellationToken ct);
    Task<UserDetail> GetUserByIdAsync(int userId, CancellationToken ct);
    Task<UserDetail> CreateUserAsync(CreateUserCommand command, string createdBy, CancellationToken ct);
    Task<IReadOnlyList<AssignedShip>> GetShipsByUserAsync(int userId, bool activeOnly, CancellationToken ct);
    Task<IReadOnlyList<AssignedShip>> AssignShipAsync(int userId, int shipId, string assignedBy, CancellationToken ct);
}

public interface IFinanceRepository
{
    Task<FinancialReport> GetReportDetailAsync(FinancialReportQuery query, CancellationToken ct);
    Task<FinancialReport> GetReportSummaryAsync(FinancialSummaryQuery query, CancellationToken ct);
}

public interface ICurrentUser
{
    string Name { get; }
}
