using FelloWay.Api.Tests.Infrastructure;
using FelloWay.Domain.Entities;
using FelloWay.Domain.Enums;
using FelloWay.Infrastructure.Persistence;
using FelloWay.Infrastructure.Persistence.Seed;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace FelloWay.Api.Tests.Events;

internal static class EventsTestHelper
{
    public static async Task SeedAsync(FelloWayWebApplicationFactory factory)
    {
        using var scope = factory.Services.CreateScope();
        var seeder = scope.ServiceProvider.GetRequiredService<IDataSeeder>();
        await seeder.SeedAsync();
    }

    public static async Task<Guid> FirstEventIdAsync(FelloWayWebApplicationFactory factory)
    {
        using var scope = factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<FelloWayDbContext>();
        return await db.Events.OrderBy(e => e.StartsAt).Select(e => e.Id).FirstAsync();
    }

    public static async Task SeedSecondUserAttendeeAsync(
        FelloWayWebApplicationFactory factory,
        Guid eventId,
        string displayName)
    {
        using var scope = factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<FelloWayDbContext>();
        var cityId = await db.Cities.Select(c => c.Id).FirstAsync();
        var user = new User
        {
            DisplayName = displayName,
            HomeCityId = cityId,
        };
        db.Users.Add(user);
        db.EventAttendees.Add(new EventAttendee
        {
            EventId = eventId,
            UserId = user.Id,
            Status = AttendanceStatus.Joined,
            JoinedAt = DateTimeOffset.UtcNow,
        });
        await db.SaveChangesAsync();
    }
}
