namespace FelloWay.Admin.Services;

public sealed class AdminApiLoggingHandler(ILogger<AdminApiLoggingHandler> logger) : DelegatingHandler
{
    protected override async Task<HttpResponseMessage> SendAsync(
        HttpRequestMessage request,
        CancellationToken cancellationToken)
    {
        logger.LogInformation(
            "Admin → API {Method} {Uri}",
            request.Method,
            request.RequestUri);

        var response = await base.SendAsync(request, cancellationToken);

        if (!response.IsSuccessStatusCode)
        {
            var body = await response.Content.ReadAsStringAsync(cancellationToken);
            logger.LogWarning(
                "Admin → API failed {StatusCode} {Method} {Uri} body={Body}",
                (int)response.StatusCode,
                request.Method,
                request.RequestUri,
                body);
        }

        return response;
    }
}
