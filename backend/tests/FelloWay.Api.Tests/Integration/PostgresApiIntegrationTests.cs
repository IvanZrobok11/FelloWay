using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using FelloWay.Api.Tests.Infrastructure;

namespace FelloWay.Api.Tests.Integration;

[Trait("Category", "Integration")]
[Collection("Integration")]
public class PostgresApiIntegrationTests : IClassFixture<PostgresWebApplicationFactory>
{
    private readonly HttpClient _client;

    public PostgresApiIntegrationTests(PostgresWebApplicationFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task GetReady_ReturnsOk_WhenDatabaseAvailable()
    {
        var response = await _client.GetAsync("/health/ready");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        var json = await ParseHealthJsonAsync(response);
        Assert.Equal("Healthy", json.GetProperty("status").GetString());
        Assert.True(json.GetProperty("entries").TryGetProperty("database", out _));
    }

    [Fact]
    public async Task ExchangeOAuth_AndGetEvents_UsesRealDatabase()
    {
        var tokenResponse = await _client.PostAsJsonAsync(
            "/auth/oauth/linkedin/token",
            new
            {
                code = "dev-integration-user",
                redirectUri = "http://localhost",
                codeVerifier = "x",
            });
        Assert.Equal(HttpStatusCode.OK, tokenResponse.StatusCode);

        var tokens = await tokenResponse.Content.ReadFromJsonAsync<JsonElement>();
        var access = tokens.GetProperty("accessToken").GetString();
        Assert.False(string.IsNullOrWhiteSpace(access));

        var request = new HttpRequestMessage(HttpMethod.Get, "/events");
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", access);
        var eventsResponse = await _client.SendAsync(request);

        Assert.Equal(HttpStatusCode.OK, eventsResponse.StatusCode);
    }

    private static async Task<JsonElement> ParseHealthJsonAsync(HttpResponseMessage response)
    {
        await using var stream = await response.Content.ReadAsStreamAsync();
        var json = await JsonSerializer.DeserializeAsync<JsonElement>(stream);
        Assert.True(json.ValueKind != JsonValueKind.Undefined);
        return json;
    }
}
