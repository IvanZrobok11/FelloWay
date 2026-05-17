using FelloWay.Infrastructure.Persistence;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;

namespace FelloWay.Api.Tests.Infrastructure;

public class FelloWayWebApplicationFactory : WebApplicationFactory<Program>
{
    private readonly string _databaseName = $"FelloWayTests_{Guid.NewGuid():N}";

    public void EnsureDatabaseCreated()
    {
        using var scope = Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<FelloWayDbContext>();
        db.Database.EnsureCreated();
    }

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Testing");

        builder.ConfigureServices(services =>
        {
            services.RemoveAll(typeof(DbContextOptions<FelloWayDbContext>));
            services.RemoveAll(typeof(FelloWayDbContext));

            services.AddDbContext<FelloWayDbContext>(options =>
                options.UseInMemoryDatabase(_databaseName));
        });
    }
}
