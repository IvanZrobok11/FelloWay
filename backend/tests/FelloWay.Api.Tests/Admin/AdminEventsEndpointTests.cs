using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using FelloWay.Api.Tests.Events;
using FelloWay.Api.Tests.Infrastructure;
using FelloWay.Domain.Enums;
using FelloWay.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace FelloWay.Api.Tests.Admin;

public class AdminEventsEndpointTests : IClassFixture<FelloWayWebApplicationFactory>
{
    private readonly HttpClient _client;
    private readonly FelloWayWebApplicationFactory _factory;

    public AdminEventsEndpointTests(FelloWayWebApplicationFactory factory)
    {
        _factory = factory;
        factory.EnsureDatabaseCreated();
        EventsTestHelper.SeedAsync(factory).GetAwaiter().GetResult();
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task AdminApprovesPendingEvent()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<FelloWayDbContext>();
        var pendingId = await db.Events
            .Where(e => e.Status == EventStatus.Pending)
            .Select(e => e.Id)
            .FirstAsync();

        var adminToken = await LoginAsync("admin");
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", adminToken);

        var list = await _client.GetFromJsonAsync<JsonElement>("/admin/events/pending");
        Assert.True(list.GetProperty("items").GetArrayLength() >= 1);

        var approve = await _client.PostAsync($"/admin/events/{pendingId}/approve", null);
        Assert.Equal(HttpStatusCode.NoContent, approve.StatusCode);

        var updated = await db.Events.AsNoTracking().FirstAsync(e => e.Id == pendingId);
        Assert.Equal(EventStatus.Active, updated.Status);
    }

    [Fact]
    public async Task NonAdminCannotAccessPendingEvents()
    {
        var userToken = await LoginAsync("regular-user");
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", userToken);

        var response = await _client.GetAsync("/admin/events/pending");
        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
    }

    private async Task<string> LoginAsync(string subject)
    {
        var code = subject == "admin" ? "dev-admin" : $"dev-{subject}";
        var response = await _client.PostAsJsonAsync(
            "/auth/oauth/linkedin/token",
            new
            {
                code,
                redirectUri = "com.felloway.app:/oauthredirect",
                codeVerifier = "verifier",
            });
        response.EnsureSuccessStatusCode();
        var json = await response.Content.ReadFromJsonAsync<JsonElement>();
        return json.GetProperty("accessToken").GetString()!;
    }
}
