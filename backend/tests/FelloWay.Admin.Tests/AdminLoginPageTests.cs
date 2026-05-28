using System.Net;
using Microsoft.AspNetCore.Mvc.Testing;

namespace FelloWay.Admin.Tests;

public class AdminLoginPageTests : IClassFixture<AdminWebApplicationFactory>
{
    private readonly HttpClient _client;

    public AdminLoginPageTests(AdminWebApplicationFactory factory) =>
        _client = factory.CreateClient(new WebApplicationFactoryClientOptions
        {
            AllowAutoRedirect = false,
        });

    [Fact]
    public async Task ValidCredentials_RedirectsToDashboard()
    {
        var response = await _client.PostAsync(
            "/Login",
            new FormUrlEncodedContent(
            [
                new KeyValuePair<string, string>("Input.Username", "test-admin"),
                new KeyValuePair<string, string>("Input.Password", "test-password"),
            ]));

        Assert.Equal(HttpStatusCode.Redirect, response.StatusCode);
        Assert.Equal("/", response.Headers.Location?.OriginalString);
    }

    [Fact]
    public async Task InvalidCredentials_ShowsLoginAgain()
    {
        var response = await _client.PostAsync(
            "/Login",
            new FormUrlEncodedContent(
            [
                new KeyValuePair<string, string>("Input.Username", "test-admin"),
                new KeyValuePair<string, string>("Input.Password", "wrong"),
            ]));

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var html = await response.Content.ReadAsStringAsync();
        Assert.Contains("Invalid username or password", html, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task EventsPage_WithoutAuth_RedirectsToLogin()
    {
        var response = await _client.GetAsync("/Events");
        Assert.Equal(HttpStatusCode.Redirect, response.StatusCode);
        Assert.Contains("/Login", response.Headers.Location?.OriginalString ?? "", StringComparison.OrdinalIgnoreCase);
    }
}
