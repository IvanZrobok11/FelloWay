using FelloWay.Infrastructure.Persistence;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;

namespace FelloWay.Api.Tests.Infrastructure;

/// <summary>
/// Default fast-suite host: in-memory EF, no PostgreSQL, no Hangfire, no startup DB init.
/// </summary>
public class FelloWayWebApplicationFactory : WebApplicationFactory<Program>
{
    private readonly string _databaseName = $"felloway_mem_{Guid.NewGuid():N}";

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Testing");
        // UseSetting applies before Program.cs reads configuration (AddInfrastructure).
        builder.UseSetting("Database:SkipInitialization", "true");
        builder.UseSetting("Database:DisableHangfire", "true");
        builder.UseSetting("Frontend:BaseUrl", "https://localhost:7357");

        builder.ConfigureServices(services =>
        {
            services.RemoveAll(typeof(DbContextOptions<FelloWayDbContext>));
            services.RemoveAll(typeof(FelloWayDbContext));

            services.AddDbContext<FelloWayDbContext>(options =>
                options.UseInMemoryDatabase(_databaseName));
        });
    }
}
