using Ae.Maritime.Application.Abstractions;
using Ae.Maritime.Application.Common;
using Ae.Maritime.Application.Fleet;
using Ae.Maritime.Domain.Common;
using Ae.Maritime.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Ae.Maritime.Infrastructure.Repositories;

internal sealed class ShipRepository : RepositoryBase, IShipRepository
{
    public ShipRepository(MaritimeDbContext db) : base(db) { }

    public Task<PagedResult<ShipSummary>> GetShipsAsync(ShipListQuery query, CancellationToken ct) =>
        TranslatingSqlErrors(async () =>
        {
            var rows = await Db.ShipSummaryRows
                .FromSqlInterpolated($@"
                    EXEC fleet.GetShips
                         @StatusCode = {query.StatusCode},
                         @SearchTerm = {query.SearchTerm},
                         @PageNumber = {query.PageNumber},
                         @PageSize   = {query.PageSize}")
                .ToListAsync(ct);

            if (rows.Count == 0)
                return PagedResult.Empty<ShipSummary>(query.PageNumber, query.PageSize);

            var items = rows
                .Select(r => new ShipSummary(
                    r.ShipId, r.DisplayId, r.ShipName, r.FiscalYearCode,
                    r.FiscalYearDescription, r.StatusCode, r.StatusName, r.ImoNumber))
                .ToList();

            return new PagedResult<ShipSummary>(
                items, query.PageNumber, query.PageSize, rows[0].TotalCount);
        });

    public Task<ShipDetail> GetShipByIdAsync(int shipId, CancellationToken ct) =>
        TranslatingSqlErrors(async () =>
        {
            var rows = await Db.ShipDetailRows
                .FromSqlInterpolated($"EXEC fleet.GetShipById @ShipId = {shipId}")
                .ToListAsync(ct);

            var row = rows.SingleOrDefault()
                      ?? throw NotFoundException.For("Ship", shipId);

            return Map(row);
        });

    public Task<ShipDetail> CreateShipAsync(CreateShipCommand command, string createdBy, CancellationToken ct) =>
        TranslatingSqlErrors(async () =>
        {
            var rows = await Db.ShipDetailRows
                .FromSqlInterpolated($@"
                    EXEC fleet.CreateShip
                         @ShipName       = {command.ShipName},
                         @FiscalYearCode = {command.FiscalYearCode},
                         @StatusCode     = {command.StatusCode},
                         @DisplayId      = {command.DisplayId},
                         @IMONumber      = {command.ImoNumber},
                         @CreatedBy      = {createdBy}")
                .ToListAsync(ct);

            var row = rows.SingleOrDefault()
                      ?? throw new InvalidOperationException(
                             "fleet.CreateShip did not return the created ship.");

            return Map(row);
        });

    private static ShipDetail Map(Persistence.Rows.ShipDetailRow r) => new(
        r.ShipId, r.DisplayId, r.ShipName, r.FiscalYearCode, r.FiscalYearDescription,
        r.FiscalYearStartMonth, r.FiscalYearEndMonth, r.StatusCode, r.StatusName,
        r.ImoNumber, AsUtc(r.CreatedAt), AsUtc(r.ModifiedAt));
}
