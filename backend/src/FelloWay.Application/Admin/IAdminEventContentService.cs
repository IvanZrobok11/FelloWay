namespace FelloWay.Application.Admin;

public interface IAdminEventContentService
{
    Task<IReadOnlyList<AdminCityDto>> ListCitiesAsync(CancellationToken cancellationToken = default);

    Task<IReadOnlyList<AdminEventListItemDto>> ListEventsAsync(CancellationToken cancellationToken = default);

    Task<AdminEventDetailDto> GetEventAsync(Guid id, CancellationToken cancellationToken = default);

    Task<Guid> CreateEventAsync(AdminEventCreateRequest request, CancellationToken cancellationToken = default);

    Task UpdateEventAsync(Guid id, AdminEventUpdateRequest request, CancellationToken cancellationToken = default);

    Task<string> UploadCoverAsync(
        Guid id,
        Stream content,
        string contentType,
        CancellationToken cancellationToken = default);
}
