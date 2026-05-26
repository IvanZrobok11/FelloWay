using Microsoft.AspNetCore.Hosting;

namespace FelloWay.Api.Tests.Infrastructure;

/// <summary>
/// Production OAuth exchanger with LinkedIn secrets configured (dev codes and raw codes rejected).
/// </summary>
public sealed class LinkedInConfiguredProductionOAuthFactory : ProductionOAuthWebApplicationFactory
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseSetting("OAuth:LinkedIn:ClientId", "test-client-id");
        builder.UseSetting("OAuth:LinkedIn:ClientSecret", "test-client-secret");
        base.ConfigureWebHost(builder);
    }
}
