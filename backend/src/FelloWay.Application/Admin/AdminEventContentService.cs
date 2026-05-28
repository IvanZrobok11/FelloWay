using FelloWay.Application.Common.Interfaces;
using FelloWay.Domain.Common;
using FelloWay.Domain.Entities;
using FelloWay.Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace FelloWay.Application.Admin;

public class AdminEventContentService(IApplicationDbContext db, IBlobStorageService blobStorage)
    : IAdminEventContentService
{
    public async Task<IReadOnlyList<AdminCityDto>> ListCitiesAsync(CancellationToken cancellationToken = default) =>
        await db.Cities
            .AsNoTracking()
            .OrderBy(c => c.Name)
            .Select(c => new AdminCityDto(c.Id, c.Name, c.CountryCode))
            .ToListAsync(cancellationToken);

    public async Task<IReadOnlyList<AdminEventListItemDto>> ListEventsAsync(
        CancellationToken cancellationToken = default) =>
        await db.Events
            .AsNoTracking()
            .Include(e => e.City)
            .OrderByDescending(e => e.StartsAt)
            .Select(e => new AdminEventListItemDto(
                e.Id,
                e.Title,
                e.StartsAt,
                e.EndsAt,
                e.City != null ? e.City.Name : string.Empty,
                e.Status.ToString().ToLowerInvariant()))
            .ToListAsync(cancellationToken);

    public async Task<AdminEventDetailDto> GetEventAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var entity = await db.Events
            .AsNoTracking()
            .Include(e => e.City)
            .FirstOrDefaultAsync(e => e.Id == id, cancellationToken)
            ?? throw new NotFoundException("Event not found.");

        return MapDetail(entity);
    }

    public async Task<Guid> CreateEventAsync(
        AdminEventCreateRequest request,
        CancellationToken cancellationToken = default)
    {
        ValidateDates(request.StartsAt, request.EndsAt);
        await EnsureCityExistsAsync(request.CityId, cancellationToken);

        var title = request.Title?.Trim() ?? string.Empty;
        if (string.IsNullOrEmpty(title))
        {
            throw new DomainException("title is required.");
        }

        var entity = new Event
        {
            Title = title,
            Description = string.IsNullOrWhiteSpace(request.Description) ? null : request.Description.Trim(),
            StartsAt = request.StartsAt,
            EndsAt = request.EndsAt,
            CityId = request.CityId,
            Venue = string.IsNullOrWhiteSpace(request.Venue) ? null : request.Venue.Trim(),
            Capacity = request.Capacity,
            OfficialUrl = string.IsNullOrWhiteSpace(request.OfficialUrl) ? null : request.OfficialUrl.Trim(),
            Status = EventStatus.Active,
        };

        db.Events.Add(entity);
        await db.SaveChangesAsync(cancellationToken);
        return entity.Id;
    }

    public async Task UpdateEventAsync(
        Guid id,
        AdminEventUpdateRequest request,
        CancellationToken cancellationToken = default)
    {
        var entity = await db.Events.FirstOrDefaultAsync(e => e.Id == id, cancellationToken)
            ?? throw new NotFoundException("Event not found.");

        if (!string.IsNullOrWhiteSpace(request.Title))
        {
            entity.Title = request.Title.Trim();
        }

        if (request.Description is not null)
        {
            entity.Description = string.IsNullOrWhiteSpace(request.Description)
                ? null
                : request.Description.Trim();
        }

        if (request.StartsAt.HasValue)
        {
            entity.StartsAt = request.StartsAt.Value;
        }

        if (request.EndsAt.HasValue)
        {
            entity.EndsAt = request.EndsAt.Value;
        }

        ValidateDates(entity.StartsAt, entity.EndsAt);

        if (request.CityId.HasValue)
        {
            await EnsureCityExistsAsync(request.CityId.Value, cancellationToken);
            entity.CityId = request.CityId.Value;
        }

        if (request.Venue is not null)
        {
            entity.Venue = string.IsNullOrWhiteSpace(request.Venue) ? null : request.Venue.Trim();
        }

        if (request.Capacity.HasValue)
        {
            entity.Capacity = request.Capacity;
        }

        if (request.OfficialUrl is not null)
        {
            entity.OfficialUrl = string.IsNullOrWhiteSpace(request.OfficialUrl)
                ? null
                : request.OfficialUrl.Trim();
        }

        if (!string.IsNullOrWhiteSpace(request.Status))
        {
            entity.Status = ParseStatus(request.Status);
        }

        entity.UpdatedAt = DateTimeOffset.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
    }

    public async Task<string> UploadCoverAsync(
        Guid id,
        Stream content,
        string contentType,
        CancellationToken cancellationToken = default)
    {
        var entity = await db.Events.FirstOrDefaultAsync(e => e.Id == id, cancellationToken)
            ?? throw new NotFoundException("Event not found.");

        var url = await blobStorage.UploadEventCoverAsync(id, content, contentType, cancellationToken);
        entity.CoverImageUrl = url;
        entity.UpdatedAt = DateTimeOffset.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
        return url;
    }

    private static AdminEventDetailDto MapDetail(Event entity) =>
        new(
            entity.Id,
            entity.Title,
            entity.Description,
            entity.StartsAt,
            entity.EndsAt,
            entity.CityId,
            entity.City?.Name ?? string.Empty,
            entity.Venue,
            entity.CoverImageUrl,
            entity.Capacity,
            entity.OfficialUrl,
            entity.Status.ToString().ToLowerInvariant());

    private static void ValidateDates(DateTimeOffset startsAt, DateTimeOffset endsAt)
    {
        if (endsAt <= startsAt)
        {
            throw new DomainException("endsAt must be after startsAt.");
        }
    }

    private async Task EnsureCityExistsAsync(Guid cityId, CancellationToken cancellationToken)
    {
        if (!await db.Cities.AnyAsync(c => c.Id == cityId, cancellationToken))
        {
            throw new DomainException("Invalid city.");
        }
    }

    private static EventStatus ParseStatus(string status) =>
        status.Trim().ToLowerInvariant() switch
        {
            "active" => EventStatus.Active,
            "rejected" => EventStatus.Rejected,
            "pending" => EventStatus.Pending,
            "archived" => EventStatus.Archived,
            _ => throw new DomainException("status must be active, rejected, pending, or archived."),
        };
}
