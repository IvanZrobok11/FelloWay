namespace FelloWay.Application.Events.Models;

public sealed record EventListPageDto(IReadOnlyList<EventDto> Items, string? NextCursor);

public sealed record EventDto(
    Guid Id,
    string Title,
    DateTimeOffset StartsAt,
    DateTimeOffset EndsAt,
    string City,
    string? VenueName,
    IReadOnlyList<string> ImageUrls,
    IReadOnlyList<string> Tags,
    int? Capacity,
    string? OfficialUrl,
    int AttendeeCount,
    bool IsJoined,
    string AttendStatus,
    double? Latitude,
    double? Longitude,
    string? CoverImageUrl,
    IReadOnlyList<AttendeeDto>? Attendees);

public sealed record AttendeeDto(Guid Id, string DisplayName, string HomeCity);

public sealed record ListEventsRequest(
    string? Cursor,
    string? Query,
    string? City,
    string? Interest,
    int Limit,
    double? SortLatitude,
    double? SortLongitude);
