using System.Net.Http.Json;
using System.Text.Json;

namespace FelloWay.Api.Tests.Auth;

public static class TestAuthExtensions
{
    public static async Task<string> LoginAsync(this HttpClient client, string subject)
    {
        var code = subject switch
        {
            "admin" => "dev-admin",
            _ when subject.StartsWith("dev-", StringComparison.Ordinal) => subject,
            _ => $"dev-{subject}",
        };

        var response = await client.PostAsJsonAsync(
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
