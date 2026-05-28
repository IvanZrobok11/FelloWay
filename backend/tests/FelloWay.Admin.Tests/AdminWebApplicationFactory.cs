using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;

namespace FelloWay.Admin.Tests;

public sealed class AdminWebApplicationFactory : WebApplicationFactory<Program>
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Testing");
        builder.UseSetting("AdminAuth:Username", "test-admin");
        builder.UseSetting("AdminAuth:Password", "test-password");
        builder.UseSetting("AdminAuth:ServiceKey", "test-service-key");
        builder.UseSetting("Api:BaseUrl", "http://localhost:9999");
    }
}
