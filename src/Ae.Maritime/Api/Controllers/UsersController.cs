using Ae.Maritime.Api.Dtos;
using Ae.Maritime.Application.Abstractions;
using Ae.Maritime.Application.Common;
using Ae.Maritime.Application.Identity;
using Microsoft.AspNetCore.Mvc;

namespace Ae.Maritime.Api.Controllers;

[ApiController]
[Route("api/users")]
[Produces("application/json")]
public sealed class UsersController : ControllerBase
{
    private readonly IUserService _userService;

    public UsersController(IUserService userService) => _userService = userService;

    [HttpGet(Name = "GetUsers")]
    [ProducesResponseType(typeof(PagedResult<UserSummary>), StatusCodes.Status200OK)]
    public async Task<ActionResult<PagedResult<UserSummary>>> GetUsers(
        [FromQuery] GetUsersRequest request,
        CancellationToken cancellationToken)
    {
        var query = new UserListQuery
        {
            IncludeInactive = request.IncludeInactive,
            SearchTerm = request.Search,
            PageNumber = request.PageNumber,
            PageSize = request.PageSize
        };

        return Ok(await _userService.GetUsersAsync(query, cancellationToken));
    }

    [HttpGet("{userId:int}", Name = "GetUserById")]
    [ProducesResponseType(typeof(UserDetail), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<UserDetail>> GetUserById(
        int userId, CancellationToken cancellationToken) =>
        Ok(await _userService.GetUserByIdAsync(userId, cancellationToken));

    [HttpPost(Name = "CreateUser")]
    [ProducesResponseType(typeof(UserDetail), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status409Conflict)]
    public async Task<ActionResult<UserDetail>> CreateUser(
        [FromBody] CreateUserCommand command, CancellationToken cancellationToken)
    {
        var user = await _userService.CreateUserAsync(command, cancellationToken);
        return CreatedAtRoute("GetUserById", new { userId = user.UserId }, user);
    }

    [HttpGet("{userId:int}/ships", Name = "GetShipsByUser")]
    [ProducesResponseType(typeof(IReadOnlyList<AssignedShip>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<IReadOnlyList<AssignedShip>>> GetShipsByUser(
        int userId,
        [FromQuery] GetShipsByUserRequest request,
        CancellationToken cancellationToken) =>
        Ok(await _userService.GetShipsByUserAsync(userId, request.ActiveOnly, cancellationToken));

    [HttpPut("{userId:int}/ships/{shipId:int}", Name = "AssignShip")]
    [ProducesResponseType(typeof(IReadOnlyList<AssignedShip>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status404NotFound)]
    public async Task<ActionResult<IReadOnlyList<AssignedShip>>> AssignShip(
        int userId, int shipId, CancellationToken cancellationToken) =>
        Ok(await _userService.AssignShipAsync(userId, shipId, cancellationToken));
}
