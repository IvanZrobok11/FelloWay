using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using FelloWay.Admin.Options;
using Microsoft.Extensions.Options;

namespace FelloWay.Admin.Services;

public sealed class AdminApiClient
{
    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web);

    private readonly HttpClient _http;
    private readonly AdminAuthOptions _auth;

    public AdminApiClient(HttpClient http, IOptions<AdminAuthOptions> authOptions)
    {
        _http = http;
        _auth = authOptions.Value;
    }

    public async Task<IReadOnlyList<AdminCityItem>> GetCitiesAsync(CancellationToken cancellationToken = default)
    {
        using var request = CreateRequest(HttpMethod.Get, "admin/events/cities");
        var response = await _http.SendAsync(request, cancellationToken);
        response.EnsureSuccessStatusCode();
        var payload = await response.Content.ReadFromJsonAsync<CitiesResponse>(JsonOptions, cancellationToken)
            ?? throw new InvalidOperationException("Empty cities response.");
        return payload.Items;
    }

    public async Task<IReadOnlyList<AdminEventListItem>> GetEventsAsync(CancellationToken cancellationToken = default)
    {
        using var request = CreateRequest(HttpMethod.Get, "admin/events");
        var response = await _http.SendAsync(request, cancellationToken);
        response.EnsureSuccessStatusCode();
        var payload = await response.Content.ReadFromJsonAsync<EventsListResponse>(JsonOptions, cancellationToken)
            ?? throw new InvalidOperationException("Empty events response.");
        return payload.Items;
    }

    public async Task<AdminEventDetail> GetEventAsync(Guid id, CancellationToken cancellationToken = default)
    {
        using var request = CreateRequest(HttpMethod.Get, $"admin/events/{id}");
        var response = await _http.SendAsync(request, cancellationToken);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<AdminEventDetail>(JsonOptions, cancellationToken)
            ?? throw new InvalidOperationException("Empty event response.");
    }

    public async Task<Guid> CreateEventAsync(AdminEventCreatePayload payload, CancellationToken cancellationToken = default)
    {
        using var request = CreateRequest(HttpMethod.Post, "admin/events");
        request.Content = JsonContent.Create(payload, options: JsonOptions);
        var response = await _http.SendAsync(request, cancellationToken);
        response.EnsureSuccessStatusCode();
        var created = await response.Content.ReadFromJsonAsync<CreatedResponse>(JsonOptions, cancellationToken)
            ?? throw new InvalidOperationException("Empty create response.");
        return created.Id;
    }

    public async Task UpdateEventAsync(
        Guid id,
        AdminEventUpdatePayload payload,
        CancellationToken cancellationToken = default)
    {
        using var request = CreateRequest(HttpMethod.Put, $"admin/events/{id}");
        request.Content = JsonContent.Create(payload, options: JsonOptions);
        var response = await _http.SendAsync(request, cancellationToken);
        response.EnsureSuccessStatusCode();
    }

    public async Task<string> UploadCoverAsync(
        Guid id,
        Stream content,
        string fileName,
        string contentType,
        CancellationToken cancellationToken = default)
    {
        using var request = CreateRequest(HttpMethod.Post, $"admin/events/{id}/cover");
        using var form = new MultipartFormDataContent();
        var streamContent = new StreamContent(content);
        streamContent.Headers.ContentType = new MediaTypeHeaderValue(contentType);
        form.Add(streamContent, "file", fileName);
        request.Content = form;
        var response = await _http.SendAsync(request, cancellationToken);
        response.EnsureSuccessStatusCode();
        var payload = await response.Content.ReadFromJsonAsync<CoverResponse>(JsonOptions, cancellationToken)
            ?? throw new InvalidOperationException("Empty cover response.");
        return payload.CoverImageUrl;
    }

    private HttpRequestMessage CreateRequest(HttpMethod method, string relativePath)
    {
        var request = new HttpRequestMessage(method, relativePath);
        if (!string.IsNullOrWhiteSpace(_auth.ServiceKey))
        {
            request.Headers.Add("X-Admin-Service-Key", _auth.ServiceKey);
        }

        return request;
    }

    private sealed record CitiesResponse(IReadOnlyList<AdminCityItem> Items);

    private sealed record EventsListResponse(IReadOnlyList<AdminEventListItem> Items);

    private sealed record CreatedResponse(Guid Id);

    private sealed record CoverResponse(string CoverImageUrl);
}

public sealed record AdminCityItem(Guid Id, string Name, string CountryCode);

public sealed record AdminEventListItem(
    Guid Id,
    string Title,
    DateTimeOffset StartsAt,
    DateTimeOffset EndsAt,
    string CityName,
    string Status);

public sealed record AdminEventDetail(
    Guid Id,
    string Title,
    string? Description,
    DateTimeOffset StartsAt,
    DateTimeOffset EndsAt,
    Guid CityId,
    string CityName,
    string? Venue,
    string? CoverImageUrl,
    int? Capacity,
    string? OfficialUrl,
    string Status);

public sealed record AdminEventCreatePayload(
    string Title,
    string? Description,
    DateTimeOffset StartsAt,
    DateTimeOffset EndsAt,
    Guid CityId,
    string? Venue,
    int? Capacity,
    string? OfficialUrl);

public sealed record AdminEventUpdatePayload(
    string? Title,
    string? Description,
    DateTimeOffset? StartsAt,
    DateTimeOffset? EndsAt,
    Guid? CityId,
    string? Venue,
    int? Capacity,
    string? OfficialUrl,
    string? Status);
