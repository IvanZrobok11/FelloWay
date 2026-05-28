using System.Text;
using AspNet.Security.OAuth.LinkedIn;
using FelloWay.Api.Auth;
using FelloWay.Application.Admin;
using FelloWay.Infrastructure.Auth;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;

namespace FelloWay.Api.Extensions;

public static class AuthExtensions
{
    public static IServiceCollection AddFelloWayAuthentication(
        this IServiceCollection services,
        IConfiguration configuration,
        IHostEnvironment environment)
    {
        services.Configure<AdminAuthOptions>(configuration.GetSection(AdminAuthOptions.SectionName));

        var signingKey = configuration["Jwt:SigningKey"]
            ?? "felloway-dev-signing-key-change-in-production-min-32-chars!!";

        var linkedInClientId = configuration["OAuth:LinkedIn:ClientId"];
        var linkedInClientSecret = configuration["OAuth:LinkedIn:ClientSecret"];
        var linkedInConfigured = !string.IsNullOrWhiteSpace(linkedInClientId)
            && !string.IsNullOrWhiteSpace(linkedInClientSecret);

        // LinkedIn Challenge is only for GET /auth/linkedin/login — never the default for [Authorize] failures.
        var authBuilder = services.AddAuthentication(options =>
        {
            options.DefaultScheme = FelloWayAuthSchemes.Smart;
            options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
        })
        .AddPolicyScheme(FelloWayAuthSchemes.Smart, FelloWayAuthSchemes.Smart, options =>
        {
            options.ForwardDefaultSelector = context =>
            {
                var authorization = context.Request.Headers.Authorization.ToString();
                if (!string.IsNullOrEmpty(authorization)
                    && authorization.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
                {
                    return JwtBearerDefaults.AuthenticationScheme;
                }

                return FelloWayAuthSchemes.WebSession;
            };
        })
        .AddCookie(FelloWayAuthSchemes.WebSession, options =>
        {
            options.Cookie.Name = "felloway.session";
            options.Cookie.HttpOnly = true;
            // AWS dev/test/prod: always Secure (cross-origin web→API cookies need SameSite=None + Secure).
            // Local host only (Development / Testing): allow HTTP for SameAsRequest.
            options.Cookie.SecurePolicy = environment.IsAwsDeployedEnvironment()
                ? CookieSecurePolicy.Always
                : CookieSecurePolicy.SameAsRequest;
            // Dev/test: Flutter web (e.g. :7357) calls API (e.g. :7086) with credentials — needs None, not Lax.
            options.Cookie.SameSite = SameSiteMode.None;
            options.SlidingExpiration = true;
            options.ExpireTimeSpan = TimeSpan.FromHours(8);
        })
        .AddJwtBearer(options =>
        {
            options.TokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidateAudience = true,
                ValidateLifetime = true,
                ValidateIssuerSigningKey = true,
                ValidIssuer = configuration["Jwt:Issuer"] ?? "felloway",
                ValidAudience = configuration["Jwt:Audience"] ?? "felloway-mobile",
                IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(signingKey)),
                ClockSkew = TimeSpan.FromMinutes(1),
            };
        })
        .AddScheme<AuthenticationSchemeOptions, AdminServiceKeyAuthenticationHandler>(
            AdminServiceKeyAuthenticationHandler.SchemeName,
            _ => { });

        if (linkedInConfigured)
        {
            authBuilder.AddLinkedIn(LinkedInAuthenticationDefaults.AuthenticationScheme, options =>
            {
                options.ClientId = linkedInClientId!;
                options.ClientSecret = linkedInClientSecret!;
                options.CallbackPath = "/auth/linkedin/callback";
                options.Scope.Add("openid");
                options.Scope.Add("profile");
                options.Scope.Add("email");
                options.SaveTokens = false;
                options.Events.OnTicketReceived = LinkedInBffAuthHandler.HandleTicketReceived;
                options.Events.OnRemoteFailure = context =>
                {
                    var returnUrl = context.Properties?.Items.TryGetValue(
                        LinkedInBffAuthHandler.ReturnUrlKey,
                        out var url) == true
                        ? url
                        : configuration["Frontend:BaseUrl"] ?? "https://localhost:7357";
                    var platform = context.Properties?.Items.TryGetValue(
                        LinkedInBffAuthHandler.PlatformKey,
                        out var p) == true
                        ? p
                        : LinkedInBffAuthHandler.PlatformWeb;

                    var error = context.Failure?.Message ?? "remote_failure";
                    if (string.Equals(platform, LinkedInBffAuthHandler.PlatformMobile, StringComparison.OrdinalIgnoreCase))
                    {
                        context.Response.Redirect(
                            $"{FelloWayAuthSchemes.MobileCallbackScheme}://auth{FelloWayAuthSchemes.MobileCallbackPath}?error={Uri.EscapeDataString(error)}");
                    }
                    else
                    {
                        context.Response.Redirect(
                            $"{returnUrl.TrimEnd('/')}/sign-in?error={Uri.EscapeDataString(error)}");
                    }

                    context.HandleResponse();
                    return Task.CompletedTask;
                };
            });
        }

        services.AddAuthorization(options =>
        {
            options.AddPolicy("AdminOnly", policy => policy.RequireRole("admin"));
            options.AddPolicy(
                "AdminContent",
                policy => policy
                    .AddAuthenticationSchemes(AdminServiceKeyAuthenticationHandler.SchemeName)
                    .RequireAuthenticatedUser());
        });

        return services;
    }
}
