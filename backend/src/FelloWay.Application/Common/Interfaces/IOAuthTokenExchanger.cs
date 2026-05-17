namespace FelloWay.Application.Common.Interfaces;

public sealed record OAuthUserInfo(string ProviderSubject, string? DisplayName, string? Email);

public interface IOAuthTokenExchanger
{
    Task<OAuthUserInfo> ExchangeAsync(
        string provider,
        string code,
        string redirectUri,
        string codeVerifier,
        CancellationToken cancellationToken = default);
}
