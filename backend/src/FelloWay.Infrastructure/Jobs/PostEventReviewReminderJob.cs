using FelloWay.Domain.Enums;
using FelloWay.Infrastructure.Notifications;
using FelloWay.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FelloWay.Infrastructure.Jobs;

public class PostEventReviewReminderJob(
    FelloWayDbContext db,
    CustomPushDispatcher pushDispatcher,
    ILogger<PostEventReviewReminderJob> logger)
{
    public async Task RunAsync(CancellationToken cancellationToken = default)
    {
        var cutoff = DateTimeOffset.UtcNow.AddHours(-24);
        var endedEvents = await db.Events
            .AsNoTracking()
            .Where(e => e.Status == EventStatus.Active && e.EndsAt <= DateTimeOffset.UtcNow && e.EndsAt >= cutoff)
            .Select(e => new { e.Id, e.Title })
            .ToListAsync(cancellationToken);

        foreach (var evt in endedEvents)
        {
            logger.LogInformation("Post-event review reminder stub for event {EventId} ({Title})", evt.Id, evt.Title);
            await pushDispatcher.DispatchPostEventReviewReminderAsync(evt.Id, evt.Title, cancellationToken);
        }
    }
}
