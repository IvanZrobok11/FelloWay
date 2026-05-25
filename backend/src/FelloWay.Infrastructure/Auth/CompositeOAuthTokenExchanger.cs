using FelloWay.Application.Common.Interfaces;
using FelloWay.Domain.Common;
using Microsoft.Extensions.Options;

namespace FelloWay.Infrastructure.Auth;

public sealed class CompositeOAuthTokenExchanger(
    DevOAuthTokenExchanger dev,
    IOptions<OAuthOptions> options) : IOAuthTokenExchanger
{
    public async Task<OAuthUserInfo> ExchangeAsync(
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

        if (normalized == "facebook")
        {
            return await dev.ExchangeAsync(normalized, code, redirectUri, codeVerifier, cancellationToken);
        }

        if (options.Value.LinkedIn.IsConfigured)
        {
            if (OAuthDevCode.IsDevCode(code))
            {
                return await dev.ExchangeAsync(normalized, code, redirectUri, codeVerifier, cancellationToken);
            }

            throw new DomainException(
                "LinkedIn sign-in uses the BFF flow. Open GET /auth/linkedin/login instead of posting an authorization code.");
        }

        return await dev.ExchangeAsync(normalized, code, redirectUri, codeVerifier, cancellationToken);
    }
}
