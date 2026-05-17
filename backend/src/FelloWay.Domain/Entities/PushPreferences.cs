namespace FelloWay.Domain.Entities;

public class PushPreferences
{
    public Guid UserId { get; set; }

    public User? User { get; set; }

    public bool GlobalEnabled { get; set; } = true;

    public bool EventMessages { get; set; } = true;

    public bool TripMessages { get; set; } = true;

    public bool DirectMessages { get; set; } = true;

    public DateTimeOffset UpdatedAt { get; set; } = DateTimeOffset.UtcNow;
}
