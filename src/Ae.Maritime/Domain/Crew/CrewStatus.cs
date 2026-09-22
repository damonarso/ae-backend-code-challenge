namespace Ae.Maritime.Domain.Crew;

public enum CrewStatus
{
    Onboard = 1,

    ReliefDue = 2,

    Planned = 3,

    SignedOff = 4
}

public static class CrewStatusExtensions
{
    public static CrewStatus ParseFromDatabase(string value) => value switch
    {
        "Onboard" => CrewStatus.Onboard,
        "Relief Due" => CrewStatus.ReliefDue,
        "Planned" => CrewStatus.Planned,
        "Signed Off" => CrewStatus.SignedOff,
        _ => throw new ArgumentOutOfRangeException(
                 nameof(value), value, "Unrecognised crew status from the database.")
    };
}
