using Microsoft.Extensions.Logging;

namespace FelloWay.Infrastructure.Notifications;

/// <summary>
/// Stub for custom push triggers (event interest / same-city attend) until Phase 4 notification provider is wired.
/// </summary>
public class CustomPushDispatcher(ILogger<CustomPushDispatcher> logger)
{
    public Task DispatchEventInterestMatchAsync(Guid userId, Guid eventId, CancellationToken cancellationToken = default)
    {
        logger.LogDebug("Push stub: event interest match user {UserId} event {EventId}", userId, eventId);
        return Task.CompletedTask;
    }

    public Task DispatchSameCityAttendAsync(Guid userId, Guid eventId, CancellationToken cancellationToken = default)
    {
        logger.LogDebug("Push stub: same-city attend user {UserId} event {EventId}", userId, eventId);
        return Task.CompletedTask;
    }

    public Task DispatchPostEventReviewReminderAsync(
        Guid eventId,
        string eventTitle,
        CancellationToken cancellationToken = default)
    {
        logger.LogDebug("Push stub: post-event review reminder for {EventId} ({Title})", eventId, eventTitle);
        return Task.CompletedTask;
    }
}
