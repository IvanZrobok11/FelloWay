using FelloWay.Application.Common.Interfaces;
using FelloWay.Application.Trips.Models;
using FelloWay.Domain.Common;
using FelloWay.Domain.Entities;
using FelloWay.Domain.Enums;
using FelloWay.Domain.Services;
using Microsoft.EntityFrameworkCore;

namespace FelloWay.Application.Trips;

public class TripService(IApplicationDbContext db, ITripChannelSyncService tripChannelSync) : ITripService
{
    public async Task<IReadOnlyList<TripDto>> ListForEventAsync(
        Guid eventId,
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        await EnsureEventAttendeeAsync(eventId, userId, cancellationToken);

        var trips = await db.Trips
            .AsNoTracking()
            .Include(t => t.OriginCity)
            .Include(t => t.Members)
            .Include(t => t.JoinRequests)
            .Where(t => t.EventId == eventId)
            .OrderBy(t => t.DepartureAt)
            .ToListAsync(cancellationToken);

        return trips.Select(t => MapTrip(t, userId)).ToList();
    }

    public async Task<TripDto> CreateAsync(
        Guid eventId,
        Guid userId,
        CreateTripRequest request,
        CancellationToken cancellationToken = default)
    {
        await EnsureEventAttendeeAsync(eventId, userId, cancellationToken);

        var originCityId = await ResolveOriginCityIdAsync(request, cancellationToken);
        var roleType = NormalizeRoleType(request.RoleType ?? request.TransportRole);
        var maxMembers = TripMembershipService.NormalizeMaxMembers(request.MaxMembers ?? request.Capacity);

        var trip = new Trip
        {
            EventId = eventId,
            CreatorUserId = userId,
            RouteLabel = request.RouteLabel.Trim(),
            DepartureAt = request.DepartureAt,
            RoleType = roleType,
            OriginCityId = originCityId,
            MaxMembers = maxMembers,
        };

        trip.Members.Add(new TripMember
        {
            TripId = trip.Id,
            UserId = userId,
            Status = TripMemberStatus.Active,
            JoinedAt = DateTimeOffset.UtcNow,
        });

        db.Trips.Add(trip);
        await db.SaveChangesAsync(cancellationToken);

        trip.StreamChannelId = await tripChannelSync.CreateTripChannelAsync(trip.Id, eventId, cancellationToken);
        trip.UpdatedAt = DateTimeOffset.UtcNow;
        await db.SaveChangesAsync(cancellationToken);

        return MapTrip(await LoadTripAsync(trip.Id, cancellationToken), userId);
    }

    public async Task RequestJoinAsync(Guid tripId, Guid userId, CancellationToken cancellationToken = default)
    {
        var trip = await LoadTripAsync(tripId, cancellationToken);
        await EnsureEventAttendeeAsync(trip.EventId, userId, cancellationToken);

        if (trip.CreatorUserId == userId)
        {
            throw new DomainException("Trip owner is already a member.");
        }

        if (trip.Members.Any(m => m.UserId == userId && m.Status == TripMemberStatus.Active))
        {
            return;
        }

        var pending = trip.JoinRequests.FirstOrDefault(r =>
            r.RequesterUserId == userId && r.Status == TripJoinRequestStatus.Pending);
        if (pending is not null)
        {
            return;
        }

        var user = await db.Users.FirstAsync(u => u.Id == userId, cancellationToken);
        var requesterCityId = user.HomeCityId
            ?? throw new DomainException("Set your home city before joining a trip.");

        if (TripJoinApprovalPolicy.ShouldAutoApprove(user.HomeCityId, trip.OriginCityId))
        {
            await AddMemberAsync(tripId, userId, cancellationToken);
            return;
        }

        db.TripJoinRequests.Add(new TripJoinRequest
        {
            TripId = tripId,
            RequesterUserId = userId,
            RequesterCityId = requesterCityId,
            Status = TripJoinRequestStatus.Pending,
        });
        await db.SaveChangesAsync(cancellationToken);
    }

