using FelloWay.Domain.Common;
using FelloWay.Domain.Enums;

namespace FelloWay.Domain.Entities;

public class Report : EntityBase
{
    public Guid ReporterUserId { get; set; }

    public User? Reporter { get; set; }

    public string TargetType { get; set; } = string.Empty;

    public string TargetId { get; set; } = string.Empty;

    public string Reason { get; set; } = string.Empty;

    public ReportStatus Status { get; set; } = ReportStatus.Pending;

    public DateTimeOffset? ResolvedAt { get; set; }
}
