using System.Security.Claims;
using System.Text.Encodings.Web;
using FelloWay.Application.Admin;
using Microsoft.AspNetCore.Authentication;
using Microsoft.Extensions.Options;

namespace FelloWay.Api.Auth;

public sealed class AdminServiceKeyAuthenticationHandler(
    IOptionsMonitor<AuthenticationSchemeOptions> options,
    ILoggerFactory logger,
    UrlEncoder encoder,
    IOptions<AdminAuthOptions> adminAuthOptions)
    : AuthenticationHandler<AuthenticationSchemeOptions>(options, logger, encoder)
{
    public const string SchemeName = "AdminServiceKey";
    public const string HeaderName = "X-Admin-Service-Key";

    protected override Task<AuthenticateResult> HandleAuthenticateAsync()
    {
        var configuredKey = adminAuthOptions.Value.ServiceKey;
        if (string.IsNullOrWhiteSpace(configuredKey))
        {
            return Task.FromResult(AuthenticateResult.Fail("Admin service key is not configured."));
        }

        if (!Request.Headers.TryGetValue(HeaderName, out var provided) || string.IsNullOrWhiteSpace(provided))
        {
            return Task.FromResult(AuthenticateResult.NoResult());
        }

        if (!string.Equals(provided.ToString(), configuredKey, StringComparison.Ordinal))
        {
            return Task.FromResult(AuthenticateResult.Fail("Invalid admin service key."));
        }

        var identity = new ClaimsIdentity(
            [new Claim(ClaimTypes.Name, "admin-service")],
            Scheme.Name);
        var principal = new ClaimsPrincipal(identity);
        var ticket = new AuthenticationTicket(principal, Scheme.Name);
        return Task.FromResult(AuthenticateResult.Success(ticket));
    }
}
