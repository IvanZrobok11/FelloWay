namespace FelloWay.Application.Trips.Models;

public sealed record TripDto(
    Guid Id,
    Guid EventId,
    string RouteLabel,
    DateTimeOffset DepartureAt,
    string RoleType,
    string TargetCityLabel,
    int Capacity,
    int MemberCount,
    Guid OwnerUserId,
    string MyMembership);

public sealed record TripJoinRequestDto(
    Guid Id,
    Guid UserId,
    string DisplayName,
    string HomeCityLabel,
    decimal RatingAverage,
    string Status);

public sealed record CreateTripRequest(
    string RouteLabel,
    DateTimeOffset DepartureAt,
    string? RoleType,
    string? TransportRole,
    Guid? OriginCityId,
    string? TargetCityLabel,
    int? Capacity,
    int? MaxMembers);
