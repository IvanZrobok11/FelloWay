namespace FelloWay.Api.Tests.Infrastructure;

public class CorrelationIdMiddlewareTests : IClassFixture<FelloWayWebApplicationFactory>
{
    private readonly HttpClient _client;

    public CorrelationIdMiddlewareTests(FelloWayWebApplicationFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task Health_ReturnsCorrelationIdHeader()
    {
        var requestId = Guid.NewGuid().ToString("N");
        using var request = new HttpRequestMessage(HttpMethod.Get, "/health");
        request.Headers.Add("X-Correlation-ID", requestId);

        var response = await _client.SendAsync(request);
        response.EnsureSuccessStatusCode();

        Assert.True(response.Headers.TryGetValues("X-Correlation-ID", out var values));
        Assert.Equal(requestId, values!.Single());
    }

    [Fact]
    public async Task Health_GeneratesCorrelationIdWhenMissing()
    {
        var response = await _client.GetAsync("/health");
        response.EnsureSuccessStatusCode();
        Assert.True(response.Headers.Contains("X-Correlation-ID"));
    }
}
