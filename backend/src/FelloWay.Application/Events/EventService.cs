using System.Globalization;
using System.Text;
using FelloWay.Application.Common.Interfaces;
using FelloWay.Application.Events.Models;
using FelloWay.Application.Trips;
using FelloWay.Domain.Common;
using FelloWay.Domain.Entities;
using FelloWay.Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace FelloWay.Application.Events;

public class EventService(
    IApplicationDbContext db,
    IEventChannelSyncService eventChannelSync,
    ITripService tripService) : IEventService
{
    private const int MaxPageSize = 50;
    private const int DefaultPageSize = 20;

    public async Task<EventListPageDto> ListAsync(
        ListEventsRequest request,
        Guid? userId,
        CancellationToken cancellationToken = default)
    {
        var limit = request.Limit <= 0 ? DefaultPageSize : Math.Min(request.Limit, MaxPageSize);
        var query = db.Events
            .AsNoTracking()
            .Include(e => e.City)
            .Include(e => e.EventInterests)
            .ThenInclude(ei => ei.Interest)
            .Where(e => e.Status == EventStatus.Active && e.EndsAt >= DateTimeOffset.UtcNow);

        if (!string.IsNullOrWhiteSpace(request.Query))
        {
            var q = request.Query.Trim().ToLowerInvariant();
            query = query.Where(e =>
                e.Title.ToLower().Contains(q) ||
                (e.Description != null && e.Description.ToLower().Contains(q)));
        }

        if (!string.IsNullOrWhiteSpace(request.City))
        {
            var city = request.City.Trim().ToLowerInvariant();
            query = query.Where(e => e.City != null && e.City.Name.ToLower().Contains(city));
        }

        if (!string.IsNullOrWhiteSpace(request.Interest))
        {
            var tag = request.Interest.Trim().ToLowerInvariant();
            query = query.Where(e =>
                e.EventInterests.Any(ei => ei.Interest != null && ei.Interest.Name.ToLower().Contains(tag)));
        }

        if (TryParseCursor(request.Cursor, out var cursorStartsAt, out var cursorId))
        {
            query = query.Where(e =>
                e.StartsAt > cursorStartsAt ||
                (e.StartsAt == cursorStartsAt && e.Id.CompareTo(cursorId) > 0));
        }

        List<Event> events;
        string? nextCursor = null;

        if (request.SortLatitude.HasValue && request.SortLongitude.HasValue)
        {
            var candidates = await query.ToListAsync(cancellationToken);
            events = GeoSort.OrderByDistance(
                    candidates,
                    request.SortLatitude.Value,
                    request.SortLongitude.Value,
                    e => e.Latitude ?? e.City?.Latitude ?? 0,
                    e => e.Longitude ?? e.City?.Longitude ?? 0)
                .Take(limit)
                .ToList();
        }
        else
        {
            var page = await query
                .OrderBy(e => e.StartsAt)
                .ThenBy(e => e.Id)
                .Take(limit + 1)
                .ToListAsync(cancellationToken);

            if (page.Count > limit)
            {
                var last = page[limit - 1];
                nextCursor = EncodeCursor(last.StartsAt, last.Id);
                events = page.Take(limit).ToList();
            }
            else
            {
                events = page;
            }
        }

        var eventIds = events.Select(e => e.Id).ToList();
        var joinedIds = await GetJoinedEventIdsAsync(userId, eventIds, cancellationToken);
        var attendeeCounts = await GetAttendeeCountsAsync(eventIds, cancellationToken);

        var items = events
            .Select(e => MapSummary(e, joinedIds.Contains(e.Id), attendeeCounts.GetValueOrDefault(e.Id)))
            .ToList();

        return new EventListPageDto(items, nextCursor);
    }

    public async Task<EventDto?> GetByIdAsync(
        Guid eventId,
        Guid? userId,
        CancellationToken cancellationToken = default)
    {
        var entity = await LoadEventAsync(eventId, cancellationToken);
        if (entity is null || entity.Status != EventStatus.Active)
        {
            return null;
        }

        var joined = await IsJoinedAsync(userId, eventId, cancellationToken);
        var count = await CountJoinedAsync(eventId, cancellationToken);
        IReadOnlyList<AttendeeDto>? attendees = null;
        if (joined)
        {
            attendees = await LoadAttendeeDtosAsync(eventId, cancellationToken);
        }

        return MapDetail(entity, joined, count, attendees);
    }

    public async Task AttendAsync(Guid eventId, Guid userId, CancellationToken cancellationToken = default)
    {
        var entity = await db.Events
            .Include(e => e.Attendees)
            .FirstOrDefaultAsync(e => e.Id == eventId, cancellationToken)
            ?? throw new NotFoundException("Event not found.");

        if (entity.Status != EventStatus.Active)
        {
            throw new DomainException("Event is not available.");
        }

        var joinedCount = entity.Attendees.Count(a => a.Status == AttendanceStatus.Joined);
        if (!AttendancePolicy.CanJoinEvent(entity.Status, joinedCount, entity.Capacity))
        {
            throw new DomainException("Event is at capacity.");
        }

        var existing = entity.Attendees.FirstOrDefault(a => a.UserId == userId);
        if (existing is { Status: AttendanceStatus.Joined })
        {
            return;
        }

        if (existing is null)
        {
            entity.Attendees.Add(new EventAttendee
            {
                EventId = eventId,
                UserId = userId,
                Status = AttendanceStatus.Joined,
                JoinedAt = DateTimeOffset.UtcNow,
            });
        }
        else
        {
            existing.Status = AttendanceStatus.Joined;
            existing.JoinedAt = DateTimeOffset.UtcNow;
            existing.LeftAt = null;
        }

        entity.UpdatedAt = DateTimeOffset.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
        await eventChannelSync.AddMemberAsync(eventId, userId, cancellationToken);
    }

    public async Task LeaveAsync(Guid eventId, Guid userId, CancellationToken cancellationToken = default)
    {
        var attendee = await db.Events
            .Where(e => e.Id == eventId)
            .SelectMany(e => e.Attendees)
            .FirstOrDefaultAsync(a => a.UserId == userId, cancellationToken);

        if (attendee is null || attendee.Status != AttendanceStatus.Joined)
        {
            return;
        }

        attendee.Status = AttendanceStatus.Left;
        attendee.LeftAt = DateTimeOffset.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
        await eventChannelSync.RemoveMemberAsync(eventId, userId, cancellationToken);
        await tripService.RevokeUserFromEventTripsAsync(eventId, userId, cancellationToken);
    }

    public async Task<IReadOnlyList<AttendeeDto>> GetAttendeesAsync(
        Guid eventId,
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        if (!await db.Events.AnyAsync(e => e.Id == eventId, cancellationToken))
        {
            throw new NotFoundException("Event not found.");
        }

        var status = await GetAttendanceStatusAsync(userId, eventId, cancellationToken);
        if (!AttendancePolicy.CanViewAttendees(status))
        {
            throw new DomainException("Attendee list is only available to event subscribers.");
        }

        return await LoadAttendeeDtosAsync(eventId, cancellationToken);
    }

    private async Task<Event?> LoadEventAsync(Guid eventId, CancellationToken cancellationToken) =>
        await db.Events
            .AsNoTracking()
            .Include(e => e.City)
            .Include(e => e.EventInterests)
            .ThenInclude(ei => ei.Interest)
            .FirstOrDefaultAsync(e => e.Id == eventId, cancellationToken);

    private async Task<HashSet<Guid>> GetJoinedEventIdsAsync(
        Guid? userId,
        IReadOnlyList<Guid> eventIds,
        CancellationToken cancellationToken)
    {
        if (!userId.HasValue || eventIds.Count == 0)
        {
            return [];
        }

        var ids = await db.EventAttendees
            .Where(a => eventIds.Contains(a.EventId) &&
                        a.UserId == userId.Value &&
                        a.Status == AttendanceStatus.Joined)
            .Select(a => a.EventId)
            .ToListAsync(cancellationToken);

        return ids.ToHashSet();
    }

    private async Task<Dictionary<Guid, int>> GetAttendeeCountsAsync(
        IReadOnlyList<Guid> eventIds,
        CancellationToken cancellationToken)
    {
        if (eventIds.Count == 0)
        {
            return new Dictionary<Guid, int>();
        }

        return await db.EventAttendees
            .Where(a => eventIds.Contains(a.EventId) && a.Status == AttendanceStatus.Joined)
            .GroupBy(a => a.EventId)
            .Select(g => new { EventId = g.Key, Count = g.Count() })
            .ToDictionaryAsync(x => x.EventId, x => x.Count, cancellationToken);
    }

    private async Task<bool> IsJoinedAsync(Guid? userId, Guid eventId, CancellationToken cancellationToken) =>
        await GetAttendanceStatusAsync(userId, eventId, cancellationToken) == AttendanceStatus.Joined;

    private async Task<AttendanceStatus?> GetAttendanceStatusAsync(
        Guid? userId,
        Guid eventId,
        CancellationToken cancellationToken)
    {
        if (!userId.HasValue)
        {
            return null;
        }

        return await db.EventAttendees
            .Where(a => a.EventId == eventId && a.UserId == userId.Value)
            .Select(a => (AttendanceStatus?)a.Status)
            .FirstOrDefaultAsync(cancellationToken);
    }

    private async Task<int> CountJoinedAsync(Guid eventId, CancellationToken cancellationToken) =>
        await db.EventAttendees.CountAsync(
            a => a.EventId == eventId && a.Status == AttendanceStatus.Joined,
            cancellationToken);

    private async Task<IReadOnlyList<AttendeeDto>> LoadAttendeeDtosAsync(
        Guid eventId,
        CancellationToken cancellationToken)
    {
        var userIds = await db.EventAttendees
            .Where(a => a.EventId == eventId && a.Status == AttendanceStatus.Joined)
            .Select(a => a.UserId)
            .ToListAsync(cancellationToken);

        if (userIds.Count == 0)
        {
            return Array.Empty<AttendeeDto>();
        }

        return await db.Users
            .AsNoTracking()
            .Include(u => u.HomeCity)
            .Where(u => userIds.Contains(u.Id))
            .Select(u => new AttendeeDto(
                u.Id,
                u.DisplayName ?? "Member",
                u.HomeCity != null ? u.HomeCity.Name : string.Empty))
            .ToListAsync(cancellationToken);
    }

    private static EventDto MapSummary(Event entity, bool isJoined, int attendeeCount) =>
        MapDetail(entity, isJoined, attendeeCount, null);

    private static EventDto MapDetail(
        Event entity,
        bool isJoined,
        int attendeeCount,
        IReadOnlyList<AttendeeDto>? attendees)
    {
        var tags = entity.EventInterests
            .Where(ei => ei.Interest is not null)
            .Select(ei => ei.Interest!.Name)
            .ToList();

        var imageUrls = string.IsNullOrWhiteSpace(entity.CoverImageUrl)
            ? Array.Empty<string>()
            : new[] { entity.CoverImageUrl };

        return new EventDto(
            entity.Id,
            entity.Title,
            entity.StartsAt,
            entity.EndsAt,
            entity.City?.Name ?? string.Empty,
            entity.Venue,
            imageUrls,
            tags,
            entity.Capacity,
            entity.OfficialUrl,
            attendeeCount,
            isJoined,
            isJoined ? "attending" : "not_attending",
            entity.Latitude ?? entity.City?.Latitude,
            entity.Longitude ?? entity.City?.Longitude,
            entity.CoverImageUrl,
            attendees);
    }

    private static string EncodeCursor(DateTimeOffset startsAt, Guid id) =>
        Convert.ToBase64String(Encoding.UTF8.GetBytes($"{startsAt:O}|{id}"));

    private static bool TryParseCursor(string? cursor, out DateTimeOffset startsAt, out Guid id)
    {
        startsAt = default;
        id = default;
        if (string.IsNullOrWhiteSpace(cursor))
        {
            return false;
        }

        try
        {
            var decoded = Encoding.UTF8.GetString(Convert.FromBase64String(cursor));
            var parts = decoded.Split('|', 2);
            if (parts.Length != 2 ||
                !DateTimeOffset.TryParse(parts[0], CultureInfo.InvariantCulture, DateTimeStyles.RoundtripKind, out startsAt) ||
                !Guid.TryParse(parts[1], out id))
            {
                return false;
            }

            return true;
        }
        catch (FormatException)
        {
            return false;
        }
    }
}
