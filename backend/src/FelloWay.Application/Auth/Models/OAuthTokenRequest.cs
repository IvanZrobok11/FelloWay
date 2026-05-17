namespace FelloWay.Application.Auth.Models;

public sealed record OAuthTokenRequest(
    string Provider,
    string Code,
    string RedirectUri,
    string CodeVerifier);
