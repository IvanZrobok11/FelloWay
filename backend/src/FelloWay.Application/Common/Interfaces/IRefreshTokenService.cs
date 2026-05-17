namespace FelloWay.Application.Common.Interfaces;

public interface IRefreshTokenService
{
    string GeneratePlainTextToken();

    string HashToken(string plainTextToken);

    bool Verify(string plainTextToken, string hash);
}
