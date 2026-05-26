using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using FelloWay.Api.Tests.Auth;
using FelloWay.Api.Tests.Events;
using FelloWay.Api.Tests.Infrastructure;
using FelloWay.Infrastructure.Persistence;
using FelloWay.Infrastructure.Persistence.Seed;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace FelloWay.Api.Tests.Trips;

public class TripJoinFlowEndpointTests : IClassFixture<FelloWayWebApplicationFactory>
{
    private readonly HttpClient _client;
    private readonly FelloWayWebApplicationFactory _factory;

    public TripJoinFlowEndpointTests(FelloWayWebApplicationFactory factory)
    {
        _factory = factory;
        EventsTestHelper.SeedAsync(factory).GetAwaiter().GetResult();
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task CreateTrip_JoinAutoApproveAndManualApprove_Works()
    {
        var eventId = await EventsTestHelper.FirstEventIdAsync(_factory);
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<FelloWayDbContext>();
        var kyivId = await db.Cities.Where(c => c.Name == "Kyiv").Select(c => c.Id).FirstAsync();
        var lvivId = await db.Cities.Where(c => c.Name == "Lviv").Select(c => c.Id).FirstAsync();

        var ownerToken = await _client.LoginAsync("trip-owner");
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", ownerToken);
        await _client.PostAsync($"/events/{eventId}/attend", null);

        var createResponse = await _client.PostAsJsonAsync(
            $"/events/{eventId}/trips",
            new
            {
                routeLabel = "Kyiv → ICC",
                departureAt = DateTimeOffset.UtcNow.AddDays(10),
                transportRole = "driver",
                originCityId = kyivId,
                capacity = 4,
            });
        Assert.Equal(HttpStatusCode.Created, createResponse.StatusCode);
        var tripJson = await createResponse.Content.ReadFromJsonAsync<JsonElement>();
        var tripId = tripJson.GetProperty("id").GetGuid();

        var kyivUserToken = await _client.LoginAsync("trip-kyiv-guest");
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", kyivUserToken);
        await SetHomeCityAsync(kyivUserToken, kyivId);
        await _client.PostAsync($"/events/{eventId}/attend", null);

        var autoJoin = await _client.PostAsync($"/trips/{tripId}/join", null);
        Assert.Equal(HttpStatusCode.Created, autoJoin.StatusCode);

        var lvivUserToken = await _client.LoginAsync("trip-lviv-guest");
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", lvivUserToken);
        await SetHomeCityAsync(lvivUserToken, lvivId);
        await _client.PostAsync($"/events/{eventId}/attend", null);

        var pendingJoin = await _client.PostAsync($"/trips/{tripId}/join", null);
        Assert.Equal(HttpStatusCode.Created, pendingJoin.StatusCode);

        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", ownerToken);
        var requests = await _client.GetFromJsonAsync<JsonElement>($"/trips/{tripId}/join-requests");
        var pendingItems = requests.GetProperty("items").EnumerateArray().ToList();
        Assert.Single(pendingItems);
        var requesterId = pendingItems[0].GetProperty("userId").GetGuid();

        var approve = await _client.PostAsync($"/trips/{tripId}/approve/{requesterId}", null);
        Assert.Equal(HttpStatusCode.NoContent, approve.StatusCode);

        var list = await _client.GetFromJsonAsync<JsonElement>($"/events/{eventId}/trips");
        var trip = list.GetProperty("items").EnumerateArray().First(t => t.GetProperty("id").GetGuid() == tripId);
        Assert.True(trip.GetProperty("memberCount").GetInt32() >= 3);
    }

    private async Task SetHomeCityAsync(string token, Guid cityId)
    {
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
        var response = await _client.PutAsJsonAsync(
            "/users/me",
            new { displayName = "Trip Tester", homeCityId = cityId, interestIds = Array.Empty<Guid>() });
        response.EnsureSuccessStatusCode();
    }
}
