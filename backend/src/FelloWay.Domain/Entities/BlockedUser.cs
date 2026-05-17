namespace FelloWay.Domain.Entities;

public class BlockedUser
{
    public Guid BlockerUserId { get; set; }

    public User? Blocker { get; set; }

    public Guid BlockedUserId { get; set; }

    public User? Blocked { get; set; }

    public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
}
