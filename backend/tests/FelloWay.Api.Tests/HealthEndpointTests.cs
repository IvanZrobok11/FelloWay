using System.Net;
using System.Text.Json;
using FelloWay.Api.Tests.Infrastructure;

namespace FelloWay.Api.Tests;

public class HealthEndpointTests : IClassFixture<FelloWayWebApplicationFactory>
{
    private readonly HttpClient _client;

    public HealthEndpointTests(FelloWayWebApplicationFactory factory)
    {
        factory.EnsureDatabaseCreated();
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task GetHealth_ReturnsOk()
    {
        var response = await _client.GetAsync("/health");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        var json = await ParseHealthJsonAsync(response);
        Assert.Equal("Healthy", json.GetProperty("status").GetString());
        Assert.True(json.GetProperty("entries").TryGetProperty("self", out _));
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

    private static async Task<JsonElement> ParseHealthJsonAsync(HttpResponseMessage response)
    {
        await using var stream = await response.Content.ReadAsStreamAsync();
        return await JsonSerializer.DeserializeAsync<JsonElement>(stream);
    }
}

public class ReadinessWhenDatabaseUnavailableTests
    : IClassFixture<UnavailableDatabaseWebApplicationFactory>
{
    private readonly HttpClient _client;

    public ReadinessWhenDatabaseUnavailableTests(UnavailableDatabaseWebApplicationFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task GetReady_ReturnsServiceUnavailable()
    {
        var response = await _client.GetAsync("/health/ready");
        Assert.Equal(HttpStatusCode.ServiceUnavailable, response.StatusCode);
    }

    [Fact]
    public async Task GetHealth_ReturnsOk_WhenDatabaseUnavailable()
    {
        var response = await _client.GetAsync("/health");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }
}
