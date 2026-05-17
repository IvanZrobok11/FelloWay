using FelloWay.Application.Users.Models;

namespace FelloWay.Application.Users;

public interface IUserTrustService
{
    Task BlockUserAsync(Guid blockerUserId, Guid blockedUserId, CancellationToken cancellationToken = default);

    Task<bool> IsBlockedAsync(Guid userId, Guid otherUserId, CancellationToken cancellationToken = default);

    Task<IReadOnlyList<ReviewDto>> ListReviewsForUserAsync(
        Guid subjectUserId,
        CancellationToken cancellationToken = default);

    Task SubmitEventReviewAsync(
        Guid authorUserId,
        Guid eventId,
        Guid subjectUserId,
        SubmitReviewRequest request,
        CancellationToken cancellationToken = default);

    Task UpdatePushPreferencesAsync(
        Guid userId,
        PushPreferencesDto preferences,
        CancellationToken cancellationToken = default);

    Task<PushPreferencesDto> GetPushPreferencesAsync(Guid userId, CancellationToken cancellationToken = default);
}
