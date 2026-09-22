using Ae.Maritime.Api.Dtos;
using Ae.Maritime.Application.Abstractions;
using Ae.Maritime.Application.Finance;
using Microsoft.AspNetCore.Mvc;

namespace Ae.Maritime.Api.Controllers;

[ApiController]
[Route("api/ships/{shipId:int}/financial-report")]
[Produces("application/json")]
public sealed class FinanceController : ControllerBase
{
    private readonly IFinanceService _financeService;

    public FinanceController(IFinanceService financeService) => _financeService = financeService;

    [HttpGet("detail", Name = "GetFinancialReportDetail")]
    [ProducesResponseType(typeof(FinancialReport), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status422UnprocessableEntity)]
    public async Task<ActionResult<FinancialReport>> GetDetail(
        int shipId,
        [FromQuery] GetFinancialReportDetailRequest request,
        CancellationToken cancellationToken)
    {
        var query = new FinancialReportQuery
        {
            ShipId = shipId,
            PeriodCode = request.Period,
            IncludeZeroRows = request.IncludeZeroRows
        };

        return Ok(await _financeService.GetReportDetailAsync(query, cancellationToken));
    }

    [HttpGet("summary", Name = "GetFinancialReportSummary")]
    [ProducesResponseType(typeof(FinancialReport), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<FinancialReport>> GetSummary(
        int shipId,
        [FromQuery] GetFinancialReportSummaryRequest request,
        CancellationToken cancellationToken)
    {
        var query = new FinancialSummaryQuery
        {
            ShipId = shipId,
            PeriodCode = request.Period,
            MaxLevel = request.MaxLevel
        };

        return Ok(await _financeService.GetReportSummaryAsync(query, cancellationToken));
    }
}
