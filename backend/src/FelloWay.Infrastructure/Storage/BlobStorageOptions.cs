namespace FelloWay.Infrastructure.Storage;

public class BlobStorageOptions
{
    public string AvatarRootPath { get; set; } = "wwwroot/avatars";

    public string PublicBasePath { get; set; } = "/avatars";

    public string EventCoverRootPath { get; set; } = "wwwroot/event-covers";

    public string EventCoverPublicBasePath { get; set; } = "/event-covers";
}
