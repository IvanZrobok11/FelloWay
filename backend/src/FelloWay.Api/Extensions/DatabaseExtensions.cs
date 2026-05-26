using FelloWay.Infrastructure.Persistence;
using FelloWay.Infrastructure.Persistence.Seed;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;

namespace FelloWay.Api.Extensions;

public static class DatabaseExtensions
{
    /// <summary>
    /// Creates database and schema when missing (<see cref="DatabaseFacade.EnsureCreatedAsync"/>).
    /// Sample data is seeded in non-production environments (including Testing).
    /// </summary>
    public static async Task ApplyDatabaseAsync(this WebApplication app)
    {
        if (app.Configuration.GetValue<bool>("Database:SkipInitialization"))
        {
            return;
        }

        _ = app.Configuration.GetConnectionString("Default")
            ?? throw new InvalidOperationException(
                "ConnectionStrings:Default is required.");

        await using var scope = app.Services.CreateAsyncScope();
        var db = scope.ServiceProvider.GetRequiredService<FelloWayDbContext>();

        await db.Database.EnsureDeletedAsync();
        await db.Database.EnsureCreatedAsync();

        // Seed for all envs
        // if (!app.Environment.IsProdLike())
        {
            var seeder = scope.ServiceProvider.GetRequiredService<IDataSeeder>();
            await seeder.SeedAsync();
        }
    }
}
