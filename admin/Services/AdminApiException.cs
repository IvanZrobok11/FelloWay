namespace FelloWay.Admin.Services;

public sealed class AdminApiException : Exception
{
    public AdminApiException(string message, Exception? inner = null)
        : base(message, inner)
    {
    }

    public static async Task EnsureSuccessAsync(HttpResponseMessage response, CancellationToken cancellationToken)
    {
        if (response.IsSuccessStatusCode)
        {
            return;
        }

        var body = await response.Content.ReadAsStringAsync(cancellationToken);
        throw new AdminApiException(
            $"API returned {(int)response.StatusCode} {response.ReasonPhrase}: {body}");
    }
}
