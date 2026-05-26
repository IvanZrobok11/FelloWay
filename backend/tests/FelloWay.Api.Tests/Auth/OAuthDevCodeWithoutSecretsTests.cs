using System.Net;
using System.Net.Http.Json;
using FelloWay.Api.Tests.Infrastructure;
using FelloWay.Infrastructure.Persistence.Seed;
using Microsoft.Extensions.DependencyInjection;

namespace FelloWay.Api.Tests.Auth;

public class OAuthDevCodeWithoutSecretsTests : IClassFixture<ProductionOAuthWebApplicationFactory>
{
    private readonly HttpClient _client;

    public OAuthDevCodeWithoutSecretsTests(ProductionOAuthWebApplicationFactory factory)
    {
        using var scope = factory.Services.CreateScope();
        var seeder = scope.ServiceProvider.GetRequiredService<IDataSeeder>();
        seeder.SeedAsync().GetAwaiter().GetResult();
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task DevCode_Rejected_WhenLinkedInSecretsAbsent()
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
}
