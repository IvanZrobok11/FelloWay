using FelloWay.Application.Admin;
using FelloWay.Domain.Common;
using FelloWay.Domain.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FelloWay.Api.Controllers;

[ApiController]
[Authorize(Policy = "AdminOnly")]
[Route("admin")]
public class AdminController(IAdminModerationService adminService) : ControllerBase
{
    [HttpGet("events/pending")]
    public async Task<ActionResult<object>> ListPendingEvents(CancellationToken cancellationToken)
    {
        var items = await adminService.ListPendingEventsAsync(cancellationToken);
        return Ok(new { items });
    }

    [HttpPost("events/{id:guid}/approve")]
    public async Task<IActionResult> ApproveEvent(Guid id, CancellationToken cancellationToken)
    {
        await adminService.ApproveEventAsync(id, cancellationToken);
        return NoContent();
    }

    [HttpPost("events/{id:guid}/reject")]
    public async Task<IActionResult> RejectEvent(Guid id, CancellationToken cancellationToken)
    {
        await adminService.RejectEventAsync(id, cancellationToken);
        return NoContent();
    }

    [HttpPost("users/{id:guid}/ban")]
    public async Task<IActionResult> BanUser(Guid id, CancellationToken cancellationToken)
    {
        await adminService.BanUserAsync(id, cancellationToken);
        return NoContent();
    }

    [HttpGet("reports")]
    public async Task<ActionResult<object>> ListReports(CancellationToken cancellationToken)
    {
        var items = await adminService.ListPendingReportsAsync(cancellationToken);
        return Ok(new { items });
    }

    [HttpPost("reports/{id:guid}/resolve")]
    public async Task<IActionResult> ResolveReport(
        Guid id,
        [FromBody] ResolveReportBody body,
        CancellationToken cancellationToken)
    {
        var status = body.Status?.ToLowerInvariant() switch
        {
            "resolved" => ReportStatus.Resolved,
            "dismissed" => ReportStatus.Dismissed,
            _ => throw new DomainException("status must be resolved or dismissed"),
        };

        await adminService.ResolveReportAsync(id, status, cancellationToken);
        return NoContent();
    }

    public sealed record ResolveReportBody(string? Status);
}
