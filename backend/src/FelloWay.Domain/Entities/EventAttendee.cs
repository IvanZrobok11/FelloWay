using FelloWay.Domain.Enums;

namespace FelloWay.Domain.Entities;

public class EventAttendee
{
    public Guid EventId { get; set; }

    public Event? Event { get; set; }

    public Guid UserId { get; set; }

    public User? User { get; set; }

    public AttendanceStatus Status { get; set; } = AttendanceStatus.Joined;

    public DateTimeOffset? JoinedAt { get; set; }

    public DateTimeOffset? LeftAt { get; set; }
}
