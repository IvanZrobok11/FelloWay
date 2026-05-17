using FelloWay.Application.Auth.Models;

namespace FelloWay.Application.Auth;

public interface IAuthService
{
    Task<TokenResponseDto> ExchangeOAuthCodeAsync(OAuthTokenRequest request, CancellationToken cancellationToken = default);

    Task<TokenResponseDto> RefreshAsync(string refreshToken, CancellationToken cancellationToken = default);

    Task RevokeRefreshTokenAsync(string? refreshToken, Guid userId, CancellationToken cancellationToken = default);
}
