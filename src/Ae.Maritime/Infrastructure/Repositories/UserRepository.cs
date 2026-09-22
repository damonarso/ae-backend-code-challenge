using Ae.Maritime.Application.Abstractions;
using Ae.Maritime.Application.Common;
using Ae.Maritime.Application.Identity;
using Ae.Maritime.Domain.Common;
using Ae.Maritime.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Ae.Maritime.Infrastructure.Repositories;

internal sealed class UserRepository : RepositoryBase, IUserRepository
{
    public UserRepository(MaritimeDbContext db) : base(db) { }

    public Task<PagedResult<UserSummary>> GetUsersAsync(UserListQuery query, CancellationToken ct) =>
        TranslatingSqlErrors(async () =>
        {
            var rows = await Db.UserSummaryRows
                .FromSqlInterpolated($@"
                    EXEC app.GetUsers
                         @IncludeInactive = {query.IncludeInactive},
                         @SearchTerm      = {query.SearchTerm},
                         @PageNumber      = {query.PageNumber},
                         @PageSize        = {query.PageSize}")
                .ToListAsync(ct);

            if (rows.Count == 0)
                return PagedResult.Empty<UserSummary>(query.PageNumber, query.PageSize);

            var items = rows
                .Select(r => new UserSummary(
                    r.UserId, r.FullName, r.Email, r.RoleCode, r.RoleName,
                    r.IsActive, r.AssignedShipCount))
                .ToList();

            return new PagedResult<UserSummary>(
                items, query.PageNumber, query.PageSize, rows[0].TotalCount);
        });

    public Task<UserDetail> GetUserByIdAsync(int userId, CancellationToken ct) =>
        TranslatingSqlErrors(async () =>
        {
            var rows = await Db.UserDetailRows
                .FromSqlInterpolated($"EXEC app.GetUserById @UserId = {userId}")
                .ToListAsync(ct);

            var row = rows.SingleOrDefault() ?? throw NotFoundException.For("User", userId);
            return Map(row);
        });

    public Task<UserDetail> CreateUserAsync(CreateUserCommand command, string createdBy, CancellationToken ct) =>
        TranslatingSqlErrors(async () =>
        {
            var rows = await Db.UserDetailRows
                .FromSqlInterpolated($@"
                    EXEC app.CreateUser
                         @FullName  = {command.FullName},
                         @Email     = {command.Email},
                         @RoleCode  = {command.RoleCode},
                         @CreatedBy = {createdBy}")
                .ToListAsync(ct);

            var row = rows.SingleOrDefault()
                      ?? throw new InvalidOperationException(
                             "app.CreateUser did not return the created user.");

            return Map(row);
        });

    public Task<IReadOnlyList<AssignedShip>> GetShipsByUserAsync(int userId, bool activeOnly, CancellationToken ct) =>
        TranslatingSqlErrors(async () =>
        {
            var rows = await Db.AssignedShipRows
                .FromSqlInterpolated($@"
                    EXEC app.GetShipsByUser
                         @UserId          = {userId},
                         @ActiveShipsOnly = {activeOnly}")
                .ToListAsync(ct);

            return (IReadOnlyList<AssignedShip>)rows.Select(MapAssignment).ToList();
        });

    public Task<IReadOnlyList<AssignedShip>> AssignShipAsync(
        int userId, int shipId, string assignedBy, CancellationToken ct) =>
        TranslatingSqlErrors(async () =>
        {
            var rows = await Db.AssignedShipRows
                .FromSqlInterpolated($@"
                    EXEC app.AssignShip
                         @UserId     = {userId},
                         @ShipId     = {shipId},
                         @AssignedBy = {assignedBy}")
                .ToListAsync(ct);

            return (IReadOnlyList<AssignedShip>)rows.Select(MapAssignment).ToList();
        });

    private static UserDetail Map(Persistence.Rows.UserDetailRow r) => new(
        r.UserId, r.FullName, r.Email, r.RoleCode, r.RoleName, r.IsActive,
        AsUtc(r.CreatedAt), AsUtc(r.ModifiedAt));

    private static AssignedShip MapAssignment(Persistence.Rows.AssignedShipRow r) => new(
        r.ShipId, r.DisplayId, r.ShipName, r.FiscalYearCode,
        r.StatusCode, r.StatusName, AsUtc(r.AssignedAt));
}
