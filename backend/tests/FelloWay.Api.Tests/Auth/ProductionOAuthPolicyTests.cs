namespace FelloWay.Api.Tests.Auth;

public class ProductionOAuthPolicyTests
{
    [Fact]
    public void ProductionSource_DoesNotContainDevOAuthTokenExchanger()
    {
        var repoRoot = Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "..", ".."));
        var infrastructureAuth = Path.Combine(repoRoot, "src", "FelloWay.Infrastructure", "Auth");
        Assert.True(Directory.Exists(infrastructureAuth), $"Expected path: {infrastructureAuth}");

        var csFiles = Directory.GetFiles(infrastructureAuth, "*.cs", SearchOption.TopDirectoryOnly);
        Assert.DoesNotContain(csFiles, f => Path.GetFileName(f) == "DevOAuthTokenExchanger.cs");
        Assert.DoesNotContain(csFiles, f => Path.GetFileName(f) == "CompositeOAuthTokenExchanger.cs");

        var diPath = Path.Combine(repoRoot, "src", "FelloWay.Infrastructure", "DependencyInjection.cs");
        var diText = File.ReadAllText(diPath);
        Assert.DoesNotContain("DevOAuthTokenExchanger", diText, StringComparison.Ordinal);
        Assert.DoesNotContain("CompositeOAuthTokenExchanger", diText, StringComparison.Ordinal);
    }
}
