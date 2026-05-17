using FelloWay.Application.Users.Models;
using FelloWay.Domain.Enums;

namespace FelloWay.Application.Admin;

public interface IAdminModerationService
{
    Task<IReadOnlyList<AdminEventSummaryDto>> ListPendingEventsAsync(CancellationToken cancellationToken = default);

    Task ApproveEventAsync(Guid eventId, CancellationToken cancellationToken = default);

    Task RejectEventAsync(Guid eventId, CancellationToken cancellationToken = default);

    Task BanUserAsync(Guid userId, CancellationToken cancellationToken = default);

    Task<IReadOnlyList<AdminReportDto>> ListPendingReportsAsync(CancellationToken cancellationToken = default);

    Task ResolveReportAsync(Guid reportId, ReportStatus status, CancellationToken cancellationToken = default);
}
