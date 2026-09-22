using Ae.Maritime.Application.Abstractions;
using Ae.Maritime.Application.Finance;
using Ae.Maritime.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Ae.Maritime.Infrastructure.Repositories;

internal sealed class FinanceRepository : RepositoryBase, IFinanceRepository
{
    public FinanceRepository(MaritimeDbContext db) : base(db) { }

    public Task<FinancialReport> GetReportDetailAsync(FinancialReportQuery query, CancellationToken ct) =>
        TranslatingSqlErrors(async () =>
        {
            var rows = await Db.FinancialReportDetailRows
                .FromSqlInterpolated($@"
                    EXEC finance.GetReportDetail
                         @ShipId          = {query.ShipId},
                         @PeriodCode      = {query.PeriodCode},
                         @IncludeZeroRows = {query.IncludeZeroRows}")
                .ToListAsync(ct);

            var fiscalStart = rows.Count > 0 ? rows[0].FiscalYearStartCode : query.PeriodCode;

            var mapped = rows
                .Select(r => new FinancialReportRow(
                    r.AccountNumber,
                    r.AccountDescription,
                    r.ParentAccountNumber,
                    r.AccountLevel,
                    r.IsPostable,
                    r.Actual,
                    r.Budget,
                    r.Variance,
                    r.ActualYtd,
                    r.BudgetYtd,
                    r.VarianceYtd))
                .ToList();

            return new FinancialReport(query.ShipId, query.PeriodCode, fiscalStart, mapped);
        });

    public Task<FinancialReport> GetReportSummaryAsync(FinancialSummaryQuery query, CancellationToken ct) =>
        TranslatingSqlErrors(async () =>
        {
            var rows = await Db.FinancialReportSummaryRows
                .FromSqlInterpolated($@"
                    EXEC finance.GetReportSummary
                         @ShipId     = {query.ShipId},
                         @PeriodCode = {query.PeriodCode},
                         @MaxLevel   = {query.MaxLevel}")
                .ToListAsync(ct);

            var mapped = rows
                .Select(r => new FinancialReportRow(
                    r.AccountNumber,
                    r.AccountDescription,
                    ParentAccountNumber: null,
                    r.AccountLevel,
                    IsPostable: false,
                    r.Actual,
                    r.Budget,
                    r.Variance,
                    r.ActualYtd,
                    r.BudgetYtd,
                    r.VarianceYtd))
                .ToList();

            return new FinancialReport(query.ShipId, query.PeriodCode, query.PeriodCode, mapped);
        });
}
