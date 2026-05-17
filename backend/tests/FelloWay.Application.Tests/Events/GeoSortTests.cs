using FelloWay.Application.Events;

namespace FelloWay.Application.Tests.Events;

public class GeoSortTests
{
    [Fact]
    public void DistanceKm_KyivToLviv_IsRoughly470Km()
    {
        var km = GeoSort.DistanceKm(50.4501, 30.5234, 49.8397, 24.0297);
        Assert.InRange(km, 450, 500);
    }

    [Fact]
    public void OrderByDistance_SortsNearestFirst()
    {
        var items = new[]
        {
            new GeoPoint("far", 40.0, 10.0),
            new GeoPoint("near", 50.45, 30.52),
            new GeoPoint("mid", 49.84, 24.03),
        };

        var sorted = GeoSort.OrderByDistance(
            items,
            50.4501,
            30.5234,
            p => p.Lat,
            p => p.Lon);

        Assert.Equal("near", sorted[0].Name);
    }

    private sealed record GeoPoint(string Name, double Lat, double Lon);
}
