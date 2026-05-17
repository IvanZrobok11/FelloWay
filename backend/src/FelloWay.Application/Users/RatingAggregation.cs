namespace FelloWay.Application.Users;

public static class RatingAggregation
{
    public static decimal ComputeAverage(IReadOnlyList<int> ratings)
    {
        if (ratings.Count == 0)
        {
            return 0m;
        }

        return Math.Round((decimal)ratings.Average(), 2, MidpointRounding.AwayFromZero);
    }

    public static decimal ApplyNewRating(IReadOnlyList<int> existingRatings, int newRating)
    {
        var all = existingRatings.Append(newRating).ToList();
        return ComputeAverage(all);
    }
}
