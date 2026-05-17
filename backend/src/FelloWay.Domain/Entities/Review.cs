using FelloWay.Domain.Common;

namespace FelloWay.Domain.Entities;

public class Review : EntityBase
{
    public Guid SubjectUserId { get; set; }

    public User? SubjectUser { get; set; }

    public Guid AuthorUserId { get; set; }

    public User? AuthorUser { get; set; }

    public Guid EventId { get; set; }

    public Event? Event { get; set; }

    public short Rating { get; set; }

    public string? Comment { get; set; }
}
