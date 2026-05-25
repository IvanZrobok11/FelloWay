using System.Net;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Mvc.Testing;

namespace FelloWay.Api.Tests.Infrastructure;

public static class WebSessionTestClient
{
    public static HttpClient CreateWithCookies(WebApplicationFactory<Program> factory)
    {
        return factory.CreateClient(new WebApplicationFactoryClientOptions
        {
            HandleCookies = true,
            AllowAutoRedirect = false,
        });
    }

    public static async Task SignInWebSessionAsync(
        HttpClient client,
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        var response = await client.PostAsJsonAsync(
            "/auth/testing/web-session",
            new { userId },
            cancellationToken);
        if (response.StatusCode != HttpStatusCode.OK)
        {
            var body = await response.Content.ReadAsStringAsync(cancellationToken);
            throw new InvalidOperationException(
                $"Failed to sign in test web session: {(int)response.StatusCode} {body}");
        }
    }
}
