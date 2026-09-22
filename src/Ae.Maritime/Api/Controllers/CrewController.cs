using Ae.Maritime.Api.Dtos;
using Ae.Maritime.Application.Abstractions;
using Ae.Maritime.Application.Common;
using Ae.Maritime.Application.Crew;
using Microsoft.AspNetCore.Mvc;

namespace Ae.Maritime.Api.Controllers;

[ApiController]
[Route("api/ships/{shipId:int}/crew")]
[Produces("application/json")]
public sealed class CrewController : ControllerBase
{
    private readonly ICrewService _crewService;

    public CrewController(ICrewService crewService) => _crewService = crewService;

    [HttpGet(Name = "GetCrewList")]
    [ProducesResponseType(typeof(PagedResult<CrewListItem>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status422UnprocessableEntity)]
    public async Task<ActionResult<PagedResult<CrewListItem>>> GetCrewList(
        int shipId,
        [FromQuery] GetCrewListRequest request,
        CancellationToken cancellationToken)
    {
        var query = new CrewListQuery
        {
            ShipId = shipId,
            AsOfDate = request.AsOfDate,
            SearchTerm = request.Search,
            SortColumn = request.SortBy,
            SortDirection = request.SortDirection,
            PageNumber = request.PageNumber,
            PageSize = request.PageSize
        };

        return Ok(await _crewService.GetCrewListAsync(query, cancellationToken));
    }
}
