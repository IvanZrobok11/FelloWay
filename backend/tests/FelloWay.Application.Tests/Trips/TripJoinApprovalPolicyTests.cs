using FelloWay.Application.Trips;

namespace FelloWay.Application.Tests.Trips;

public class TripJoinApprovalPolicyTests
{
    [Fact]
    public void ShouldAutoApprove_WhenCitiesMatch_ReturnsTrue()
    {
        var cityId = Guid.NewGuid();
        Assert.True(TripJoinApprovalPolicy.ShouldAutoApprove(cityId, cityId));
    }

    [Fact]
    public void ShouldAutoApprove_WhenCitiesDiffer_ReturnsFalse()
    {
        Assert.False(TripJoinApprovalPolicy.ShouldAutoApprove(Guid.NewGuid(), Guid.NewGuid()));
    }

    [Fact]
    public void ShouldAutoApprove_WhenRequesterCityMissing_ReturnsFalse()
    {
        Assert.False(TripJoinApprovalPolicy.ShouldAutoApprove(null, Guid.NewGuid()));
    }
}
