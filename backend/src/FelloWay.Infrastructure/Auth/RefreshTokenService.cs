using System.Security.Cryptography;
using System.Text;
using FelloWay.Application.Common.Interfaces;

namespace FelloWay.Infrastructure.Auth;

public class RefreshTokenService : IRefreshTokenService
{
    public string GeneratePlainTextToken()
    {
        var bytes = RandomNumberGenerator.GetBytes(64);
        return Convert.ToBase64String(bytes);
    }

    public string HashToken(string plainTextToken)
    {
        var hash = SHA256.HashData(Encoding.UTF8.GetBytes(plainTextToken));
        return Convert.ToHexString(hash);
    }

    public bool Verify(string plainTextToken, string hash) =>
        HashToken(plainTextToken).Equals(hash, StringComparison.OrdinalIgnoreCase);
}
