using System.Net;
using System.Net.Http.Json;
using FelloWay.Api.Tests.Infrastructure;
using FelloWay.Infrastructure.Persistence.Seed;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.DependencyInjection;

namespace FelloWay.Api.Tests.Auth;

public class OAuthDevCodeRejectionTests : IClassFixture<LinkedInConfiguredProductionOAuthFactory>
{
    private readonly HttpClient _client;

    public OAuthDevCodeRejectionTests(LinkedInConfiguredProductionOAuthFactory factory)
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
    public async Task DevCode_Rejected_WhenLinkedInSecretsConfigured()
    {
        var response = await _client.PostAsJsonAsync(
            "/auth/oauth/linkedin/token",
            new
            {
                code = "dev-smoke-user",
                redirectUri = "com.felloway.app:/oauthredirect",
                codeVerifier = "verifier",
            });

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    private static async Task SeedAsync(WebApplicationFactory<Program> factory)
    {
        using var scope = factory.Services.CreateScope();
        var seeder = scope.ServiceProvider.GetRequiredService<IDataSeeder>();
        await seeder.SeedAsync();
    }
}
