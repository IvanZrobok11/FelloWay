namespace FelloWay.Domain.Entities;

public class EventInterest
{
    public Guid EventId { get; set; }

    public Event? Event { get; set; }

    public Guid InterestId { get; set; }

    public Interest? Interest { get; set; }
}
