using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using FelloWay.Api.Tests.Infrastructure;
using FelloWay.Infrastructure.Persistence.Seed;
using Microsoft.Extensions.DependencyInjection;

namespace FelloWay.Api.Tests.Reference;

public class InterestsEndpointTests : IClassFixture<FelloWayWebApplicationFactory>
{
    private readonly HttpClient _client;
    private readonly FelloWayWebApplicationFactory _factory;

    public InterestsEndpointTests(FelloWayWebApplicationFactory factory)
    {
        _factory = factory;
        SeedAsync(factory).GetAwaiter().GetResult();
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task GetInterests_ReturnsTenCanonicalItems()
    {
        var response = await _client.GetAsync("/interests");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        var json = await response.Content.ReadFromJsonAsync<JsonElement>();
        var items = json.GetProperty("items");
        Assert.Equal(10, items.GetArrayLength());

        var names = items.EnumerateArray().Select(i => i.GetProperty("name").GetString()).ToList();
        Assert.Contains("ІТ та розробка", names);
    }

    [Fact]
    public async Task GetInterests_ReturnsDistinctIdsAndSortOrdersOneThroughTen()
    {
        var json = await _client.GetFromJsonAsync<JsonElement>("/interests");
        var items = json.GetProperty("items").EnumerateArray().ToList();

        var ids = items.Select(i => i.GetProperty("id").GetString()).ToList();
        Assert.Equal(10, ids.Distinct().Count());

        var sortOrders = items.Select(i => i.GetProperty("sortOrder").GetInt32()).OrderBy(x => x).ToList();
        Assert.Equal(Enumerable.Range(1, 10), sortOrders);

        var expectedIds = InterestCatalogSeed.Catalog.Select(e => e.Id.ToString()).ToHashSet();
        Assert.All(ids, id => Assert.Contains(id, expectedIds));
    }

    private static async Task SeedAsync(FelloWayWebApplicationFactory factory)
    {
        using var scope = factory.Services.CreateScope();
        var seeder = scope.ServiceProvider.GetRequiredService<IDataSeeder>();
        await seeder.SeedAsync();
    }
}
