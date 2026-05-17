using FelloWay.Application.Auth;
using FelloWay.Application.Auth.Models;
using FelloWay.Application.Common.Interfaces;
using FluentValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FelloWay.Api.Controllers;

[ApiController]
[Route("auth")]
public class AuthController(
    IAuthService authService,
    ICurrentUserService currentUser,
    IValidator<OAuthTokenRequest> oauthValidator) : ControllerBase
{
    public sealed record OAuthTokenBody(string Code, string RedirectUri, string CodeVerifier);

    public sealed record RefreshTokenBody(string RefreshToken);

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
        return NoContent();
    }
}
