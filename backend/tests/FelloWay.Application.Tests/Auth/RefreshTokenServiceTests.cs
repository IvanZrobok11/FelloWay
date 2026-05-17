using FelloWay.Infrastructure.Auth;

namespace FelloWay.Application.Tests.Auth;

public class RefreshTokenServiceTests
{
    private readonly RefreshTokenService _sut = new();

    [Fact]
    public void HashToken_IsDeterministic()
    {
        var hash1 = _sut.HashToken("same-token");
        var hash2 = _sut.HashToken("same-token");
        Assert.Equal(hash1, hash2);
    }

    [Fact]
    public void Verify_ReturnsTrue_ForMatchingToken()
    {
        var plain = _sut.GeneratePlainTextToken();
        var hash = _sut.HashToken(plain);
        Assert.True(_sut.Verify(plain, hash));
    }

    [Fact]
    public void Verify_ReturnsFalse_ForDifferentToken()
    {
        var hash = _sut.HashToken("token-a");
        Assert.False(_sut.Verify("token-b", hash));
    }
}
