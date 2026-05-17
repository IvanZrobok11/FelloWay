using FelloWay.Application.Users;

namespace FelloWay.Application.Tests.Users;

public class RatingAggregationTests
{
    [Fact]
    public void ComputeAverage_WithRatings_ReturnsRoundedMean()
    {
        Assert.Equal(4.00m, RatingAggregation.ComputeAverage([5, 4, 3]));
    }

    [Fact]
    public void ApplyNewRating_IncludesNewScore()
    {
        Assert.Equal(4.67m, RatingAggregation.ApplyNewRating([4, 5], 5));
    }

    [Fact]
    public void ComputeAverage_WhenEmpty_ReturnsZero()
    {
        Assert.Equal(0m, RatingAggregation.ComputeAverage([]));
    }
}
