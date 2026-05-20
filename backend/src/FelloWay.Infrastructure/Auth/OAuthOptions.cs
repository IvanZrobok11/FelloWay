namespace FelloWay.Infrastructure.Auth;

public sealed class OAuthOptions
{
    public const string SectionName = "OAuth";

    public LinkedInOAuthOptions LinkedIn { get; set; } = new();
}

public sealed class LinkedInOAuthOptions
{
    public string? ClientId { get; set; }

    public string? ClientSecret { get; set; }

    public bool IsConfigured =>
        !string.IsNullOrWhiteSpace(ClientId) && !string.IsNullOrWhiteSpace(ClientSecret);
}
