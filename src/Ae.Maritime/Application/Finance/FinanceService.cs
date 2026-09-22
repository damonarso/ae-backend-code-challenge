using Ae.Maritime.Application.Abstractions;
using Ae.Maritime.Application.Common;
using FluentValidation;
using Microsoft.Extensions.Logging;

namespace Ae.Maritime.Application.Finance;

public sealed partial class FinanceService : IFinanceService
{
    private readonly IFinanceRepository _repository;
    private readonly IValidator<FinancialReportQuery> _detailValidator;
    private readonly IValidator<FinancialSummaryQuery> _summaryValidator;
    private readonly ILogger<FinanceService> _logger;

    public FinanceService(
        IFinanceRepository repository,
        IValidator<FinancialReportQuery> detailValidator,
        IValidator<FinancialSummaryQuery> summaryValidator,
        ILogger<FinanceService> logger)
    {
        _repository = repository;
        _detailValidator = detailValidator;
        _summaryValidator = summaryValidator;
        _logger = logger;
    }

    public async Task<FinancialReport> GetReportDetailAsync(FinancialReportQuery query, CancellationToken ct)
    {
        await _detailValidator.ValidateAndThrowDomainAsync(query, ct);

        var report = await _repository.GetReportDetailAsync(query, ct);

        LogDetailReportReturned(query.ShipId, query.PeriodCode, report.FiscalYearStartCode, report.Rows.Count);

        return report;
    }

    public async Task<FinancialReport> GetReportSummaryAsync(FinancialSummaryQuery query, CancellationToken ct)
    {
        await _summaryValidator.ValidateAndThrowDomainAsync(query, ct);
        return await _repository.GetReportSummaryAsync(query, ct);
    }

    [LoggerMessage(
        Level = LogLevel.Information,
        Message = "Detail report: ship {ShipId}, period {Period}, YTD from {FiscalStart}, {RowCount} rows.")]
    private partial void LogDetailReportReturned(int shipId, string period, string fiscalStart, int rowCount);
}
