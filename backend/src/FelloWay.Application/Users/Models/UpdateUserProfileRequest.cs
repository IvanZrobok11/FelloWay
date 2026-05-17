namespace FelloWay.Application.Users.Models;

public sealed record UpdateUserProfileRequest(
    string? DisplayName,
    string? Bio,
    Guid? HomeCityId,
    IReadOnlyList<Guid>? InterestIds);