    public async Task CancelJoinRequestAsync(Guid tripId, Guid userId, CancellationToken cancellationToken = default)
    {
        var request = await db.TripJoinRequests
            .FirstOrDefaultAsync(
                r => r.TripId == tripId &&
                     r.RequesterUserId == userId &&
                     r.Status == TripJoinRequestStatus.Pending,
                cancellationToken);

        if (request is null)
        {
            return;
        }

        request.Status = TripJoinRequestStatus.Cancelled;
        request.UpdatedAt = DateTimeOffset.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<TripJoinRequestDto>> ListPendingJoinRequestsAsync(
        Guid tripId,
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        var trip = await LoadTripAsync(tripId, cancellationToken);
        if (trip.CreatorUserId != userId)
        {
            throw new DomainException("Only the trip owner can view join requests.");
        }

        return await db.TripJoinRequests
            .AsNoTracking()
            .Include(r => r.Requester)
            .ThenInclude(u => u!.HomeCity)
            .Where(r => r.TripId == tripId && r.Status == TripJoinRequestStatus.Pending)
            .OrderBy(r => r.CreatedAt)
            .Select(r => new TripJoinRequestDto(
                r.Id,
                r.RequesterUserId,
                r.Requester!.DisplayName ?? "Member",
                r.Requester.HomeCity != null ? r.Requester.HomeCity.Name : string.Empty,
                r.Requester.AggregateRating,
                r.Status.ToString().ToLowerInvariant()))
            .ToListAsync(cancellationToken);
    }

    public async Task ApproveJoinAsync(
        Guid tripId,
        Guid ownerUserId,
        Guid requesterUserId,
        CancellationToken cancellationToken = default)
    {
        var trip = await LoadTripAsync(tripId, cancellationToken);
        if (trip.CreatorUserId != ownerUserId)
        {
            throw new DomainException("Only the trip owner can approve join requests.");
        }

        var joinRequest = trip.JoinRequests.FirstOrDefault(r =>
            r.RequesterUserId == requesterUserId && r.Status == TripJoinRequestStatus.Pending);
        if (joinRequest is null)
        {
            throw new NotFoundException("Join request not found.");
        }

        await AddMemberAsync(tripId, requesterUserId, cancellationToken);
        joinRequest.Status = TripJoinRequestStatus.Approved;
        joinRequest.UpdatedAt = DateTimeOffset.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
    }

    public async Task RevokeUserFromEventTripsAsync(
        Guid eventId,
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        var tripIds = await db.Trips
            .Where(t => t.EventId == eventId)
            .Select(t => t.Id)
            .ToListAsync(cancellationToken);

        if (tripIds.Count == 0)
        {
            return;
        }

        var members = await db.TripMembers
            .Where(m => tripIds.Contains(m.TripId) && m.UserId == userId && m.Status == TripMemberStatus.Active)
            .ToListAsync(cancellationToken);

        foreach (var member in members)
        {
            member.Status = TripMemberStatus.Left;
            member.LeftAt = DateTimeOffset.UtcNow;
            await tripChannelSync.RemoveMemberAsync(member.TripId, userId, cancellationToken);
        }

        var pending = await db.TripJoinRequests
            .Where(r => tripIds.Contains(r.TripId) &&
                        r.RequesterUserId == userId &&
                        r.Status == TripJoinRequestStatus.Pending)
            .ToListAsync(cancellationToken);

        foreach (var request in pending)
        {
            request.Status = TripJoinRequestStatus.Cancelled;
            request.UpdatedAt = DateTimeOffset.UtcNow;
        }

        if (members.Count > 0 || pending.Count > 0)
        {
            await db.SaveChangesAsync(cancellationToken);
        }
    }

    private async Task AddMemberAsync(Guid tripId, Guid userId, CancellationToken cancellationToken)
    {
        var trip = await LoadTripAsync(tripId, cancellationToken);
        var activeCount = trip.Members.Count(m => m.Status == TripMemberStatus.Active);
        if (!TripMembershipService.CanAddMember(activeCount, trip.MaxMembers))
        {
            throw new DomainException("Trip is at capacity.");
        }

        var existing = trip.Members.FirstOrDefault(m => m.UserId == userId);
        if (existing is { Status: TripMemberStatus.Active })
        {
            return;
        }

        if (existing is null)
        {
            trip.Members.Add(new TripMember
            {
                TripId = trip.Id,
                UserId = userId,
                Status = TripMemberStatus.Active,
                JoinedAt = DateTimeOffset.UtcNow,
            });
        }
        else
        {
            existing.Status = TripMemberStatus.Active;
            existing.JoinedAt = DateTimeOffset.UtcNow;
            existing.LeftAt = null;
        }

        trip.UpdatedAt = DateTimeOffset.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
        await tripChannelSync.AddMemberAsync(trip.Id, userId, cancellationToken);
    }

    private async Task<Trip> LoadTripAsync(Guid tripId, CancellationToken cancellationToken) =>
        await db.Trips
            .Include(t => t.OriginCity)
            .Include(t => t.Members)
            .Include(t => t.JoinRequests)
            .FirstOrDefaultAsync(t => t.Id == tripId, cancellationToken)
        ?? throw new NotFoundException("Trip not found.");

    private async Task EnsureEventAttendeeAsync(Guid eventId, Guid userId, CancellationToken cancellationToken)
    {
        var joined = await db.EventAttendees.AnyAsync(
            a => a.EventId == eventId && a.UserId == userId && a.Status == AttendanceStatus.Joined,
            cancellationToken);

        if (!joined)
        {
            throw new DomainException("Join the event before accessing trip chats.");
        }
    }

    private async Task<Guid> ResolveOriginCityIdAsync(CreateTripRequest request, CancellationToken cancellationToken)
    {
        if (request.OriginCityId.HasValue)
        {
            var exists = await db.Cities.AnyAsync(c => c.Id == request.OriginCityId.Value, cancellationToken);
            if (!exists)
            {
                throw new DomainException("Unknown origin city.");
            }

            return request.OriginCityId.Value;
        }

        if (string.IsNullOrWhiteSpace(request.TargetCityLabel))
        {
            throw new DomainException("originCityId or targetCityLabel is required.");
        }

        var label = request.TargetCityLabel.Trim().ToLowerInvariant();
        var city = await db.Cities
            .FirstOrDefaultAsync(c => c.Name.ToLower() == label, cancellationToken);

        if (city is null)
        {
            throw new DomainException("Unknown target city.");
        }

        return city.Id;
    }

    private static string NormalizeRoleType(string? raw)
    {
        if (string.IsNullOrWhiteSpace(raw))
        {
            return "either";
        }

        return raw.Trim().ToLowerInvariant() switch
        {
            "driver" => "driver",
            "passenger" => "passenger",
            _ => "either",
        };
    }

    private static TripDto MapTrip(Trip trip, Guid userId)
    {
        var activeCount = trip.Members.Count(m => m.Status == TripMemberStatus.Active);
        var membership = ResolveMembership(trip, userId);

        return new TripDto(
            trip.Id,
            trip.EventId,
            trip.RouteLabel,
            trip.DepartureAt,
            trip.RoleType,
            trip.OriginCity?.Name ?? string.Empty,
            trip.MaxMembers,
            activeCount,
            trip.CreatorUserId,
            membership);
    }

    private static string ResolveMembership(Trip trip, Guid userId)
    {
        if (trip.CreatorUserId == userId)
        {
            return "owner";
        }

        if (trip.Members.Any(m => m.UserId == userId && m.Status == TripMemberStatus.Active))
        {
            return "member";
        }

        if (trip.JoinRequests.Any(r =>
                r.RequesterUserId == userId && r.Status == TripJoinRequestStatus.Pending))
        {
            return "pending";
        }

        return "none";
    }
}
