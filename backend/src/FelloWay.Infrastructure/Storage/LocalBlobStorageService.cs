using FelloWay.Application.Common.Interfaces;
using Microsoft.Extensions.Options;

namespace FelloWay.Infrastructure.Storage;

public class LocalBlobStorageService(IOptions<BlobStorageOptions> options) : IBlobStorageService
{
    public async Task<string> UploadAvatarAsync(
        Guid userId,
        System.IO.Stream content,
        string contentType,
        CancellationToken cancellationToken = default)
    {
        var extension = contentType switch
        {
            "image/png" => ".png",
            "image/jpeg" or "image/jpg" => ".jpg",
            "image/webp" => ".webp",
            _ => ".bin",
        };

        var root = options.Value.AvatarRootPath;
        Directory.CreateDirectory(root);

        var fileName = $"{userId:N}{extension}";
        var path = Path.Combine(root, fileName);
        await using var file = File.Create(path);
        await content.CopyToAsync(file, cancellationToken);

        return $"{options.Value.PublicBasePath.TrimEnd('/')}/{fileName}";
    }
}
