namespace FelloWay.Application.Events;

public static class GeoSort
{
    private const double EarthRadiusKm = 6371.0;

    public static double DistanceKm(double lat1, double lon1, double lat2, double lon2)
    {
        var dLat = DegreesToRadians(lat2 - lat1);
        var dLon = DegreesToRadians(lon2 - lon1);
        var a =
            Math.Sin(dLat / 2) * Math.Sin(dLat / 2) +
            Math.Cos(DegreesToRadians(lat1)) * Math.Cos(DegreesToRadians(lat2)) *
            Math.Sin(dLon / 2) * Math.Sin(dLon / 2);
        var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
        return EarthRadiusKm * c;
    }

    public static IReadOnlyList<T> OrderByDistance<T>(
        IEnumerable<T> items,
        double originLat,
        double originLon,
        Func<T, double> latitude,
        Func<T, double> longitude)
    {
        return items
            .OrderBy(i => DistanceKm(originLat, originLon, latitude(i), longitude(i)))
            .ToList();
    }

    private static double DegreesToRadians(double degrees) => degrees * (Math.PI / 180.0);
}
