using FelloWay.Application.Common.Interfaces;
using FelloWay.Application.Events;
using FelloWay.Application.Events.Models;
using FelloWay.Application.Users;
using FelloWay.Application.Users.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FelloWay.Api.Controllers;

[ApiController]
[Route("events")]
public class EventsController(
    IEventService eventService,
    IUserTrustService userTrustService,
    ICurrentUserService currentUser) : ControllerBase
{
    [HttpGet]
    [AllowAnonymous]
    public async Task<ActionResult<object>> List(
        [FromQuery] string? cursor,
        [FromQuery] string? q,
        [FromQuery] string? city,
        [FromQuery] string? interest,
        [FromQuery] int limit = 20,
        [FromQuery] double? sortLat = null,
        [FromQuery] double? sortLng = null,
        CancellationToken cancellationToken = default)
    {
        var page = await eventService.ListAsync(
            new ListEventsRequest(cursor, q, city, interest, limit, sortLat, sortLng),
            currentUser.UserId,
            cancellationToken);

        return Ok(new
        {
            items = page.Items.Select(dto => ToEventJson(dto)),
            nextCursor = page.NextCursor,
        });
    }

    [HttpGet("{id:guid}")]
    [AllowAnonymous]
    public async Task<ActionResult<object>> GetById(Guid id, CancellationToken cancellationToken)
    {
        var item = await eventService.GetByIdAsync(id, currentUser.UserId, cancellationToken);
        if (item is null)
        {
            return NotFound();
        }

        return Ok(ToEventJson(item, includeAttendees: item.IsJoined));
    }

    [HttpPost("{id:guid}/attend")]
    [Authorize]
    public async Task<IActionResult> Attend(Guid id, CancellationToken cancellationToken)
    {
        if (!currentUser.UserId.HasValue)
        {
            return Unauthorized();
        }

        await eventService.AttendAsync(id, currentUser.UserId.Value, cancellationToken);
        return NoContent();
    }

    [HttpDelete("{id:guid}/attend")]
    [Authorize]
    public async Task<IActionResult> Leave(Guid id, CancellationToken cancellationToken)
    {
        if (!currentUser.UserId.HasValue)
        {
            return Unauthorized();
        }

        await eventService.LeaveAsync(id, currentUser.UserId.Value, cancellationToken);
        return NoContent();
    }

    [HttpGet("{id:guid}/attendees")]
    [Authorize]
    public async Task<ActionResult<object>> GetAttendees(Guid id, CancellationToken cancellationToken)
    {
        if (!currentUser.UserId.HasValue)
        {
            return Unauthorized();
        }

        var items = await eventService.GetAttendeesAsync(id, currentUser.UserId.Value, cancellationToken);
        return Ok(new
        {
            items = items.Select(a => new
            {
                id = a.Id,
                displayName = a.DisplayName,
                homeCity = a.HomeCity,
                city = a.HomeCity,
            }),
        });
    }

    public sealed record SubmitReviewBody(int Rating, string? Comment);

    [HttpPost("{id:guid}/attendees/{userId:guid}/review")]
    [Authorize]
    public async Task<IActionResult> SubmitReview(
        Guid id,
        Guid userId,
        [FromBody] SubmitReviewBody body,
        CancellationToken cancellationToken)
    {
        if (!currentUser.UserId.HasValue)
        {
            return Unauthorized();
        }

        await userTrustService.SubmitEventReviewAsync(
            currentUser.UserId.Value,
            id,
            userId,
            new SubmitReviewRequest(body.Rating, body.Comment),
            cancellationToken);
        return StatusCode(StatusCodes.Status201Created);
    }

    private static object ToEventJson(EventDto dto, bool includeAttendees = false) =>
        new
        {
            id = dto.Id,
            title = dto.Title,
            startsAt = dto.StartsAt,
            endsAt = dto.EndsAt,
            city = dto.City,
            venueName = dto.VenueName,
            venue = dto.VenueName,
            imageUrls = dto.ImageUrls,
            tags = dto.Tags,
            capacity = dto.Capacity,
            officialUrl = dto.OfficialUrl,
            attendeeCount = dto.AttendeeCount,
            isJoined = dto.IsJoined,
            attendStatus = dto.AttendStatus,
            latitude = dto.Latitude,
            longitude = dto.Longitude,
            coverImageUrl = dto.CoverImageUrl,
            attendeePreview = includeAttendees && dto.Attendees is not null
                ? dto.Attendees.Select(a => new { id = a.Id, displayName = a.DisplayName, city = a.HomeCity })
                : null,
            attendees = includeAttendees && dto.Attendees is not null
                ? dto.Attendees.Select(a => new { id = a.Id, displayName = a.DisplayName, city = a.HomeCity })
                : null,
        };
}
