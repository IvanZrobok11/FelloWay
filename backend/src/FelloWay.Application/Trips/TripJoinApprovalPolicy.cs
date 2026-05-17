namespace FelloWay.Application.Trips;

public static class TripJoinApprovalPolicy
{
    public static bool ShouldAutoApprove(Guid? requesterHomeCityId, Guid tripOriginCityId) =>
        requesterHomeCityId.HasValue && requesterHomeCityId.Value == tripOriginCityId;
}
