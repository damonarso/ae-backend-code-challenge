using Ae.Maritime.Api.Dtos;
using Ae.Maritime.Application.Abstractions;
using Ae.Maritime.Application.Common;
using Ae.Maritime.Application.Fleet;
using Microsoft.AspNetCore.Mvc;

namespace Ae.Maritime.Api.Controllers;

[ApiController]
[Route("api/ships")]
[Produces("application/json")]
public sealed class ShipsController : ControllerBase
{
    private readonly IShipService _shipService;

    public ShipsController(IShipService shipService) => _shipService = shipService;

    [HttpGet(Name = "GetShips")]
    [ProducesResponseType(typeof(PagedResult<ShipSummary>), StatusCodes.Status200OK)]
    public async Task<ActionResult<PagedResult<ShipSummary>>> GetShips(
        [FromQuery] GetShipsRequest request,
        CancellationToken cancellationToken)
    {
        var query = new ShipListQuery
        {
            StatusCode = request.Status,
            SearchTerm = request.Search,
            PageNumber = request.PageNumber,
            PageSize = request.PageSize
        };

        return Ok(await _shipService.GetShipsAsync(query, cancellationToken));
    }

    [HttpGet("{shipId:int}", Name = "GetShipById")]
    [ProducesResponseType(typeof(ShipDetail), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<ShipDetail>> GetShipById(
        int shipId, CancellationToken cancellationToken) =>
        Ok(await _shipService.GetShipByIdAsync(shipId, cancellationToken));

    [HttpPost(Name = "CreateShip")]
    [ProducesResponseType(typeof(ShipDetail), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status409Conflict)]
    public async Task<ActionResult<ShipDetail>> CreateShip(
        [FromBody] CreateShipCommand command, CancellationToken cancellationToken)
    {
        var ship = await _shipService.CreateShipAsync(command, cancellationToken);

        return CreatedAtRoute("GetShipById", new { shipId = ship.ShipId }, ship);
    }
}
