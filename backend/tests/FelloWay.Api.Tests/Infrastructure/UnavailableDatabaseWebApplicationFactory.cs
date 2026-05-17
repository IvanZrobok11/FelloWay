using FelloWay.Infrastructure.Persistence;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;

namespace FelloWay.Api.Tests.Infrastructure;

/// <summary>
/// Fast-suite host with unreachable PostgreSQL for readiness tests.
/// </summary>
public class UnavailableDatabaseWebApplicationFactory : WebApplicationFactory<Program>
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Testing");
        builder.UseSetting("Database:SkipInitialization", "true");
        builder.UseSetting("Database:DisableHangfire", "true");

        builder.ConfigureServices(services =>
        {
            services.RemoveAll(typeof(DbContextOptions<FelloWayDbContext>));
            services.RemoveAll(typeof(FelloWayDbContext));

            services.AddDbContext<FelloWayDbContext>(options =>
                options.UseNpgsql(
                    "Host=127.0.0.1;Port=1;Database=felloway_unreachable;Username=x;Password=x;Timeout=1"));
        });
    }
}
