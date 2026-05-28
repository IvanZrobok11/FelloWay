namespace FelloWay.Application.Common.Interfaces;

public interface IBlobStorageService
{
    Task<string> UploadAvatarAsync(Guid userId, Stream content, string contentType, CancellationToken cancellationToken = default);

    Task<string> UploadEventCoverAsync(
        Guid eventId,
        Stream content,
        string contentType,
        CancellationToken cancellationToken = default);
}
