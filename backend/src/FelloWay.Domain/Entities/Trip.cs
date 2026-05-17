using FelloWay.Domain.Common;

namespace FelloWay.Domain.Entities;

public class Trip : EntityBase
{
    public Guid EventId { get; set; }

    public Event? Event { get; set; }

    public Guid CreatorUserId { get; set; }

    public User? Creator { get; set; }

    public string RouteLabel { get; set; } = string.Empty;

    public DateTimeOffset DepartureAt { get; set; }

    public string RoleType { get; set; } = "either";

    public Guid OriginCityId { get; set; }

    public City? OriginCity { get; set; }

    public string? StreamChannelId { get; set; }

    public int MaxMembers { get; set; } = 20;

    public ICollection<TripMember> Members { get; set; } = new List<TripMember>();

    public ICollection<TripJoinRequest> JoinRequests { get; set; } = new List<TripJoinRequest>();
}
