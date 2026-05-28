namespace FelloWay.Application.Admin;

public sealed record AdminCityDto(Guid Id, string Name, string CountryCode);

public sealed record AdminEventListItemDto(
    Guid Id,
    string Title,
    DateTimeOffset StartsAt,
    DateTimeOffset EndsAt,
    string CityName,
    string Status);

public sealed record AdminEventDetailDto(
    Guid Id,
    string Title,
    string? Description,
    DateTimeOffset StartsAt,
    DateTimeOffset EndsAt,
    Guid CityId,
    string CityName,
    string? Venue,
    string? CoverImageUrl,
    int? Capacity,
    string? OfficialUrl,
    string Status);

public sealed record AdminEventCreateRequest(
    string Title,
    string? Description,
    DateTimeOffset StartsAt,
    DateTimeOffset EndsAt,
    Guid CityId,
    string? Venue,
    int? Capacity,
    string? OfficialUrl);

public sealed record AdminEventUpdateRequest(
    string? Title,
    string? Description,
    DateTimeOffset? StartsAt,
    DateTimeOffset? EndsAt,
    Guid? CityId,
    string? Venue,
    int? Capacity,
    string? OfficialUrl,
    string? Status);
