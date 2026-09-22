using Ae.Maritime.Application.Abstractions;
using Ae.Maritime.Application.Common;
using Ae.Maritime.Application.Crew;
using Ae.Maritime.Domain.Crew;
using Ae.Maritime.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Ae.Maritime.Infrastructure.Repositories;

internal sealed class CrewRepository : RepositoryBase, ICrewRepository
{
    public CrewRepository(MaritimeDbContext db) : base(db) { }

    public Task<PagedResult<CrewListItem>> GetCrewListAsync(CrewListQuery query, CancellationToken ct) =>
        TranslatingSqlErrors(async () =>
        {
            var rows = await Db.CrewListRows
                .FromSqlInterpolated($@"
                    EXEC crew.GetCrewList
                         @ShipId        = {query.ShipId},
                         @AsOfDate      = {query.AsOfDate},
                         @SearchTerm    = {query.SearchTerm},
                         @SortColumn    = {query.SortColumn},
                         @SortDirection = {query.SortDirection.ToSqlToken()},
                         @PageNumber    = {query.PageNumber},
                         @PageSize      = {query.PageSize}")
                .ToListAsync(ct);

            if (rows.Count == 0)
                return PagedResult.Empty<CrewListItem>(query.PageNumber, query.PageSize);

            var items = rows
                .Select(r => new CrewListItem(
                    r.CrewMemberDisplayId,
                    r.RankName,
                    r.FirstName,
                    r.LastName,
                    r.Age,
                    r.Nationality,
                    r.SignOnDate,
                    CrewStatusExtensions.ParseFromDatabase(r.Status)))
                .ToList();

            return new PagedResult<CrewListItem>(
                items, query.PageNumber, query.PageSize, rows[0].TotalCount);
        });
}
