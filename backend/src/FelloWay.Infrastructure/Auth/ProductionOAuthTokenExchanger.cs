using FelloWay.Application.Common.Interfaces;
using FelloWay.Domain.Common;
using Microsoft.Extensions.Options;

namespace FelloWay.Infrastructure.Auth;

/// <summary>
/// Production OAuth token exchange: rejects development codes; LinkedIn uses BFF when configured.
/// </summary>
public sealed class ProductionOAuthTokenExchanger(IOptions<OAuthOptions> options) : IOAuthTokenExchanger
{
    public Task<OAuthUserInfo> ExchangeAsync(
        string provider,
        string code,
        string redirectUri,
        string codeVerifier,
        CancellationToken cancellationToken = default)
    {
        var normalized = provider.ToLowerInvariant();
        if (normalized is not "linkedin" and not "facebook")
        {
            throw new DomainException("Unsupported OAuth provider.");
        }

        if (IsDevCode(code))
        {
            throw new DomainException("Development authorization codes are not supported.");
        }

        if (normalized == "facebook")
        {
            throw new DomainException("Facebook sign-in is not configured.");
        }

        if (options.Value.LinkedIn.IsConfigured)
        {
            throw new DomainException(
                "LinkedIn sign-in uses the BFF flow. Open GET /auth/linkedin/login instead of posting an authorization code.");
        }

        throw new DomainException("LinkedIn OAuth is not configured.");
    }

    private static bool IsDevCode(string code) =>
        code == "test-code" || code.StartsWith("dev-", StringComparison.Ordinal);
}
