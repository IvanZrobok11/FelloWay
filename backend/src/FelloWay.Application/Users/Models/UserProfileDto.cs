using FelloWay.Application.Reference.Models;

namespace FelloWay.Application.Users.Models;

public sealed record UserProfileDto(
    Guid Id,
    string? DisplayName,
    string? Bio,
    string? HomeCity,
    Guid? HomeCityId,
    IReadOnlyList<Guid> InterestIds,
    IReadOnlyList<InterestCatalogItemDto> Interests,
    string? AvatarUrl,
    decimal AggregateRating,
    bool IsProfileComplete);
