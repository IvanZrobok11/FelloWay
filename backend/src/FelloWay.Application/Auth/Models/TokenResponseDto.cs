namespace FelloWay.Application.Auth.Models;

public sealed record TokenResponseDto(
    string AccessToken,
    int ExpiresIn,
    string RefreshToken,
    Guid UserId);
