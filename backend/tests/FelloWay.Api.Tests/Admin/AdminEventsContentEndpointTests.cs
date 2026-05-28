using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using FelloWay.Api.Tests.Events;
using FelloWay.Api.Tests.Infrastructure;
using FelloWay.Domain.Enums;
using FelloWay.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace FelloWay.Api.Tests.Admin;

public class AdminEventsContentEndpointTests : IClassFixture<AdminContentWebApplicationFactory>
{
    private readonly AdminContentWebApplicationFactory _factory;
    private readonly HttpClient _client;

    public AdminEventsContentEndpointTests(AdminContentWebApplicationFactory factory)
    {
        _factory = factory;
        EventsTestHelper.SeedAsync(factory).GetAwaiter().GetResult();
        _client = factory.CreateClient();
        _client.DefaultRequestHeaders.Add(
            "X-Admin-Service-Key",
            AdminContentWebApplicationFactory.ServiceKey);
    }

    [Fact]
    public async Task MissingServiceKey_ReturnsUnauthorized()
    {
        var client = _factory.CreateClient();
        var response = await client.GetAsync("/admin/events/cities");
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task InvalidServiceKey_ReturnsUnauthorized()
    {
        var client = _factory.CreateClient();
        client.DefaultRequestHeaders.Add("X-Admin-Service-Key", "wrong-key");
        var response = await client.GetAsync("/admin/events/cities");
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task ListCities_ReturnsSeededCities()
    {
        var response = await _client.GetFromJsonAsync<JsonElement>("/admin/events/cities");
        Assert.True(response.GetProperty("items").GetArrayLength() >= 1);
    }

    [Fact]
    public async Task CreateEvent_WithServiceKey_PersistsActiveEvent()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<FelloWayDbContext>();
        var cityId = await db.Cities.Select(c => c.Id).FirstAsync();

        var starts = DateTimeOffset.UtcNow.AddDays(30);
        var body = new
        {
            title = "Admin created meetup",
            description = "Created via service key",
            startsAt = starts,
            endsAt = starts.AddHours(2),
            cityId,
            venue = "Central Park",
            capacity = 50,
        };

        var create = await _client.PostAsJsonAsync("/admin/events", body);
        Assert.Equal(HttpStatusCode.Created, create.StatusCode);
        var id = (await create.Content.ReadFromJsonAsync<JsonElement>())!.GetProperty("id").GetGuid();

        var entity = await db.Events.AsNoTracking().FirstAsync(e => e.Id == id);
        Assert.Equal(EventStatus.Active, entity.Status);
        Assert.Equal("Admin created meetup", entity.Title);
    }

    [Fact]
    public async Task CreateEvent_EndBeforeStart_ReturnsBadRequest()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<FelloWayDbContext>();
        var cityId = await db.Cities.Select(c => c.Id).FirstAsync();
        var starts = DateTimeOffset.UtcNow.AddDays(5);

        var body = new
        {
            title = "Bad dates",
            startsAt = starts,
            endsAt = starts.AddHours(-1),
            cityId,
        };

        var create = await _client.PostAsJsonAsync("/admin/events", body);
        Assert.Equal(HttpStatusCode.BadRequest, create.StatusCode);
    }

    [Fact]
    public async Task UploadCover_UpdatesCoverImageUrl()
    {
        var eventId = await EventsTestHelper.FirstEventIdAsync(_factory);
        var pngBytes = Convert.FromBase64String(
            "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==");
        using var content = new MultipartFormDataContent();
        var fileContent = new ByteArrayContent(pngBytes);
        fileContent.Headers.ContentType = new MediaTypeHeaderValue("image/png");
        content.Add(fileContent, "file", "cover.png");

        var response = await _client.PostAsync($"/admin/events/{eventId}/cover", content);
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<FelloWayDbContext>();
        var entity = await db.Events.AsNoTracking().FirstAsync(e => e.Id == eventId);
        Assert.False(string.IsNullOrWhiteSpace(entity.CoverImageUrl));
    }

    [Fact]
    public async Task ListAndUpdateEvent_WorksWithServiceKey()
    {
        var eventId = await EventsTestHelper.FirstEventIdAsync(_factory);

        var list = await _client.GetFromJsonAsync<JsonElement>("/admin/events");
        Assert.True(list.GetProperty("items").GetArrayLength() >= 1);

        var detail = await _client.GetFromJsonAsync<JsonElement>($"/admin/events/{eventId}");
        Assert.Equal(eventId, detail.GetProperty("id").GetGuid());

        var updateBody = new { description = "Updated by admin content API", status = "rejected" };
        var update = await _client.PutAsJsonAsync($"/admin/events/{eventId}", updateBody);
        Assert.Equal(HttpStatusCode.NoContent, update.StatusCode);

        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<FelloWayDbContext>();
        var entity = await db.Events.AsNoTracking().FirstAsync(e => e.Id == eventId);
        Assert.Equal(EventStatus.Rejected, entity.Status);
        Assert.Equal("Updated by admin content API", entity.Description);
    }
}
