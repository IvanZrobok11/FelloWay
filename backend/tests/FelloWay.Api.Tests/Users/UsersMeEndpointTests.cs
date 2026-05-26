using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using FelloWay.Api.Tests.Auth;
using FelloWay.Api.Tests.Infrastructure;
using FelloWay.Infrastructure.Persistence;
using FelloWay.Infrastructure.Persistence.Seed;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace FelloWay.Api.Tests.Users;

public class UsersMeEndpointTests : IClassFixture<FelloWayWebApplicationFactory>
{
    private readonly HttpClient _client;
    private readonly FelloWayWebApplicationFactory _factory;

    public UsersMeEndpointTests(FelloWayWebApplicationFactory factory)
    {
        _factory = factory;
        SeedAsync(factory).GetAwaiter().GetResult();
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task GetAndUpdateProfile_WorksForAuthenticatedUser()
    {
        var token = await _client.LoginAsync("dev-profile-user");
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<FelloWayDbContext>();
        var cityId = await db.Cities.Select(c => c.Id).FirstAsync();
        var interestIds = await db.Interests.Select(i => i.Id).Take(2).ToListAsync();

        var updateResponse = await _client.PutAsJsonAsync(
            "/users/me",
            new
            {
                displayName = "Alex Dev",
                bio = "Backend tester",
                homeCityId = cityId,
                interestIds,
            });
        Assert.Equal(HttpStatusCode.OK, updateResponse.StatusCode);

        var profile = await _client.GetFromJsonAsync<JsonElement>("/users/me");
        Assert.Equal("Alex Dev", profile.GetProperty("displayName").GetString());
        Assert.True(profile.GetProperty("isProfileComplete").GetBoolean());
    }

    [Fact]
    public async Task UpdateMe_WithInvalidInterestIds_ReturnsBadRequest()
    {
        var token = await _client.LoginAsync("dev-invalid-interests");
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<FelloWayDbContext>();
        var cityId = await db.Cities.Select(c => c.Id).FirstAsync();

        var response = await _client.PutAsJsonAsync(
            "/users/me",
            new
            {
                displayName = "Test User",
                homeCityId = cityId,
                interestIds = new[] { Guid.NewGuid(), Guid.NewGuid() },
            });

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task UpdateMe_WithValidInterestIds_PersistsOnGetMe()
    {
        var token = await _client.LoginAsync("dev-valid-interests");
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<FelloWayDbContext>();
        var cityId = await db.Cities.Select(c => c.Id).FirstAsync();
        var interestIds = await db.Interests.OrderBy(i => i.SortOrder).Take(2).Select(i => i.Id).ToListAsync();

        var updateResponse = await _client.PutAsJsonAsync(
            "/users/me",
            new
            {
                displayName = "Interest Tester",
                homeCityId = cityId,
                interestIds,
            });
        Assert.Equal(HttpStatusCode.OK, updateResponse.StatusCode);

        var profile = await _client.GetFromJsonAsync<JsonElement>("/users/me");
        var returnedIds = profile.GetProperty("interestIds").EnumerateArray()
            .Select(e => Guid.Parse(e.GetString()!))
            .ToList();
        Assert.Equal(interestIds.OrderBy(x => x), returnedIds.OrderBy(x => x));

        var names = profile.GetProperty("interests").EnumerateArray()
            .Select(e => e.GetProperty("name").GetString())
            .ToList();
        Assert.Equal(2, names.Count);
        Assert.All(names, n => Assert.False(string.IsNullOrWhiteSpace(n)));
    }

    [Fact]
    public async Task GetMe_WithoutToken_ReturnsUnauthorized()
    {
        var client = _factory.CreateClient();
        var response = await client.GetAsync("/users/me");
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    private static async Task SeedAsync(FelloWayWebApplicationFactory factory)
    {
        using var scope = factory.Services.CreateScope();
        var seeder = scope.ServiceProvider.GetRequiredService<IDataSeeder>();
        await seeder.SeedAsync();
    }
}
