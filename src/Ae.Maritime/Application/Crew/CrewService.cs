using Ae.Maritime.Application.Abstractions;
using Ae.Maritime.Application.Common;
using FluentValidation;
using Microsoft.Extensions.Logging;

namespace Ae.Maritime.Application.Crew;

public sealed partial class CrewService : ICrewService
{
    private readonly ICrewRepository _repository;
    private readonly IValidator<CrewListQuery> _validator;
    private readonly ILogger<CrewService> _logger;

    public CrewService(
        ICrewRepository repository,
        IValidator<CrewListQuery> validator,
        ILogger<CrewService> logger)
    {
        _repository = repository;
        _validator = validator;
        _logger = logger;
    }

    public async Task<PagedResult<CrewListItem>> GetCrewListAsync(CrewListQuery query, CancellationToken ct)
    {
        await _validator.ValidateAndThrowDomainAsync(query, ct);

        var result = await _repository.GetCrewListAsync(query, ct);

        LogCrewListReturned(query.ShipId, result.Items.Count, result.TotalCount, query.PageNumber, query.PageSize);

        return result;
    }

    [LoggerMessage(
        Level = LogLevel.Information,
        Message = "Crew list for ship {ShipId}: returned {Returned} of {Total} (page {Page}, size {Size}).")]
    private partial void LogCrewListReturned(int shipId, int returned, int total, int page, int size);
}
