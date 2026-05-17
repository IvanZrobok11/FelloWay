namespace FelloWay.Application.Users.Models;

public sealed record UserProfileDto(
    Guid Id,
    string? DisplayName,
    string? Bio,
    string? HomeCity,
    Guid? HomeCityId,
    IReadOnlyList<Guid> InterestIds,
    string? AvatarUrl,
    decimal AggregateRating,
    bool IsProfileComplete);
