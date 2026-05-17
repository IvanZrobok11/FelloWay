using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
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
        factory.EnsureDatabaseCreated();
        SeedAsync(factory).GetAwaiter().GetResult();
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task GetAndUpdateProfile_WorksForAuthenticatedUser()
    {
        var token = await LoginAsync("dev-profile-user");
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
    public async Task GetMe_WithoutToken_ReturnsUnauthorized()
    {
        var client = _factory.CreateClient();
        var response = await client.GetAsync("/users/me");
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    private async Task<string> LoginAsync(string subject)
    {
        var response = await _client.PostAsJsonAsync(
            "/auth/oauth/linkedin/token",
            new
            {
                code = $"dev-{subject}",
                redirectUri = "com.felloway.app:/oauthredirect",
                codeVerifier = "verifier",
            });
        response.EnsureSuccessStatusCode();
        var json = await response.Content.ReadFromJsonAsync<JsonElement>();
        return json.GetProperty("accessToken").GetString()!;
    }

    private static async Task SeedAsync(FelloWayWebApplicationFactory factory)
    {
        using var scope = factory.Services.CreateScope();
        var seeder = scope.ServiceProvider.GetRequiredService<IDataSeeder>();
        await seeder.SeedAsync();
    }
}
