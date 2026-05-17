using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using FelloWay.Api.Tests.Infrastructure;
using FelloWay.Infrastructure.Persistence.Seed;
using Microsoft.Extensions.DependencyInjection;

namespace FelloWay.Api.Tests.Chat;

public class StreamTokenEndpointTests : IClassFixture<FelloWayWebApplicationFactory>
{
    private readonly FelloWayWebApplicationFactory _factory;

    public StreamTokenEndpointTests(FelloWayWebApplicationFactory factory)
    {
        _factory = factory;
        factory.EnsureDatabaseCreated();
        using var scope = factory.Services.CreateScope();
        scope.ServiceProvider.GetRequiredService<IDataSeeder>().SeedAsync().GetAwaiter().GetResult();
    }

    [Fact]
    public async Task GetStreamToken_ReturnsToken_WhenAuthenticated()
    {
        var client = _factory.CreateClient();
        var login = await client.PostAsJsonAsync(
            "/auth/oauth/linkedin/token",
            new
            {
                code = "dev-stream-user",
                redirectUri = "com.felloway.app:/oauthredirect",
                codeVerifier = "v",
            });
        var loginJson = await login.Content.ReadFromJsonAsync<JsonElement>();
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(
            "Bearer",
            loginJson.GetProperty("accessToken").GetString());

        var response = await client.GetAsync("/chat/stream-token");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var body = await response.Content.ReadFromJsonAsync<JsonElement>();
        Assert.Contains("dev-stream-token", body.GetProperty("token").GetString());
    }
}
