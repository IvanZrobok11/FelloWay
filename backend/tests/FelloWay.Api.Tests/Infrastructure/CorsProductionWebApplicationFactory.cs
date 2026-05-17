using Microsoft.AspNetCore.Hosting;

namespace FelloWay.Api.Tests.Infrastructure;

/// <summary>
/// Fast-suite host with Production environment and explicit CORS allowlist.
/// </summary>
public class CorsProductionWebApplicationFactory : FelloWayWebApplicationFactory
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        base.ConfigureWebHost(builder);
        builder.UseEnvironment("Production");
        builder.UseSetting("Cors:AllowedOrigins:0", "https://app.felloway.test");
    }
}
