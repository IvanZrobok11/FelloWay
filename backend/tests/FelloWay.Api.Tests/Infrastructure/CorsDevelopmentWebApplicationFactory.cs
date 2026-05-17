using Microsoft.AspNetCore.Hosting;

namespace FelloWay.Api.Tests.Infrastructure;

/// <summary>
/// Fast-suite host with Development environment for localhost CORS predicate tests.
/// </summary>
public class CorsDevelopmentWebApplicationFactory : FelloWayWebApplicationFactory
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        base.ConfigureWebHost(builder);
        builder.UseEnvironment("Development");
    }
}
