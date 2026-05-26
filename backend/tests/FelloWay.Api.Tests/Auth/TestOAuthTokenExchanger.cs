using FelloWay.Application.Common.Interfaces;
using FelloWay.Domain.Common;

namespace FelloWay.Api.Tests.Auth;

/// <summary>
/// Test-host-only OAuth exchanger. Accepts <c>dev-{subject}</c> or <c>test-code</c> for CI.
/// Not registered in production Infrastructure.
/// </summary>
public sealed class TestOAuthTokenExchanger : IOAuthTokenExchanger
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

        if (!IsDevCode(code))
        {
            throw new DomainException("Invalid authorization code for test OAuth.");
        }

        var subject = code switch
        {
            "test-code" => "test-user-subject",
            _ => code["dev-".Length..],
        };

        return Task.FromResult(new OAuthUserInfo(subject, $"Dev User {subject}", null));
    }

    private static bool IsDevCode(string code) =>
        code == "test-code" || code.StartsWith("dev-", StringComparison.Ordinal);
}
