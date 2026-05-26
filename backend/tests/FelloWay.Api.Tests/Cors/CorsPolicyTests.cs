using System.Net;
using System.Net.Http.Json;
using FelloWay.Api.Tests.Infrastructure;

namespace FelloWay.Api.Tests.Cors;

public class CorsPolicyTests
{
  [Fact]
  public async Task GetHealth_WithLocalhostOrigin_ReturnsAllowOrigin()
  {
    await using var factory = new CorsDevelopmentWebApplicationFactory();
    var client = factory.CreateClient();
    const string origin = "http://localhost:62178";

    var request = new HttpRequestMessage(HttpMethod.Get, "/health");
    request.Headers.TryAddWithoutValidation("Origin", origin);

    var response = await client.SendAsync(request);

    Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    Assert.True(response.Headers.TryGetValues("Access-Control-Allow-Origin", out var values));
    Assert.Equal(origin, values.Single());
  }

  [Fact]
  public async Task GetHealth_WithConfiguredOrigin_ReturnsAllowOrigin()
  {
    await using var factory = new CorsConfiguredOriginWebApplicationFactory();
    var client = factory.CreateClient();
    var origin = CorsConfiguredOriginWebApplicationFactory.AllowedOrigin;

    var request = new HttpRequestMessage(HttpMethod.Get, "/health");
    request.Headers.TryAddWithoutValidation("Origin", origin);

    var response = await client.SendAsync(request);

    Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    Assert.True(response.Headers.TryGetValues("Access-Control-Allow-Origin", out var values));
    Assert.Equal(origin, values.Single());
  }

  [Fact]
  public async Task GetHealth_WithUnlistedOrigin_DoesNotReturnAllowOrigin()
  {
    await using var factory = new CorsProductionWebApplicationFactory();
    var client = factory.CreateClient();
    const string origin = "https://evil.example";

    var request = new HttpRequestMessage(HttpMethod.Get, "/health");
    request.Headers.TryAddWithoutValidation("Origin", origin);

    var response = await client.SendAsync(request);

    Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    Assert.False(
      response.Headers.TryGetValues("Access-Control-Allow-Origin", out var values)
        && values.Contains(origin));
  }

  [Fact]
  public async Task OptionsPreflight_MobileComplete_WithConfiguredOrigin_ReturnsAllowOrigin()
  {
    await using var factory = new CorsConfiguredOriginWebApplicationFactory();
    var client = factory.CreateClient();
    var origin = CorsConfiguredOriginWebApplicationFactory.AllowedOrigin;

    var request = new HttpRequestMessage(HttpMethod.Options, "/auth/linkedin/mobile/complete");
    request.Headers.TryAddWithoutValidation("Origin", origin);
    request.Headers.TryAddWithoutValidation("Access-Control-Request-Method", "POST");
    request.Headers.TryAddWithoutValidation("Access-Control-Request-Headers", "content-type");

    var response = await client.SendAsync(request);

    Assert.True(response.StatusCode is HttpStatusCode.OK or HttpStatusCode.NoContent);
    Assert.True(response.Headers.TryGetValues("Access-Control-Allow-Origin", out var values));
    Assert.Equal(origin, values.Single());
  }

  [Fact]
  public async Task PostMobileComplete_WithConfiguredOrigin_ReturnsAllowOrigin()
  {
    await using var factory = new CorsConfiguredOriginWebApplicationFactory();
    var client = factory.CreateClient();
    var origin = CorsConfiguredOriginWebApplicationFactory.AllowedOrigin;

    var request = new HttpRequestMessage(HttpMethod.Post, "/auth/linkedin/mobile/complete");
    request.Headers.TryAddWithoutValidation("Origin", origin);
    request.Content = JsonContent.Create(new { ticket = "invalid" });

    var response = await client.SendAsync(request);

    Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    Assert.True(response.Headers.TryGetValues("Access-Control-Allow-Origin", out var values));
    Assert.Equal(origin, values.Single());
  }

  [Fact]
  public async Task OptionsPreflight_WithAuthorizationHeader_ReturnsAllowHeaders()
  {
    await using var factory = new CorsDevelopmentWebApplicationFactory();
    var client = factory.CreateClient();
    const string origin = "http://localhost:62178";

    var request = new HttpRequestMessage(HttpMethod.Options, "/events");
    request.Headers.TryAddWithoutValidation("Origin", origin);
    request.Headers.TryAddWithoutValidation("Access-Control-Request-Method", "POST");
    request.Headers.TryAddWithoutValidation(
      "Access-Control-Request-Headers",
      "authorization,content-type");

    var response = await client.SendAsync(request);

    Assert.True(
      response.StatusCode is HttpStatusCode.OK or HttpStatusCode.NoContent);
    Assert.True(response.Headers.TryGetValues("Access-Control-Allow-Origin", out var originValues));
    Assert.Equal(origin, originValues.Single());
    Assert.True(response.Headers.TryGetValues("Access-Control-Allow-Methods", out _));
    Assert.True(response.Headers.TryGetValues("Access-Control-Allow-Headers", out var headerValues));
    Assert.Contains(
      "Authorization",
      headerValues.Single(),
      StringComparison.OrdinalIgnoreCase);
  }
}
