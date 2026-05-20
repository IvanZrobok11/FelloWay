using System.Net;
using System.Net.Http.Json;
using FelloWay.Api.Tests.Infrastructure;
using FelloWay.Infrastructure.Persistence.Seed;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.DependencyInjection;

namespace FelloWay.Api.Tests.Auth;

public class OAuthDevCodeRejectionTests : IClassFixture<LinkedInConfiguredWebApplicationFactory>
{
    private readonly HttpClient _client;

    public OAuthDevCodeRejectionTests(LinkedInConfiguredWebApplicationFactory factory)
    {
        SeedAsync(factory).GetAwaiter().GetResult();
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task RealLinkedInCode_ReturnsBadRequest_WhenLinkedInSecretsConfigured()
    {
        var response = await _client.PostAsJsonAsync(
            "/auth/oauth/linkedin/token",
            new
            {
                code = "real-linkedin-authorization-code",
                redirectUri = "https://localhost:5001/auth/linkedin/callback",
                codeVerifier = "verifier",
            });

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task DevCode_StillAccepted_WhenLinkedInSecretsConfigured()
    {
        var response = await _client.PostAsJsonAsync(
            "/auth/oauth/linkedin/token",
            new
            {
                code = "dev-smoke-user",
                redirectUri = "com.felloway.app:/oauthredirect",
                codeVerifier = "verifier",
            });

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    private static async Task SeedAsync(WebApplicationFactory<Program> factory)
    {
        using var scope = factory.Services.CreateScope();
        var seeder = scope.ServiceProvider.GetRequiredService<IDataSeeder>();
        await seeder.SeedAsync();
    }
}

/// <summary>
/// In-memory host with LinkedIn OAuth secrets set (real codes rejected; dev-* still allowed).
/// </summary>
public class LinkedInConfiguredWebApplicationFactory : FelloWayWebApplicationFactory
{
    protected override void ConfigureWebHost(Microsoft.AspNetCore.Hosting.IWebHostBuilder builder)
    {
        builder.UseSetting("OAuth:LinkedIn:ClientId", "test-client-id");
        builder.UseSetting("OAuth:LinkedIn:ClientSecret", "test-client-secret");
        base.ConfigureWebHost(builder);
    }
}
