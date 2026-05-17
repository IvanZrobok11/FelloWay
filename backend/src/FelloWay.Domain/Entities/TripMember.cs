using FelloWay.Domain.Enums;

namespace FelloWay.Domain.Entities;

public class TripMember
{
    public Guid TripId { get; set; }

    public Trip? Trip { get; set; }

    public Guid UserId { get; set; }

    public User? User { get; set; }

    public TripMemberStatus Status { get; set; } = TripMemberStatus.Active;

    public DateTimeOffset? JoinedAt { get; set; }

    public DateTimeOffset? LeftAt { get; set; }
}
