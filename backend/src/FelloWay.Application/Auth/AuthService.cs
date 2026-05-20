using FelloWay.Application.Auth.Models;
using FelloWay.Application.Common.Interfaces;
using FelloWay.Domain.Common;
using FelloWay.Domain.Entities;
using FelloWay.Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace FelloWay.Application.Auth;

public class AuthService(
    IApplicationDbContext db,
    IOAuthTokenExchanger oauthExchanger,
    IJwtTokenService jwtTokenService,
    IRefreshTokenService refreshTokenService,
    IStreamChatService streamChatService) : IAuthService
{
    public async Task<TokenResponseDto> ExchangeOAuthCodeAsync(
        OAuthTokenRequest request,
        CancellationToken cancellationToken = default)
    {
        var provider = request.Provider.ToLowerInvariant();
        if (provider is not "linkedin" and not "facebook")
        {
            throw new DomainException("Unsupported OAuth provider.");
        }

        var userInfo = await oauthExchanger.ExchangeAsync(
            provider,
            request.Code,
            request.RedirectUri,
            request.CodeVerifier,
            cancellationToken);

        return await SignInFromProviderAsync(provider, userInfo, cancellationToken);
    }

    public async Task<TokenResponseDto> SignInFromProviderAsync(
        string provider,
        OAuthUserInfo userInfo,
        CancellationToken cancellationToken = default)
    {
        var normalized = provider.ToLowerInvariant();
        if (normalized is not "linkedin" and not "facebook")
        {
            throw new DomainException("Unsupported OAuth provider.");
        }

        var user = await UpsertUserFromOAuthAsync(normalized, userInfo, cancellationToken);
        return await IssueTokensAsync(user.Id, cancellationToken);
    }

    public Task<TokenResponseDto> IssueTokensForUserAsync(
        Guid userId,
        CancellationToken cancellationToken = default) =>
        IssueTokensAsync(userId, cancellationToken);

    public async Task<TokenResponseDto> RefreshAsync(string refreshToken, CancellationToken cancellationToken = default)
    {
        var hash = refreshTokenService.HashToken(refreshToken);
        var stored = await db.RefreshTokens
            .FirstOrDefaultAsync(x => x.TokenHash == hash, cancellationToken)
            ?? throw new DomainException("Invalid refresh token.");

        if (!stored.IsActive)
        {
            throw new DomainException("Refresh token revoked or expired.");
        }

        stored.RevokedAt = DateTimeOffset.UtcNow;
        return await IssueTokensAsync(stored.UserId, cancellationToken);
    }

    public async Task RevokeRefreshTokenAsync(string? refreshToken, Guid userId, CancellationToken cancellationToken = default)
    {
        if (!string.IsNullOrWhiteSpace(refreshToken))
        {
            var hash = refreshTokenService.HashToken(refreshToken);
            var stored = await db.RefreshTokens
                .FirstOrDefaultAsync(x => x.TokenHash == hash && x.UserId == userId, cancellationToken);
            if (stored is not null)
            {
                stored.RevokedAt = DateTimeOffset.UtcNow;
            }
        }

        await db.SaveChangesAsync(cancellationToken);
    }

    private async Task<User> UpsertUserFromOAuthAsync(
        string provider,
        OAuthUserInfo userInfo,
        CancellationToken cancellationToken)
    {
        var identity = await db.OAuthIdentities
            .Include(x => x.User)
            .FirstOrDefaultAsync(
                x => x.Provider == provider && x.ProviderSubject == userInfo.ProviderSubject,
                cancellationToken);

        User user;
        if (identity is null)
        {
            user = new User
            {
                DisplayName = userInfo.DisplayName,
                Email = NormalizeEmail(userInfo.Email),
                Role = IsAdminSubject(userInfo.ProviderSubject) ? UserRole.Admin : UserRole.User,
            };
            db.Users.Add(user);
            db.OAuthIdentities.Add(new OAuthIdentity
            {
                User = user,
                Provider = provider,
                ProviderSubject = userInfo.ProviderSubject,
            });
        }
        else
        {
            user = identity.User;
            if (IsAdminSubject(userInfo.ProviderSubject))
            {
                user.Role = UserRole.Admin;
            }

            if (string.IsNullOrWhiteSpace(user.DisplayName) && !string.IsNullOrWhiteSpace(userInfo.DisplayName))
            {
                user.DisplayName = userInfo.DisplayName;
                user.UpdatedAt = DateTimeOffset.UtcNow;
            }

            if (string.IsNullOrWhiteSpace(user.Email) && !string.IsNullOrWhiteSpace(userInfo.Email))
            {
                user.Email = NormalizeEmail(userInfo.Email);
                user.UpdatedAt = DateTimeOffset.UtcNow;
            }
        }

        await db.SaveChangesAsync(cancellationToken);
        await streamChatService.EnsureUserAsync(user.Id, user.DisplayName, cancellationToken);
        return user;
    }

    private static bool IsAdminSubject(string subject) =>
        subject.Equals("admin", StringComparison.OrdinalIgnoreCase);

    private static string? NormalizeEmail(string? email)
    {
        if (string.IsNullOrWhiteSpace(email))
        {
            return null;
        }

        return email.Trim().ToLowerInvariant();
    }

    private async Task<TokenResponseDto> IssueTokensAsync(Guid userId, CancellationToken cancellationToken)
    {
        var user = await db.Users.FirstAsync(u => u.Id == userId, cancellationToken);
        if (user.BannedAt.HasValue)
        {
            throw new DomainException("Account suspended.");
        }

        var accessToken = jwtTokenService.CreateAccessToken(userId, user.Role, out var expiresIn);
        var plainRefresh = refreshTokenService.GeneratePlainTextToken();
        db.RefreshTokens.Add(new RefreshToken
        {
            UserId = userId,
            TokenHash = refreshTokenService.HashToken(plainRefresh),
            ExpiresAt = DateTimeOffset.UtcNow.AddDays(30),
        });
        await db.SaveChangesAsync(cancellationToken);
        return new TokenResponseDto(accessToken, expiresIn, plainRefresh, userId);
    }
}
