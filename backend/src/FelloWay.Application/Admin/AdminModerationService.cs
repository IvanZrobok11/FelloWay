using FelloWay.Application.Common.Interfaces;
using FelloWay.Application.Users.Models;
using FelloWay.Domain.Common;
using FelloWay.Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace FelloWay.Application.Admin;

public class AdminModerationService(IApplicationDbContext db) : IAdminModerationService
{
    public async Task<IReadOnlyList<AdminEventSummaryDto>> ListPendingEventsAsync(
        CancellationToken cancellationToken = default) =>
        await db.Events
            .AsNoTracking()
            .Include(e => e.City)
            .Where(e => e.Status == EventStatus.Pending)
            .OrderBy(e => e.StartsAt)
            .Select(e => new AdminEventSummaryDto(
                e.Id,
                e.Title,
                e.StartsAt,
                e.City != null ? e.City.Name : string.Empty,
                e.Status.ToString().ToLowerInvariant()))
            .ToListAsync(cancellationToken);

    public async Task ApproveEventAsync(Guid eventId, CancellationToken cancellationToken = default)
    {
        var entity = await db.Events.FirstOrDefaultAsync(e => e.Id == eventId, cancellationToken)
            ?? throw new NotFoundException("Event not found.");

        if (entity.Status != EventStatus.Pending)
        {
            throw new DomainException("Only pending events can be approved.");
        }

        entity.Status = EventStatus.Active;
        entity.UpdatedAt = DateTimeOffset.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
    }

    public async Task RejectEventAsync(Guid eventId, CancellationToken cancellationToken = default)
    {
        var entity = await db.Events.FirstOrDefaultAsync(e => e.Id == eventId, cancellationToken)
            ?? throw new NotFoundException("Event not found.");

        if (entity.Status != EventStatus.Pending)
        {
            throw new DomainException("Only pending events can be rejected.");
        }

        entity.Status = EventStatus.Rejected;
        entity.UpdatedAt = DateTimeOffset.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
    }

    public async Task BanUserAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var user = await db.Users.FirstOrDefaultAsync(u => u.Id == userId, cancellationToken)
            ?? throw new NotFoundException("User not found.");

        user.BannedAt = DateTimeOffset.UtcNow;
        user.UpdatedAt = DateTimeOffset.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<AdminReportDto>> ListPendingReportsAsync(
        CancellationToken cancellationToken = default) =>
        await db.Reports
            .AsNoTracking()
            .Where(r => r.Status == ReportStatus.Pending)
            .OrderByDescending(r => r.CreatedAt)
            .Select(r => new AdminReportDto(
                r.Id,
                r.ReporterUserId,
                r.TargetType,
                r.TargetId,
                r.Reason,
                r.Status.ToString().ToLowerInvariant(),
                r.CreatedAt))
            .ToListAsync(cancellationToken);

    public async Task ResolveReportAsync(
        Guid reportId,
        ReportStatus status,
        CancellationToken cancellationToken = default)
    {
        if (status == ReportStatus.Pending)
        {
            throw new DomainException("Invalid resolution status.");
        }

        var report = await db.Reports.FirstOrDefaultAsync(r => r.Id == reportId, cancellationToken)
            ?? throw new NotFoundException("Report not found.");

        report.Status = status;
        report.ResolvedAt = DateTimeOffset.UtcNow;
        report.UpdatedAt = DateTimeOffset.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
    }
}
