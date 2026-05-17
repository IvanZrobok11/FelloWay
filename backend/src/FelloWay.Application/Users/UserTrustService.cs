using FelloWay.Application.Common.Interfaces;
using FelloWay.Application.Users.Models;
using FelloWay.Domain.Common;
using FelloWay.Domain.Entities;
using FelloWay.Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace FelloWay.Application.Users;

public class UserTrustService(IApplicationDbContext db) : IUserTrustService
{
    public async Task BlockUserAsync(Guid blockerUserId, Guid blockedUserId, CancellationToken cancellationToken = default)
    {
        if (blockerUserId == blockedUserId)
        {
            throw new DomainException("You cannot block yourself.");
        }

        if (!await db.Users.AnyAsync(u => u.Id == blockedUserId, cancellationToken))
        {
            throw new NotFoundException("User not found.");
        }

        var exists = await db.BlockedUsers.AnyAsync(
            b => b.BlockerUserId == blockerUserId && b.BlockedUserId == blockedUserId,
            cancellationToken);

        if (exists)
        {
            return;
        }

        db.BlockedUsers.Add(new BlockedUser
        {
            BlockerUserId = blockerUserId,
            BlockedUserId = blockedUserId,
        });
        await db.SaveChangesAsync(cancellationToken);
    }

    public Task<bool> IsBlockedAsync(Guid userId, Guid otherUserId, CancellationToken cancellationToken = default) =>
        db.BlockedUsers.AnyAsync(
            b => (b.BlockerUserId == userId && b.BlockedUserId == otherUserId) ||
                 (b.BlockerUserId == otherUserId && b.BlockedUserId == userId),
            cancellationToken);

    public async Task<IReadOnlyList<ReviewDto>> ListReviewsForUserAsync(
        Guid subjectUserId,
        CancellationToken cancellationToken = default)
    {
        return await db.Reviews
            .AsNoTracking()
            .Include(r => r.AuthorUser)
            .Include(r => r.Event)
            .Where(r => r.SubjectUserId == subjectUserId)
            .OrderByDescending(r => r.CreatedAt)
            .Select(r => new ReviewDto(
                r.Id,
                r.AuthorUserId,
                r.AuthorUser!.DisplayName,
                r.Rating,
                r.Comment,
                r.Event!.Title,
                r.CreatedAt))
            .ToListAsync(cancellationToken);
    }

    public async Task SubmitEventReviewAsync(
        Guid authorUserId,
        Guid eventId,
        Guid subjectUserId,
        SubmitReviewRequest request,
        CancellationToken cancellationToken = default)
    {
        if (authorUserId == subjectUserId)
        {
            throw new DomainException("You cannot review yourself.");
        }

        if (request.Rating is < 1 or > 5)
        {
            throw new DomainException("Rating must be between 1 and 5.");
        }

        if (await IsBlockedAsync(authorUserId, subjectUserId, cancellationToken))
        {
            throw new DomainException("Interaction with this user is blocked.");
        }

        var eventExists = await db.Events.AnyAsync(e => e.Id == eventId, cancellationToken);
        if (!eventExists)
        {
            throw new NotFoundException("Event not found.");
        }

        var authorJoined = await db.EventAttendees.AnyAsync(
            a => a.EventId == eventId && a.UserId == authorUserId && a.Status == AttendanceStatus.Joined,
            cancellationToken);
        var subjectJoined = await db.EventAttendees.AnyAsync(
            a => a.EventId == eventId && a.UserId == subjectUserId && a.Status == AttendanceStatus.Joined,
            cancellationToken);

        if (!authorJoined || !subjectJoined)
        {
            throw new DomainException("Both users must have attended the event.");
        }

        var duplicate = await db.Reviews.AnyAsync(
            r => r.EventId == eventId &&
                 r.AuthorUserId == authorUserId &&
                 r.SubjectUserId == subjectUserId,
            cancellationToken);
        if (duplicate)
        {
            throw new DomainException("You already reviewed this attendee for this event.");
        }

        var subject = await db.Users.FirstAsync(u => u.Id == subjectUserId, cancellationToken);
        var existingRatings = await db.Reviews
            .Where(r => r.SubjectUserId == subjectUserId)
            .Select(r => (int)r.Rating)
            .ToListAsync(cancellationToken);

        subject.AggregateRating = RatingAggregation.ApplyNewRating(existingRatings, request.Rating);

        db.Reviews.Add(new Review
        {
            EventId = eventId,
            AuthorUserId = authorUserId,
            SubjectUserId = subjectUserId,
            Rating = (short)request.Rating,
            Comment = request.Comment,
        });
        subject.UpdatedAt = DateTimeOffset.UtcNow;

        await db.SaveChangesAsync(cancellationToken);
    }

    public async Task UpdatePushPreferencesAsync(
        Guid userId,
        PushPreferencesDto preferences,
        CancellationToken cancellationToken = default)
    {
        var entity = await db.PushPreferences.FirstOrDefaultAsync(p => p.UserId == userId, cancellationToken);
        if (entity is null)
        {
            entity = new PushPreferences { UserId = userId };
            db.PushPreferences.Add(entity);
        }

        entity.GlobalEnabled = preferences.GlobalEnabled;
        entity.EventMessages = preferences.EventMessages;
        entity.TripMessages = preferences.TripMessages;
        entity.DirectMessages = preferences.DirectMessages;
        entity.UpdatedAt = DateTimeOffset.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
    }

    public async Task<PushPreferencesDto> GetPushPreferencesAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        var entity = await db.PushPreferences.AsNoTracking()
            .FirstOrDefaultAsync(p => p.UserId == userId, cancellationToken);

        return entity is null
            ? new PushPreferencesDto(true, true, true, true)
            : new PushPreferencesDto(
                entity.GlobalEnabled,
                entity.EventMessages,
                entity.TripMessages,
                entity.DirectMessages);
    }
}
