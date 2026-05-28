using System.Net;
using System.Net.Http.Json;
using FelloWay.Api.Tests.Infrastructure;
using FelloWay.Application.Auth.Models;
using FelloWay.Domain.Entities;
using FelloWay.Domain.Enums;
using FelloWay.Infrastructure.Auth;
using FelloWay.Infrastructure.Persistence;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.DependencyInjection;

namespace FelloWay.Api.Tests.Auth;

file sealed class LinkedInOAuthConfiguredFactory : FelloWayWebApplicationFactory
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        base.ConfigureWebHost(builder);
        builder.UseSetting("OAuth:LinkedIn:ClientId", "test-client");
        builder.UseSetting("OAuth:LinkedIn:ClientSecret", "test-secret");
    }
}

public class LinkedInBffLoginTests : IClassFixture<FelloWayWebApplicationFactory>
{
    private readonly FelloWayWebApplicationFactory _factory;

    public LinkedInBffLoginTests(FelloWayWebApplicationFactory factory) => _factory = factory;

    [Fact]
    public async Task UsersMe_WithoutCredentials_Returns401_NotLinkedInRedirect()
    {
        await using var factory = new LinkedInOAuthConfiguredFactory();
        var client = factory.CreateClient(new WebApplicationFactoryClientOptions
        {
            AllowAutoRedirect = false,
        });
        var response = await client.GetAsync("/users/me");
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
        Assert.DoesNotContain(
            "linkedin.com",
            response.Headers.Location?.ToString() ?? string.Empty,
            StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task LinkedInLogin_WithForwardedProtoHttps_UsesHttpsInOAuthRedirectUri()
    {
        await using var factory = new LinkedInOAuthConfiguredFactory();
        var client = factory.CreateClient(new WebApplicationFactoryClientOptions
        {
            AllowAutoRedirect = false,
        });

        using var request = new HttpRequestMessage(
            HttpMethod.Get,
            "/auth/linkedin/login?returnUrl=https://web.felloway.test");
        request.Headers.TryAddWithoutValidation("X-Forwarded-Proto", "https");
        request.Headers.TryAddWithoutValidation("X-Forwarded-Host", "api.felloway.test");

        var response = await client.SendAsync(request);

        Assert.Equal(HttpStatusCode.Redirect, response.StatusCode);
        var location = response.Headers.Location?.ToString() ?? string.Empty;
        Assert.Contains("redirect_uri=", location, StringComparison.OrdinalIgnoreCase);
        Assert.Contains(
            Uri.EscapeDataString("https://api.felloway.test/auth/linkedin/callback"),
            location,
            StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task LinkedInLogin_WhenSecretsMissing_Returns503()
    {
        var client = _factory.CreateClient();
        var response = await client.GetAsync("/auth/linkedin/login");
        Assert.Equal(HttpStatusCode.ServiceUnavailable, response.StatusCode);
    }

    [Fact]
    public async Task MobileComplete_WithValidTicket_ReturnsTokens()
    {
        var userId = Guid.NewGuid();
        await SeedUserAsync(userId);

        using var scope = _factory.Services.CreateScope();
        var store = scope.ServiceProvider.GetRequiredService<IMobileAuthTicketStore>();
        var ticket = store.Create(userId);

        var client = _factory.CreateClient();
        var response = await client.PostAsJsonAsync(
            "/auth/linkedin/mobile/complete",
            new { ticket });

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var body = await response.Content.ReadFromJsonAsync<TokenResponseDto>();
        Assert.NotNull(body);
        Assert.Equal(userId, body.UserId);
        Assert.False(string.IsNullOrWhiteSpace(body.AccessToken));
        Assert.False(string.IsNullOrWhiteSpace(body.RefreshToken));
    }

    [Fact]
    public async Task MobileComplete_WithInvalidTicket_Returns400()
    {
        var client = _factory.CreateClient();
        var response = await client.PostAsJsonAsync(
            "/auth/linkedin/mobile/complete",
            new { ticket = "not-a-real-ticket" });

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task MobileComplete_TicketIsSingleUse()
    {
        var userId = Guid.NewGuid();
        await SeedUserAsync(userId);

        using var scope = _factory.Services.CreateScope();
        var store = scope.ServiceProvider.GetRequiredService<IMobileAuthTicketStore>();
        var ticket = store.Create(userId);

        var client = _factory.CreateClient();
        var first = await client.PostAsJsonAsync(
            "/auth/linkedin/mobile/complete",
            new { ticket });
        Assert.Equal(HttpStatusCode.OK, first.StatusCode);

        var second = await client.PostAsJsonAsync(
            "/auth/linkedin/mobile/complete",
            new { ticket });
        Assert.Equal(HttpStatusCode.BadRequest, second.StatusCode);
    }

    [Fact]
    public async Task TestingWebSession_SetsHttpOnlySessionCookie()
    {
        var userId = Guid.NewGuid();
        await SeedUserAsync(userId);

        var client = WebSessionTestClient.CreateWithCookies(_factory);
        var response = await client.PostAsJsonAsync(
            "/auth/testing/web-session",
            new { userId });

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.True(response.Headers.TryGetValues("Set-Cookie", out var cookies));
        var combined = string.Join("; ", cookies!);
        Assert.Contains("felloway.session=", combined, StringComparison.OrdinalIgnoreCase);
        Assert.Contains("httponly", combined, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task UsersMe_Succeeds_WithWebSessionCookie()
    {
        var userId = Guid.NewGuid();
        await SeedUserAsync(userId);

        var client = WebSessionTestClient.CreateWithCookies(_factory);
        await WebSessionTestClient.SignInWebSessionAsync(client, userId);

        var me = await client.GetAsync("/users/me");
        Assert.Equal(HttpStatusCode.OK, me.StatusCode);
    }

    [Fact]
    public async Task Session_And_UsersMe_Succeed_OnSecondRequest_WithCookie()
    {
        var userId = Guid.NewGuid();
        await SeedUserAsync(userId);

        var client = WebSessionTestClient.CreateWithCookies(_factory);
        await WebSessionTestClient.SignInWebSessionAsync(client, userId);

        var session = await client.GetAsync("/auth/session");
        Assert.Equal(HttpStatusCode.OK, session.StatusCode);

        var me = await client.GetAsync("/users/me");
        Assert.Equal(HttpStatusCode.OK, me.StatusCode);
    }

    [Fact]
    public async Task MobileComplete_ThenRefresh_Works()
    {
        var userId = Guid.NewGuid();
        await SeedUserAsync(userId);

        using var scope = _factory.Services.CreateScope();
        var store = scope.ServiceProvider.GetRequiredService<IMobileAuthTicketStore>();
        var ticket = store.Create(userId);

        var client = _factory.CreateClient();
        var complete = await client.PostAsJsonAsync(
            "/auth/linkedin/mobile/complete",
            new { ticket });
        Assert.Equal(HttpStatusCode.OK, complete.StatusCode);
        var tokens = await complete.Content.ReadFromJsonAsync<TokenResponseDto>();
        Assert.NotNull(tokens);

        var refresh = await client.PostAsJsonAsync(
            "/auth/refresh",
            new { refreshToken = tokens.RefreshToken });
        Assert.Equal(HttpStatusCode.OK, refresh.StatusCode);
        var refreshed = await refresh.Content.ReadFromJsonAsync<TokenResponseDto>();
        Assert.NotNull(refreshed);
        Assert.False(string.IsNullOrWhiteSpace(refreshed.AccessToken));
    }

    private async Task SeedUserAsync(Guid userId)
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<FelloWayDbContext>();
        db.Users.Add(new User
        {
            Id = userId,
            DisplayName = "BFF Test",
            Role = UserRole.User,
        });
        db.OAuthIdentities.Add(new OAuthIdentity
        {
            UserId = userId,
            Provider = "linkedin",
            ProviderSubject = "bff-test-subject",
        });
        await db.SaveChangesAsync();
    }
}
