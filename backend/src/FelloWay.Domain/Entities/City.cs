using FelloWay.Domain.Common;

namespace FelloWay.Domain.Entities;

public class City : EntityBase
{
    public required string Name { get; set; }

    public required string CountryCode { get; set; }

    public double Latitude { get; set; }

    public double Longitude { get; set; }
}
