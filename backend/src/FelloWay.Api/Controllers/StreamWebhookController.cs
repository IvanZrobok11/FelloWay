using Microsoft.AspNetCore.Mvc;

namespace FelloWay.Api.Controllers;

/// <summary>
/// Stub endpoint for future GetStream webhook sync (SC-B003).
/// </summary>
[ApiController]
[Route("webhooks/stream")]
public class StreamWebhookController(ILogger<StreamWebhookController> logger) : ControllerBase
{
    [HttpPost]
    public IActionResult Receive()
    {
        logger.LogDebug("Stream webhook received (stub — not processed).");
        return Accepted();
    }
}
