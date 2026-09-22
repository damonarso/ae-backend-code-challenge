using Ae.Maritime.Domain.Crew;

namespace Ae.Maritime.Application.Crew;

public sealed record CrewListItem(
    string CrewMemberDisplayId,
    string RankName,
    string FirstName,
    string LastName,
    int Age,
    string Nationality,
    DateOnly SignOnDate,
    CrewStatus Status);
