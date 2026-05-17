using FelloWay.Domain.Common;
using FelloWay.Domain.Enums;

namespace FelloWay.Domain.Entities;

public class Event : EntityBase
{
    public string Title { get; set; } = string.Empty;

    public string? Description { get; set; }

    public DateTimeOffset StartsAt { get; set; }

    public DateTimeOffset EndsAt { get; set; }

    public Guid CityId { get; set; }

    public City? City { get; set; }

    public string? Venue { get; set; }

    public string? CoverImageUrl { get; set; }

    public EventStatus Status { get; set; } = EventStatus.Active;

    public Guid? CreatedByUserId { get; set; }

    public int? Capacity { get; set; }

    public string? OfficialUrl { get; set; }

    public double? Latitude { get; set; }

    public double? Longitude { get; set; }

    public ICollection<EventAttendee> Attendees { get; set; } = new List<EventAttendee>();

    public ICollection<EventInterest> EventInterests { get; set; } = new List<EventInterest>();
}
