using FelloWay.Domain.Common;
using FelloWay.Domain.Enums;

namespace FelloWay.Domain.Entities;

public class User : EntityBase
{
    public string? DisplayName { get; set; }

    public string? Bio { get; set; }

    public Guid? HomeCityId { get; set; }

    public City? HomeCity { get; set; }

    public string? AvatarUrl { get; set; }

    public decimal AggregateRating { get; set; }

    public UserRole Role { get; set; } = UserRole.User;

    public DateTimeOffset? BannedAt { get; set; }

    public ICollection<UserInterest> UserInterests { get; set; } = new List<UserInterest>();

    public ICollection<OAuthIdentity> OAuthIdentities { get; set; } = new List<OAuthIdentity>();

    public ICollection<RefreshToken> RefreshTokens { get; set; } = new List<RefreshToken>();

    public bool IsProfileComplete =>
        !string.IsNullOrWhiteSpace(DisplayName) && HomeCityId.HasValue;
}
