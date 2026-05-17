using FelloWay.Domain.Entities;
using FelloWay.Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace FelloWay.Infrastructure.Persistence.Seed;

public class DataSeeder(FelloWayDbContext db) : IDataSeeder
{
    public async Task SeedAsync(CancellationToken cancellationToken = default)
    {
        if (await db.Events.AnyAsync(cancellationToken))
        {
            return;
        }

        if (!await db.Cities.AnyAsync(cancellationToken))
        {
            await SeedReferenceDataAsync(cancellationToken);
        }

        await SeedEventsAsync(cancellationToken);
    }

    private async Task SeedReferenceDataAsync(CancellationToken cancellationToken)
    {

        var kyiv = new City
        {
            Name = "Kyiv",
            CountryCode = "UA",
            Latitude = 50.4501,
            Longitude = 30.5234,
        };
        var lviv = new City
        {
            Name = "Lviv",
            CountryCode = "UA",
            Latitude = 49.8397,
            Longitude = 24.0297,
        };

        db.Cities.AddRange(kyiv, lviv);

        var interests = new[]
        {
            new Interest { Name = ".NET" },
            new Interest { Name = "Flutter" },
            new Interest { Name = "DevOps" },
            new Interest { Name = "Product" },
        };
        db.Interests.AddRange(interests);

        await db.SaveChangesAsync(cancellationToken);
    }

    private async Task SeedEventsAsync(CancellationToken cancellationToken)
    {
        var kyiv = await db.Cities.FirstAsync(c => c.Name == "Kyiv", cancellationToken);
        var lviv = await db.Cities.FirstAsync(c => c.Name == "Lviv", cancellationToken);
        var dotnet = await db.Interests.FirstAsync(i => i.Name == ".NET", cancellationToken);
        var flutter = await db.Interests.FirstAsync(i => i.Name == "Flutter", cancellationToken);
        var product = await db.Interests.FirstAsync(i => i.Name == "Product", cancellationToken);

        var now = DateTimeOffset.UtcNow;
        var event1 = new Event
        {
            Title = "Flutter & Friends Kyiv",
            Description = "Mobile and cross-platform community meetup.",
            StartsAt = now.AddDays(14),
            EndsAt = now.AddDays(15),
            CityId = kyiv.Id,
            Venue = "ICC",
            Status = EventStatus.Active,
            Latitude = kyiv.Latitude,
            Longitude = kyiv.Longitude,
            Capacity = 500,
            OfficialUrl = "https://example.com/flutter-kyiv",
        };
        var event2 = new Event
        {
            Title = "Product IT Summit",
            Description = "Product and engineering leadership conference.",
            StartsAt = now.AddDays(30),
            EndsAt = now.AddDays(31),
            CityId = lviv.Id,
            Venue = "Arena Lviv",
            Status = EventStatus.Active,
            Latitude = lviv.Latitude,
            Longitude = lviv.Longitude,
            Capacity = 300,
        };

        db.Events.AddRange(event1, event2);
        db.EventInterests.AddRange(
            new EventInterest { Event = event1, InterestId = flutter.Id },
            new EventInterest { Event = event1, InterestId = dotnet.Id },
            new EventInterest { Event = event2, InterestId = product.Id });

        var pending = new Event
        {
            Title = "Pending Dev Conference",
            Description = "Awaiting admin approval.",
            StartsAt = now.AddDays(45),
            EndsAt = now.AddDays(46),
            CityId = kyiv.Id,
            Status = EventStatus.Pending,
        };
        db.Events.Add(pending);

        await db.SaveChangesAsync(cancellationToken);
    }
}
