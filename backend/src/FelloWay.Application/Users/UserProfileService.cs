using FelloWay.Application.Common.Interfaces;
using FelloWay.Application.Reference.Models;
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
            var requestedIds = request.InterestIds.Distinct().ToList();
            var validIds = await db.Interests
                .Where(i => requestedIds.Contains(i.Id))
                .Select(i => i.Id)
                .ToListAsync(cancellationToken);

            if (validIds.Count != requestedIds.Count)
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
            .ThenInclude(ui => ui.Interest)
            .FirstOrDefaultAsync(u => u.Id == userId, cancellationToken)
            ?? throw new DomainException("User not found.");
    }

    private static UserProfileDto Map(User user)
    {
        var resolved = user.UserInterests
            .Select(ui => ui.Interest)
            .OrderBy(i => i.SortOrder)
            .Select(i => new InterestCatalogItemDto(i.Id, i.Name, i.SortOrder))
            .ToList();

        return new(
            user.Id,
            user.DisplayName,
            user.Bio,
            user.HomeCity?.Name,
            user.HomeCityId,
            resolved.Select(i => i.Id).ToList(),
            resolved,
            user.AvatarUrl,
            user.AggregateRating,
            user.IsProfileComplete);
    }
}
