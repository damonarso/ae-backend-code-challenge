using Ae.Maritime.Application.Abstractions;
using Ae.Maritime.Application.Common;
using Ae.Maritime.Application.Crew;
using Ae.Maritime.Domain.Common;
using Ae.Maritime.Domain.Crew;
using FluentAssertions;
using Microsoft.Extensions.Logging.Abstractions;
using NSubstitute;
using Xunit;

namespace Ae.Maritime.Tests;

public sealed class CrewServiceTests
{
    private readonly ICrewRepository _repository = Substitute.For<ICrewRepository>();

    private CrewService CreateSut() =>
        new(_repository, new CrewListQueryValidator(), NullLogger<CrewService>.Instance);

    private static CrewListQuery ValidQuery() => new() { ShipId = 1 };

    [Fact]
    public async Task GetCrewList_passes_a_valid_query_to_the_repository()
    {
        var expected = new PagedResult<CrewListItem>(
            new[]
            {
                new CrewListItem("CREW001", "Master", "Ramon", "Delgado", 54,
                    "Filipino", new DateOnly(2025, 4, 5), CrewStatus.Onboard)
            },
            PageNumber: 1, PageSize: 25, TotalCount: 1);

        _repository.GetCrewListAsync(Arg.Any<CrewListQuery>(), Arg.Any<CancellationToken>())
                   .Returns(expected);

        var result = await CreateSut().GetCrewListAsync(ValidQuery(), CancellationToken.None);

        result.Should().BeSameAs(expected);
        await _repository.Received(1)
            .GetCrewListAsync(Arg.Is<CrewListQuery>(q => q.ShipId == 1), Arg.Any<CancellationToken>());
    }

    [Theory]
    [InlineData(0)]
    [InlineData(-1)]
    public async Task GetCrewList_rejects_a_non_positive_ship_id(int shipId)
    {
        var act = () => CreateSut().GetCrewListAsync(
            ValidQuery() with { ShipId = shipId }, CancellationToken.None);

        await act.Should().ThrowAsync<InputValidationException>();
        await _repository.DidNotReceiveWithAnyArgs().GetCrewListAsync(default!, default);
    }

    [Fact]
    public async Task GetCrewList_rejects_a_sort_column_outside_the_whitelist()
    {
        var query = ValidQuery() with { SortColumn = "1; DROP TABLE crew.CrewMember--" };

        var act = () => CreateSut().GetCrewListAsync(query, CancellationToken.None);

        var thrown = await act.Should().ThrowAsync<InputValidationException>();
        thrown.Which.Errors.Should().ContainKey(nameof(CrewListQuery.SortColumn));
        await _repository.DidNotReceiveWithAnyArgs().GetCrewListAsync(default!, default);
    }

    [Theory]
    [InlineData(0, 25)]
    [InlineData(1, 0)]
    [InlineData(1, 201)]
    public async Task GetCrewList_rejects_out_of_range_paging(int pageNumber, int pageSize)
    {
        var query = ValidQuery() with { PageNumber = pageNumber, PageSize = pageSize };

        var act = () => CreateSut().GetCrewListAsync(query, CancellationToken.None);

        await act.Should().ThrowAsync<InputValidationException>();
    }
}
