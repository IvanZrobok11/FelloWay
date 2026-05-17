using FelloWay.Application.Common.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FelloWay.Api.Controllers;

[ApiController]
[Authorize]
[Route("chat")]
public class ChatController(
    IStreamChatService streamChatService,
    ICurrentUserService currentUser) : ControllerBase
{
    [HttpGet("stream-token")]
    public async Task<ActionResult<object>> GetStreamToken(CancellationToken cancellationToken)
    {
        if (!currentUser.UserId.HasValue)
        {
            return Unauthorized();
        }

        var token = await streamChatService.CreateUserTokenAsync(currentUser.UserId.Value, cancellationToken);
        return Ok(new { token });
    }
}
