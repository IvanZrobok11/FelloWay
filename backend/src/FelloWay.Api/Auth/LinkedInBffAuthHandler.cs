using System.Globalization;
using System.Security.Claims;
using AspNet.Security.OAuth.LinkedIn;
using FelloWay.Api.Options;
using FelloWay.Application.Auth;
using FelloWay.Application.Common.Interfaces;
using FelloWay.Infrastructure.Auth;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.WebUtilities;
using Microsoft.Extensions.Options;

namespace FelloWay.Api.Auth;

public static class LinkedInBffAuthHandler
{
    public const string PlatformKey = "platform";
    public const string ReturnUrlKey = "returnUrl";
    public const string PlatformMobile = "mobile";
    public const string PlatformWeb = "web";

    public static Task HandleTicketReceived(TicketReceivedContext context)
    {
        return HandleTicketReceivedAsync(context);
    }

    private static async Task HandleTicketReceivedAsync(TicketReceivedContext context)
    {
        var authService = context.HttpContext.RequestServices.GetRequiredService<IAuthService>();
        var ticketStore = context.HttpContext.RequestServices.GetRequiredService<IMobileAuthTicketStore>();
        var frontendOptions = context.HttpContext.RequestServices
            .GetRequiredService<IOptions<FrontendOptions>>().Value;

        var platform = context.Properties?.Items.TryGetValue(PlatformKey, out var p) == true
            ? p
            : PlatformWeb;
        var returnUrl = context.Properties?.Items.TryGetValue(ReturnUrlKey, out var r) == true
            ? r
            : frontendOptions.BaseUrl.TrimEnd('/');

        var principal = context.Principal;
        if (principal is null)
        {
            await RedirectWithErrorAsync(context, platform, returnUrl, "missing_principal");
            return;
        }

        var subject = principal.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? principal.FindFirstValue("sub");
        if (string.IsNullOrWhiteSpace(subject))
        {
            await RedirectWithErrorAsync(context, platform, returnUrl, "missing_subject");
            return;
        }

        var displayName = principal.FindFirstValue(ClaimTypes.Name)
            ?? principal.FindFirstValue("name");
        var email = principal.FindFirstValue(ClaimTypes.Email)
            ?? principal.FindFirstValue("email");

        try
        {
            var userInfo = new OAuthUserInfo(subject, displayName, email);
            var tokenResponse = await authService.SignInFromProviderAsync(
                "linkedin",
                userInfo,
                context.HttpContext.RequestAborted);

            if (string.Equals(platform, PlatformMobile, StringComparison.OrdinalIgnoreCase))
            {
                var ticket = ticketStore.Create(tokenResponse.UserId);
                var mobileUri = QueryHelpers.AddQueryString(
                    $"{FelloWayAuthSchemes.MobileCallbackScheme}://auth{FelloWayAuthSchemes.MobileCallbackPath}",
                    "ticket",
                    ticket);
                context.Response.Redirect(mobileUri);
                context.HandleResponse();
                return;
            }

            var sessionPrincipal = new ClaimsPrincipal(
                new ClaimsIdentity(
                    new[]
                    {
                        new Claim(ClaimTypes.NameIdentifier, tokenResponse.UserId.ToString()),
                    },
                    CookieAuthenticationDefaults.AuthenticationScheme));

            await context.HttpContext.SignInAsync(
                FelloWayAuthSchemes.WebSession,
                sessionPrincipal,
                new AuthenticationProperties
                {
                    IsPersistent = true,
                    ExpiresUtc = DateTimeOffset.UtcNow.AddHours(8),
                });

            // Cross-origin web (separate CloudFront hosts) cannot rely on credentialed XHR with
            // the API cookie; hand off a one-time ticket like mobile (POST .../mobile/complete).
            var handoffTicket = ticketStore.Create(tokenResponse.UserId);
            var successUri = QueryHelpers.AddQueryString(
                $"{returnUrl.TrimEnd('/')}/auth/success",
                "ticket",
                handoffTicket);
            context.Response.Redirect(successUri);
            context.HandleResponse();
        }
        catch (Exception)
        {
            await RedirectWithErrorAsync(context, platform, returnUrl, "sign_in_failed");
        }
    }

    private static Task RedirectWithErrorAsync(
        TicketReceivedContext context,
        string platform,
        string returnUrl,
        string error)
    {
        if (string.Equals(platform, PlatformMobile, StringComparison.OrdinalIgnoreCase))
        {
            var mobileUri = QueryHelpers.AddQueryString(
                $"{FelloWayAuthSchemes.MobileCallbackScheme}://auth{FelloWayAuthSchemes.MobileCallbackPath}",
                "error",
                error);
            context.Response.Redirect(mobileUri);
        }
        else
        {
            var webUri = QueryHelpers.AddQueryString(
                $"{returnUrl.TrimEnd('/')}/sign-in",
                "error",
                error);
            context.Response.Redirect(webUri);
        }

        context.HandleResponse();
        return Task.CompletedTask;
    }
}
