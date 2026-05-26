namespace FelloWay.Api.Auth;

/// <summary>
/// Builds public request URIs using reverse-proxy forwarded headers.
/// </summary>
internal static class ForwardedPublicUri
{
    public static Uri GetRequestUri(HttpRequest request)
    {
        var scheme = request.Headers["X-Forwarded-Proto"].FirstOrDefault()
            ?? request.Scheme;
        var host = request.Headers["X-Forwarded-Host"].FirstOrDefault()
            ?? request.Host.Value;
        var pathBase = request.PathBase.HasValue ? request.PathBase.Value : string.Empty;
        var path = request.Path.HasValue ? request.Path.Value : string.Empty;
        var query = request.QueryString.HasValue ? request.QueryString.Value : string.Empty;
        return new Uri($"{scheme}://{host}{pathBase}{path}{query}");
    }
}
