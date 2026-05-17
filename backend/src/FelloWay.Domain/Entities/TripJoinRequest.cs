using FelloWay.Domain.Common;
using FelloWay.Domain.Enums;

namespace FelloWay.Domain.Entities;

public class TripJoinRequest : EntityBase
{
    public Guid TripId { get; set; }

    public Trip? Trip { get; set; }

    public Guid RequesterUserId { get; set; }

    public User? Requester { get; set; }

    public TripJoinRequestStatus Status { get; set; } = TripJoinRequestStatus.Pending;

    public Guid RequesterCityId { get; set; }

    public City? RequesterCity { get; set; }
}
