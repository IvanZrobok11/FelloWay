using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using FelloWay.Api.Tests.Auth;
using FelloWay.Api.Tests.Events;
using FelloWay.Api.Tests.Infrastructure;
using FelloWay.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace FelloWay.Api.Tests.Users;

public class TrustAndPrefsEndpointTests : IClassFixture<FelloWayWebApplicationFactory>
{
    private readonly HttpClient _client;
    private readonly FelloWayWebApplicationFactory _factory;

    public TrustAndPrefsEndpointTests(FelloWayWebApplicationFactory factory)
    {
        _factory = factory;
        EventsTestHelper.SeedAsync(factory).GetAwaiter().GetResult();
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task BlockReviewAndPushPreferences_Work()
    {
        var eventId = await EventsTestHelper.FirstEventIdAsync(_factory);
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<FelloWayDbContext>();
        var cityId = await db.Cities.Select(c => c.Id).FirstAsync();

        var authorToken = await _client.LoginAsync("trust-author");
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", authorToken);
        await _client.PutAsJsonAsync(
            "/users/me",
            new { displayName = "Author", homeCityId = cityId, interestIds = Array.Empty<Guid>() });
        await _client.PostAsync($"/events/{eventId}/attend", null);

        var subjectToken = await _client.LoginAsync("trust-subject");
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", subjectToken);
        await _client.PutAsJsonAsync(
            "/users/me",
            new { displayName = "Subject", homeCityId = cityId, interestIds = Array.Empty<Guid>() });
        await _client.PostAsync($"/events/{eventId}/attend", null);

        var subjectId = await UserIdForSubjectAsync("trust-subject");

        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", authorToken);
        var reviewResponse = await _client.PostAsJsonAsync(
            $"/events/{eventId}/attendees/{subjectId}/review",
            new { rating = 5, comment = "Great networking" });
        Assert.Equal(HttpStatusCode.Created, reviewResponse.StatusCode);

        var reviews = await _client.GetFromJsonAsync<JsonElement>($"/users/{subjectId}/reviews");
        Assert.True(reviews.GetProperty("items").GetArrayLength() >= 1);

        var blockResponse = await _client.PostAsync($"/users/{subjectId}/block", null);
        Assert.Equal(HttpStatusCode.NoContent, blockResponse.StatusCode);

        var prefsResponse = await _client.PutAsJsonAsync(
            "/users/me/push-preferences",
            new
            {
                globalEnabled = true,
                eventMessages = false,
                tripMessages = true,
                directMessages = true,
            });
        Assert.Equal(HttpStatusCode.NoContent, prefsResponse.StatusCode);
    }

    private async Task<Guid> UserIdForSubjectAsync(string subject)
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<FelloWayDbContext>();
        return await db.OAuthIdentities
            .Where(i => i.ProviderSubject == subject)
            .Select(i => i.UserId)
            .FirstAsync();
    }
}
