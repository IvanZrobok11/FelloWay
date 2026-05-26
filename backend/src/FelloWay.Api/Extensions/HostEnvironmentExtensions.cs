namespace FelloWay.Api.Extensions;

public static class HostEnvironmentExtensions
{
    /// <summary>
    /// Local Development or AWS <c>dev</c> (ASPNETCORE_ENVIRONMENT=dev).
    /// </summary>
    public static bool IsDevLike(this IHostEnvironment environment) =>
        environment.IsDevelopment() || environment.IsEnvironment("dev");

    /// <summary>
    /// Production or AWS <c>prod</c> (ASPNETCORE_ENVIRONMENT=prod).
    /// </summary>
    public static bool IsProdLike(this IHostEnvironment environment) =>
        environment.IsProduction() || environment.IsEnvironment("prod");
}
