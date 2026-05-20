using System.Security.Claims;
using AspNet.Security.OAuth.LinkedIn;
using FelloWay.Application.Auth;
using FelloWay.Application.Auth.Models;
using FelloWay.Application.Common.Interfaces;
using FelloWay.Api.Auth;
using FelloWay.Api.Options;
using FelloWay.Domain.Common;
using FelloWay.Infrastructure.Auth;
using FluentValidation;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Options;

namespace FelloWay.Api.Controllers;

[ApiController]
[Route("auth")]
public class AuthController(
    IAuthService authService,
    ICurrentUserService currentUser,
    IValidator<OAuthTokenRequest> oauthValidator,
    IOptions<FrontendOptions> frontendOptions,
    IOptions<OAuthOptions> oauthOptions,
    IMobileAuthTicketStore mobileAuthTicketStore) : ControllerBase
{
    public sealed record OAuthTokenBody(string Code, string RedirectUri, string CodeVerifier);

    public sealed record RefreshTokenBody(string RefreshToken);

    public sealed record MobileCompleteBody(string Ticket);

    public sealed record TestingWebSessionBody(Guid UserId);

    /// <summary>
    /// Starts LinkedIn BFF sign-in. Web: sets cookie on callback. Mobile: returns ticket on custom scheme.
    /// </summary>
    [HttpGet("linkedin/login")]
    [AllowAnonymous]
    public IActionResult LinkedInLogin(
        [FromQuery] string? returnUrl,
        [FromQuery] string platform = LinkedInBffAuthHandler.PlatformWeb)
    {
        if (!oauthOptions.Value.LinkedIn.IsConfigured)
        {
            return Problem(
                title: "LinkedIn OAuth is not configured",
                statusCode: StatusCodes.Status503ServiceUnavailable);
        }

        var frontendBase = frontendOptions.Value.BaseUrl.TrimEnd('/');
        var resolvedReturnUrl = string.IsNullOrWhiteSpace(returnUrl)
            ? frontendBase
            : returnUrl.TrimEnd('/');

        var props = new AuthenticationProperties
        {
            RedirectUri = "/auth/linkedin/callback",
        };
        props.Items[LinkedInBffAuthHandler.PlatformKey] = platform;
        props.Items[LinkedInBffAuthHandler.ReturnUrlKey] = resolvedReturnUrl;

        return Challenge(props, LinkedInAuthenticationDefaults.AuthenticationScheme);
    }

    [HttpPost("linkedin/mobile/complete")]
    [AllowAnonymous]
    public async Task<ActionResult<TokenResponseDto>> CompleteLinkedInMobile(
        [FromBody] MobileCompleteBody body,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(body.Ticket))
        {
            return BadRequest(new { error = "ticket_required" });
        }

        var userId = mobileAuthTicketStore.Consume(body.Ticket);
        if (userId is null)
        {
            return BadRequest(new { error = "invalid_or_expired_ticket" });
        }

        try
        {
            var tokens = await authService.IssueTokensForUserAsync(userId.Value, cancellationToken);
            return Ok(tokens);
        }
        catch (DomainException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    /// <summary>
    /// Testing only: establish web session cookie without LinkedIn (environment must be Testing).
    /// </summary>
    [HttpPost("testing/web-session")]
    [AllowAnonymous]
    public async Task<IActionResult> TestingWebSession(
        [FromBody] TestingWebSessionBody body,
        IHostEnvironment environment)
    {
        if (!environment.IsEnvironment("Testing"))
        {
            return NotFound();
        }

        if (body.UserId == Guid.Empty)
        {
            return BadRequest(new { error = "user_id_required" });
        }

        var principal = new ClaimsPrincipal(
            new ClaimsIdentity(
                new[] { new Claim(ClaimTypes.NameIdentifier, body.UserId.ToString()) },
                CookieAuthenticationDefaults.AuthenticationScheme));

        await HttpContext.SignInAsync(
            FelloWayAuthSchemes.WebSession,
            principal,
            new AuthenticationProperties
            {
                IsPersistent = true,
                ExpiresUtc = DateTimeOffset.UtcNow.AddHours(8),
            });

        return Ok();
    }

    [HttpGet("session")]
    [Authorize]
    public IActionResult Session()
    {
        if (!currentUser.UserId.HasValue)
        {
            return Unauthorized();
        }

        return Ok(new { userId = currentUser.UserId.Value });
    }

    [HttpPost("oauth/{provider}/token")]
    [AllowAnonymous]
    public async Task<ActionResult<TokenResponseDto>> ExchangeOAuthToken(
        string provider,
        [FromBody] OAuthTokenBody body,
        CancellationToken cancellationToken)
    {
        var request = new OAuthTokenRequest(provider, body.Code, body.RedirectUri, body.CodeVerifier);
        await oauthValidator.ValidateAndThrowAsync(request, cancellationToken);
        var result = await authService.ExchangeOAuthCodeAsync(request, cancellationToken);
        return Ok(result);
    }

    [HttpPost("refresh")]
    [AllowAnonymous]
    public async Task<ActionResult<TokenResponseDto>> Refresh(
        [FromBody] RefreshTokenBody body,
        CancellationToken cancellationToken)
    {
        var result = await authService.RefreshAsync(body.RefreshToken, cancellationToken);
        return Ok(result);
    }

    [HttpPost("logout")]
    [Authorize]
    public async Task<IActionResult> Logout(
        [FromBody] RefreshTokenBody? body,
        CancellationToken cancellationToken)
    {
        if (!currentUser.UserId.HasValue)
        {
            return Unauthorized();
        }

        await authService.RevokeRefreshTokenAsync(body?.RefreshToken, currentUser.UserId.Value, cancellationToken);
        await HttpContext.SignOutAsync(FelloWayAuthSchemes.WebSession);
        return NoContent();
    }

}
