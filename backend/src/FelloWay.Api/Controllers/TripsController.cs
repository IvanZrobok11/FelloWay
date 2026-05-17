using FelloWay.Application.Common.Interfaces;
using FelloWay.Application.Trips;
using FelloWay.Application.Trips.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FelloWay.Api.Controllers;

[ApiController]
[Authorize]
public class TripsController(ITripService tripService, ICurrentUserService currentUser) : ControllerBase
{
    public sealed record CreateTripBody(
        string? RouteLabel,
        DateTimeOffset? DepartureAt,
        string? RoleType,
        string? TransportRole,
        Guid? OriginCityId,
        string? TargetCityLabel,
        int? Capacity,
        int? MaxMembers);

    [HttpGet("/events/{eventId:guid}/trips")]
    public async Task<ActionResult<object>> ListForEvent(Guid eventId, CancellationToken cancellationToken)
    {
        if (!currentUser.UserId.HasValue)
        {
            return Unauthorized();
        }

        var items = await tripService.ListForEventAsync(eventId, currentUser.UserId.Value, cancellationToken);
        return Ok(new { items = items.Select(ToTripJson) });
    }

    [HttpPost("/events/{eventId:guid}/trips")]
    public async Task<ActionResult<object>> Create(
        Guid eventId,
        [FromBody] CreateTripBody body,
        CancellationToken cancellationToken)
    {
        if (!currentUser.UserId.HasValue)
        {
            return Unauthorized();
        }

        if (string.IsNullOrWhiteSpace(body.RouteLabel) || !body.DepartureAt.HasValue)
        {
            return BadRequest(new { message = "routeLabel and departureAt are required." });
        }

        var request = new CreateTripRequest(
            body.RouteLabel,
            body.DepartureAt.Value,
            body.RoleType,
            body.TransportRole,
            body.OriginCityId,
            body.TargetCityLabel,
            body.Capacity,
            body.MaxMembers);

        var trip = await tripService.CreateAsync(eventId, currentUser.UserId.Value, request, cancellationToken);
        return CreatedAtAction(nameof(GetTrip), new { tripId = trip.Id }, ToTripJson(trip));
    }

    [HttpGet("/trips/{tripId:guid}")]
    [ApiExplorerSettings(IgnoreApi = true)]
    public IActionResult GetTrip(Guid tripId) => Ok(new { id = tripId });

    [HttpPost("/trips/{tripId:guid}/join")]
    public async Task<IActionResult> RequestJoin(Guid tripId, CancellationToken cancellationToken)
    {
        if (!currentUser.UserId.HasValue)
        {
            return Unauthorized();
        }

        await tripService.RequestJoinAsync(tripId, currentUser.UserId.Value, cancellationToken);
        return StatusCode(StatusCodes.Status201Created);
    }

    [HttpDelete("/trips/{tripId:guid}/join")]
    public async Task<IActionResult> CancelJoin(Guid tripId, CancellationToken cancellationToken)
    {
        if (!currentUser.UserId.HasValue)
        {
            return Unauthorized();
        }

        await tripService.CancelJoinRequestAsync(tripId, currentUser.UserId.Value, cancellationToken);
        return NoContent();
    }

    [HttpGet("/trips/{tripId:guid}/join-requests")]
    public async Task<ActionResult<object>> ListJoinRequests(Guid tripId, CancellationToken cancellationToken)
    {
        if (!currentUser.UserId.HasValue)
        {
            return Unauthorized();
        }

        var items = await tripService.ListPendingJoinRequestsAsync(
            tripId,
            currentUser.UserId.Value,
            cancellationToken);

        return Ok(new
        {
            items = items.Select(r => new
            {
                id = r.Id,
                userId = r.UserId,
                requesterId = r.UserId,
                displayName = r.DisplayName,
                homeCityLabel = r.HomeCityLabel,
                city = r.HomeCityLabel,
                ratingAverage = r.RatingAverage,
                rating = r.RatingAverage,
                status = r.Status,
            }),
        });
    }

    [HttpPost("/trips/{tripId:guid}/approve/{userId:guid}")]
    public async Task<IActionResult> ApproveJoin(
        Guid tripId,
        Guid userId,
        CancellationToken cancellationToken)
    {
        if (!currentUser.UserId.HasValue)
        {
            return Unauthorized();
        }

        await tripService.ApproveJoinAsync(tripId, currentUser.UserId.Value, userId, cancellationToken);
        return NoContent();
    }

    private static object ToTripJson(TripDto dto) => new
    {
        id = dto.Id,
        eventId = dto.EventId,
        routeLabel = dto.RouteLabel,
        departureAt = dto.DepartureAt,
        roleType = dto.RoleType,
        transportRole = dto.RoleType,
        targetCityLabel = dto.TargetCityLabel,
        city = dto.TargetCityLabel,
        capacity = dto.Capacity,
        maxMembers = dto.Capacity,
        memberCount = dto.MemberCount,
        ownerUserId = dto.OwnerUserId,
        myMembership = dto.MyMembership,
    };
}
