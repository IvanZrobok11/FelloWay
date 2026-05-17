using FelloWay.Domain.Services;

namespace FelloWay.Application.Tests.Trips;

public class TripMembershipServiceTests
{
    [Fact]
    public void NormalizeMaxMembers_ClampsToTwenty()
    {
        Assert.Equal(20, TripMembershipService.NormalizeMaxMembers(100));
        Assert.Equal(20, TripMembershipService.NormalizeMaxMembers(null));
    }

    [Fact]
    public void CanAddMember_WhenAtCap_ReturnsFalse()
    {
        Assert.False(TripMembershipService.CanAddMember(20, 20));
        Assert.True(TripMembershipService.CanAddMember(19, 20));
    }
}
