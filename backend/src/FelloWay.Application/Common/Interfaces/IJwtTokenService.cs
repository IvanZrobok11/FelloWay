using FelloWay.Domain.Enums;

namespace FelloWay.Application.Common.Interfaces;

public interface IJwtTokenService
{
    string CreateAccessToken(Guid userId, UserRole role, out int expiresInSeconds);
}
