using FelloWay.Api.Tests.Infrastructure;
using Microsoft.AspNetCore.Hosting;

namespace FelloWay.Api.Tests.Admin;

public sealed class AdminContentWebApplicationFactory : FelloWayWebApplicationFactory
{
    public const string ServiceKey = "test-admin-service-key";

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        base.ConfigureWebHost(builder);
        builder.UseSetting("AdminAuth:ServiceKey", ServiceKey);
    }
}
