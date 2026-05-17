using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using FelloWay.Api.Tests.Infrastructure;
using FelloWay.Infrastructure.Persistence;
using FelloWay.Infrastructure.Persistence.Seed;
using Microsoft.Extensions.DependencyInjection;

namespace FelloWay.Api.Tests.Auth;

public class OAuthTokenEndpointTests : IClassFixture<FelloWayWebApplicationFactory>
{
    private readonly HttpClient _client;
    private readonly FelloWayWebApplicationFactory _factory;

    public OAuthTokenEndpointTests(FelloWayWebApplicationFactory factory)
    {
        _factory = factory;
        factory.EnsureDatabaseCreated();
        SeedAsync(factory).GetAwaiter().GetResult();
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task ExchangeOAuthToken_ReturnsAccessAndRefreshTokens()
    {
        var response = await _client.PostAsJsonAsync(
            "/auth/oauth/linkedin/token",
            new
            {
                code = "test-code",
                redirectUri = "com.felloway.app:/oauthredirect",
                codeVerifier = "verifier",
            });

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var json = await response.Content.ReadFromJsonAsync<JsonElement>();
        Assert.False(string.IsNullOrWhiteSpace(json.GetProperty("accessToken").GetString()));
        Assert.False(string.IsNullOrWhiteSpace(json.GetProperty("refreshToken").GetString()));
        Assert.True(json.GetProperty("userId").GetGuid() != Guid.Empty);
    }

    [Fact]
    public async Task RefreshToken_ReturnsNewPair()
    {
        var login = await _client.PostAsJsonAsync(
            "/auth/oauth/facebook/token",
            new
            {
                code = "dev-refresh-user",
                redirectUri = "com.felloway.app:/oauthredirect",
                codeVerifier = "verifier",
            });
        var loginJson = await login.Content.ReadFromJsonAsync<JsonElement>();
        var refreshToken = loginJson.GetProperty("refreshToken").GetString()!;

        var response = await _client.PostAsJsonAsync("/auth/refresh", new { refreshToken });
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    private static async Task SeedAsync(FelloWayWebApplicationFactory factory)
    {
        using var scope = factory.Services.CreateScope();
        var seeder = scope.ServiceProvider.GetRequiredService<IDataSeeder>();
        await seeder.SeedAsync();
    }
}
