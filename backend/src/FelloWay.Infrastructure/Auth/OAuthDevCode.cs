namespace FelloWay.Infrastructure.Auth;

public static class OAuthDevCode
{
    public static bool IsDevCode(string code) =>
        code == "test-code" || code.StartsWith("dev-", StringComparison.Ordinal);
}
