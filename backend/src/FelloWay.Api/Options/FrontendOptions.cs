namespace FelloWay.Api.Options;

public sealed class FrontendOptions
{
    public const string SectionName = "Frontend";

    /// <summary>
    /// Flutter web / client origin for OAuth return (e.g. http://localhost:55162).
    /// </summary>
    public string BaseUrl { get; set; } = "http://localhost:7357";
}
