using Ae.Maritime.Application.Common;
using Ae.Maritime.Application.Crew;
using Ae.Maritime.Application.Finance;
using Ae.Maritime.Application.Fleet;
using Ae.Maritime.Application.Identity;

namespace Ae.Maritime.Application.Abstractions;

public interface ICrewService
{
    Task<PagedResult<CrewListItem>> GetCrewListAsync(CrewListQuery query, CancellationToken ct);
}

public interface IShipService
{
    Task<PagedResult<ShipSummary>> GetShipsAsync(ShipListQuery query, CancellationToken ct);
    Task<ShipDetail> GetShipByIdAsync(int shipId, CancellationToken ct);
    Task<ShipDetail> CreateShipAsync(CreateShipCommand command, CancellationToken ct);
}

public interface IUserService
{
    Task<PagedResult<UserSummary>> GetUsersAsync(UserListQuery query, CancellationToken ct);
    Task<UserDetail> GetUserByIdAsync(int userId, CancellationToken ct);
    Task<UserDetail> CreateUserAsync(CreateUserCommand command, CancellationToken ct);
    Task<IReadOnlyList<AssignedShip>> GetShipsByUserAsync(int userId, bool activeOnly, CancellationToken ct);
    Task<IReadOnlyList<AssignedShip>> AssignShipAsync(int userId, int shipId, CancellationToken ct);
}

public interface IFinanceService
{
    Task<FinancialReport> GetReportDetailAsync(FinancialReportQuery query, CancellationToken ct);
    Task<FinancialReport> GetReportSummaryAsync(FinancialSummaryQuery query, CancellationToken ct);
}
