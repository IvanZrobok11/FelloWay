using Microsoft.AspNetCore.Hosting;

namespace FelloWay.Api.Tests.Infrastructure;

/// <summary>
/// Testing environment with a single configured allowed origin (no localhost predicate).
/// </summary>
public class CorsConfiguredOriginWebApplicationFactory : FelloWayWebApplicationFactory
{
    public const string AllowedOrigin = "https://web.felloway.test";

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        base.ConfigureWebHost(builder);
        builder.UseSetting("Cors:AllowedOrigins:0", AllowedOrigin);
    }
}
