using FelloWay.Domain.Common;

namespace FelloWay.Domain.Entities;

public class OAuthIdentity : EntityBase
{
    public Guid UserId { get; set; }

    public User User { get; set; } = null!;

    public required string Provider { get; set; }

    public required string ProviderSubject { get; set; }
}
