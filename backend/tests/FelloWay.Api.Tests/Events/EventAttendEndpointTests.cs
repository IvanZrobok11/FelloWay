using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using FelloWay.Api.Tests.Auth;
using FelloWay.Api.Tests.Infrastructure;

namespace FelloWay.Api.Tests.Events;

public class EventAttendEndpointTests : IClassFixture<FelloWayWebApplicationFactory>
{
    private readonly HttpClient _client;
    private readonly FelloWayWebApplicationFactory _factory;

    public EventAttendEndpointTests(FelloWayWebApplicationFactory factory)
    {
        _factory = factory;
        EventsTestHelper.SeedAsync(factory).GetAwaiter().GetResult();
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task AttendAndLeave_UpdatesJoinedState()
    {
        var eventId = await EventsTestHelper.FirstEventIdAsync(_factory);
        var token = await _client.LoginAsync("dev-events-user");
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

        var attend = await _client.PostAsync($"/events/{eventId}/attend", null);
        Assert.Equal(HttpStatusCode.NoContent, attend.StatusCode);

        var detail = await _client.GetFromJsonAsync<JsonElement>($"/events/{eventId}");
        Assert.True(detail.GetProperty("isJoined").GetBoolean());
        Assert.Equal("attending", detail.GetProperty("attendStatus").GetString());

        var leave = await _client.DeleteAsync($"/events/{eventId}/attend");
        Assert.Equal(HttpStatusCode.NoContent, leave.StatusCode);

        var afterLeave = await _client.GetFromJsonAsync<JsonElement>($"/events/{eventId}");
        Assert.False(afterLeave.GetProperty("isJoined").GetBoolean());
    }

    [Fact]
    public async Task GetAttendees_WhenNotJoined_ReturnsBadRequest()
    {
        var eventId = await EventsTestHelper.FirstEventIdAsync(_factory);
        var token = await _client.LoginAsync("dev-events-guest");
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

        var response = await _client.GetAsync($"/events/{eventId}/attendees");
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task GetAttendees_WhenJoined_ReturnsList()
    {
        var eventId = await EventsTestHelper.FirstEventIdAsync(_factory);
        await EventsTestHelper.SeedSecondUserAttendeeAsync(_factory, eventId, "Olena");

        var token = await _client.LoginAsync("dev-events-member");
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

        await _client.PostAsync($"/events/{eventId}/attend", null);

        var response = await _client.GetAsync($"/events/{eventId}/attendees");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        var json = await response.Content.ReadFromJsonAsync<JsonElement>();
        Assert.True(json.GetProperty("items").GetArrayLength() >= 2);
    }

}
