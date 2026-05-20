using FelloWay.Application.Auth.Models;
using FelloWay.Application.Common.Interfaces;

namespace FelloWay.Application.Auth;

public interface IAuthService
{
    Task<TokenResponseDto> ExchangeOAuthCodeAsync(OAuthTokenRequest request, CancellationToken cancellationToken = default);

    Task<TokenResponseDto> SignInFromProviderAsync(
        string provider,
        OAuthUserInfo userInfo,
        CancellationToken cancellationToken = default);

    Task<TokenResponseDto> IssueTokensForUserAsync(
        Guid userId,
        CancellationToken cancellationToken = default);

    Task<TokenResponseDto> RefreshAsync(string refreshToken, CancellationToken cancellationToken = default);

    Task RevokeRefreshTokenAsync(string? refreshToken, Guid userId, CancellationToken cancellationToken = default);
}
