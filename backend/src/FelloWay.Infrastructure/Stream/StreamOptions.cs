namespace FelloWay.Infrastructure.Stream;

public sealed class StreamOptions
{
    public const string SectionName = "Stream";

    public string? ApiKey { get; set; }

    public string? ApiSecret { get; set; }

    public bool IsConfigured =>
        !string.IsNullOrWhiteSpace(ApiKey) && !string.IsNullOrWhiteSpace(ApiSecret);
}
