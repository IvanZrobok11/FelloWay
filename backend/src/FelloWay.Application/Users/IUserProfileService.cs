using FelloWay.Application.Users.Models;

namespace FelloWay.Application.Users;

public interface IUserProfileService
{
    Task<UserProfileDto> GetCurrentAsync(Guid userId, CancellationToken cancellationToken = default);

    Task<UserProfileDto> UpdateCurrentAsync(Guid userId, UpdateUserProfileRequest request, CancellationToken cancellationToken = default);

    Task<string> UploadAvatarAsync(Guid userId, Stream content, string contentType, CancellationToken cancellationToken = default);
}
