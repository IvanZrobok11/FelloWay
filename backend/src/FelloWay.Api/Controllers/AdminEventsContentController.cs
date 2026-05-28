using FelloWay.Application.Admin;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FelloWay.Api.Controllers;

[ApiController]
[Route("admin/events")]
[Authorize(Policy = "AdminContent")]
public class AdminEventsContentController(IAdminEventContentService adminEventContentService) : ControllerBase
{
    [HttpGet("cities")]
    public async Task<ActionResult<object>> ListCities(CancellationToken cancellationToken)
    {
        var items = await adminEventContentService.ListCitiesAsync(cancellationToken);
        return Ok(new { items });
    }

    [HttpGet]
    public async Task<ActionResult<object>> ListEvents(CancellationToken cancellationToken)
    {
        var items = await adminEventContentService.ListEventsAsync(cancellationToken);
        return Ok(new { items });
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<AdminEventDetailDto>> GetEvent(Guid id, CancellationToken cancellationToken) =>
        Ok(await adminEventContentService.GetEventAsync(id, cancellationToken));

    [HttpPost]
    public async Task<ActionResult<object>> CreateEvent(
        [FromBody] AdminEventCreateRequest body,
        CancellationToken cancellationToken)
    {
        var id = await adminEventContentService.CreateEventAsync(body, cancellationToken);
        return CreatedAtAction(nameof(GetEvent), new { id }, new { id });
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> UpdateEvent(
        Guid id,
        [FromBody] AdminEventUpdateRequest body,
        CancellationToken cancellationToken)
    {
        await adminEventContentService.UpdateEventAsync(id, body, cancellationToken);
        return NoContent();
    }

    [HttpPost("{id:guid}/cover")]
    [RequestSizeLimit(10 * 1024 * 1024)]
    public async Task<ActionResult<object>> UploadCover(
        Guid id,
        IFormFile file,
        CancellationToken cancellationToken)
    {
        if (file.Length == 0)
        {
            return BadRequest(new { error = "file is required." });
        }

        await using var stream = file.OpenReadStream();
        var contentType = string.IsNullOrWhiteSpace(file.ContentType)
            ? "application/octet-stream"
            : file.ContentType;
        var url = await adminEventContentService.UploadCoverAsync(id, stream, contentType, cancellationToken);
        return Ok(new { coverImageUrl = url });
    }
}
