using FelloWay.Application.Common.Interfaces;
using FelloWay.Application.Users.Models;
using FelloWay.Domain.Common;
using FelloWay.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace FelloWay.Application.Users;

public class UserProfileService(IApplicationDbContext db, IBlobStorageService blobStorage) : IUserProfileService
{
    public async Task<UserProfileDto> GetCurrentAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var user = await LoadUserAsync(userId, cancellationToken);
        return Map(user);
    }

    public async Task<UserProfileDto> UpdateCurrentAsync(
        Guid userId,
        UpdateUserProfileRequest request,
        CancellationToken cancellationToken = default)
    {
        var user = await LoadUserAsync(userId, cancellationToken);

        if (request.DisplayName is not null)
        {
            user.DisplayName = request.DisplayName.Trim();
        }

        if (request.Bio is not null)
        {
            user.Bio = request.Bio;
        }

        if (request.HomeCityId.HasValue)
        {
            var cityExists = await db.Cities.AnyAsync(c => c.Id == request.HomeCityId.Value, cancellationToken);
            if (!cityExists)
            {
                throw new DomainException("Unknown home city.");
            }

            user.HomeCityId = request.HomeCityId;
        }

        if (request.InterestIds is not null)
        {
            var validIds = await db.Interests
                .Where(i => request.InterestIds.Contains(i.Id))
                .Select(i => i.Id)
                .ToListAsync(cancellationToken);

            if (validIds.Count != request.InterestIds.Count)
            {
                throw new DomainException("One or more interests are invalid.");
            }

            user.UserInterests.Clear();
            foreach (var interestId in validIds)
            {
                user.UserInterests.Add(new UserInterest { UserId = user.Id, InterestId = interestId });
            }
        }

        user.UpdatedAt = DateTimeOffset.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
        return Map(await LoadUserAsync(userId, cancellationToken));
    }

    public async Task<string> UploadAvatarAsync(
        Guid userId,
        Stream content,
        string contentType,
        CancellationToken cancellationToken = default)
    {
        var user = await LoadUserAsync(userId, cancellationToken);
        var url = await blobStorage.UploadAvatarAsync(userId, content, contentType, cancellationToken);
        user.AvatarUrl = url;
        user.UpdatedAt = DateTimeOffset.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
        return url;
    }

    private async Task<User> LoadUserAsync(Guid userId, CancellationToken cancellationToken)
    {
        return await db.Users
            .Include(u => u.HomeCity)
            .Include(u => u.UserInterests)
            .FirstOrDefaultAsync(u => u.Id == userId, cancellationToken)
            ?? throw new DomainException("User not found.");
    }

    private static UserProfileDto Map(User user) =>
        new(
            user.Id,
            user.DisplayName,
            user.Bio,
            user.HomeCity?.Name,
            user.HomeCityId,
            user.UserInterests.Select(x => x.InterestId).ToList(),
            user.AvatarUrl,
            user.AggregateRating,
            user.IsProfileComplete);
}
