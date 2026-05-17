namespace FelloWay.Domain.Services;

public static class TripMembershipService
{
    public const int AbsoluteMaxMembers = 20;

    public const int DefaultMaxMembers = 20;

    public static int NormalizeMaxMembers(int? requested) =>
        Math.Clamp(requested ?? DefaultMaxMembers, 1, AbsoluteMaxMembers);

    public static bool CanAddMember(int activeMemberCount, int maxMembers) =>
        activeMemberCount < maxMembers;
}
