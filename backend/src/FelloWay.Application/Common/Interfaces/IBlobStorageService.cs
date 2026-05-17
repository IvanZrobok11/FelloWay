namespace FelloWay.Application.Common.Interfaces;

public interface IBlobStorageService
{
    Task<string> UploadAvatarAsync(Guid userId, Stream content, string contentType, CancellationToken cancellationToken = default);
}
