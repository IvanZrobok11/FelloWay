using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using FelloWay.Api.Tests.Infrastructure;
using Microsoft.Extensions.DependencyInjection;

namespace FelloWay.Api.Tests.Events;

public class EventsListEndpointTests : IClassFixture<FelloWayWebApplicationFactory>
{
    private readonly HttpClient _client;
    private readonly FelloWayWebApplicationFactory _factory;

    public EventsListEndpointTests(FelloWayWebApplicationFactory factory)
    {
        _factory = factory;
        EventsTestHelper.SeedAsync(factory).GetAwaiter().GetResult();
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task ListEvents_ReturnsSeededItems()
    {
        var response = await _client.GetAsync("/events");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        var json = await response.Content.ReadFromJsonAsync<JsonElement>();
        var items = json.GetProperty("items");
        Assert.True(items.GetArrayLength() >= 2);
    }

    [Fact]
    public async Task ListEvents_FilterByCity_ReturnsMatchingOnly()
    {
        var response = await _client.GetAsync("/events?city=Kyiv");
        var json = await response.Content.ReadFromJsonAsync<JsonElement>();
        var items = json.GetProperty("items").EnumerateArray().ToList();
        Assert.All(items, e => Assert.Contains("Kyiv", e.GetProperty("city").GetString(), StringComparison.OrdinalIgnoreCase));
    }

    [Fact]
    public async Task ListEvents_SearchQuery_FiltersTitle()
    {
        var response = await _client.GetAsync("/events?q=Product");
        var json = await response.Content.ReadFromJsonAsync<JsonElement>();
        var items = json.GetProperty("items").EnumerateArray().ToList();
        Assert.Single(items);
        Assert.Contains("Product", items[0].GetProperty("title").GetString());
    }
}
