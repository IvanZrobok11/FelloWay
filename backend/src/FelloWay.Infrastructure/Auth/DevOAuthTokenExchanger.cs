using FelloWay.Application.Common.Interfaces;
using FelloWay.Domain.Common;

namespace FelloWay.Infrastructure.Auth;

/// <summary>
/// Development/test OAuth exchanger. Accepts code <c>dev-{subject}</c> or <c>test-code</c>.
/// </summary>
public class DevOAuthTokenExchanger : IOAuthTokenExchanger
{
    public Task<OAuthUserInfo> ExchangeAsync(
        string provider,
        string code,
        string redirectUri,
        string codeVerifier,
        CancellationToken cancellationToken = default)
    {
        if (provider is not "linkedin" and not "facebook")
        {
            throw new DomainException("Unsupported OAuth provider.");
        }

        var subject = code switch
        {
            "test-code" => "test-user-subject",
            _ when code.StartsWith("dev-", StringComparison.Ordinal) => code["dev-".Length..],
            _ => throw new DomainException("Invalid authorization code for development OAuth."),
        };

        return Task.FromResult(new OAuthUserInfo(subject, $"Dev User {subject}", null));
    }
}
