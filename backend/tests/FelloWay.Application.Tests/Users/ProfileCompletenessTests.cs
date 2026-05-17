using FelloWay.Domain.Entities;

namespace FelloWay.Application.Tests.Users;

public class ProfileCompletenessTests
{
    [Fact]
    public void IsProfileComplete_WhenNameAndCitySet_ReturnsTrue()
    {
        var user = new User
        {
            DisplayName = "Alex",
            HomeCityId = Guid.NewGuid(),
        };
        Assert.True(user.IsProfileComplete);
    }

    [Fact]
    public void IsProfileComplete_WhenMissingCity_ReturnsFalse()
    {
        var user = new User { DisplayName = "Alex" };
        Assert.False(user.IsProfileComplete);
    }
}
