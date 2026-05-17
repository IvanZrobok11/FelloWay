using FelloWay.Api.Configuration;

namespace FelloWay.Api.Extensions;

public static class CorsExtensions
{
    public const string PolicyName = "FelloWay";

    private static readonly string[] AllowedMethods =
    [
        "GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS",
    ];

    private static readonly string[] AllowedHeaders =
    [
        "Authorization",
        "Content-Type",
        "Accept",
        "X-Correlation-ID",
    ];

    public static IServiceCollection AddFelloWayCors(
        this IServiceCollection services,
        IConfiguration configuration,
        IHostEnvironment environment)
    {
        var section = configuration.GetSection(CorsOptions.SectionName);
        var corsOptions = section.Get<CorsOptions>() ?? new CorsOptions();
        var allowedOrigins = FilterValidOrigins(corsOptions.AllowedOrigins);

        services.AddCors(options =>
        {
            options.AddPolicy(PolicyName, policy =>
            {
                policy
                    .WithMethods(AllowedMethods)
                    .WithHeaders(AllowedHeaders)
                    .DisallowCredentials();

                if (environment.IsDevelopment())
                {
                    policy.SetIsOriginAllowed(IsLocalDevOrigin);
                }
                else if (allowedOrigins.Length > 0)
                {
                    policy.WithOrigins(allowedOrigins);
                }
                else
                {
                    policy.SetIsOriginAllowed(_ => false);
                }
            });
        });

        return services;
    }

    internal static bool IsLocalDevOrigin(string origin)
    {
        if (!Uri.TryCreate(origin, UriKind.Absolute, out var uri))
        {
            return false;
        }

        return uri.Host is "localhost" or "127.0.0.1";
    }

    internal static string[] FilterValidOrigins(IEnumerable<string>? origins)
    {
        if (origins is null)
        {
            return [];
        }

        return origins
            .Where(o => !string.IsNullOrWhiteSpace(o))
            .Select(o => o.Trim())
            .Where(TryParseOrigin)
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToArray();
    }

    private static bool TryParseOrigin(string value)
    {
        if (!Uri.TryCreate(value, UriKind.Absolute, out var uri))
        {
            return false;
        }

        if (uri.Scheme is not ("http" or "https"))
        {
            return false;
        }

        return string.IsNullOrEmpty(uri.AbsolutePath) || uri.AbsolutePath == "/";
    }
}
