using FelloWay.Application.Events.Models;

namespace FelloWay.Application.Events;

public interface IEventService
{
    Task<EventListPageDto> ListAsync(ListEventsRequest request, Guid? userId, CancellationToken cancellationToken = default);

    Task<EventDto?> GetByIdAsync(Guid eventId, Guid? userId, CancellationToken cancellationToken = default);

    Task AttendAsync(Guid eventId, Guid userId, CancellationToken cancellationToken = default);

    Task LeaveAsync(Guid eventId, Guid userId, CancellationToken cancellationToken = default);

    Task<IReadOnlyList<AttendeeDto>> GetAttendeesAsync(
        Guid eventId,
        Guid userId,
        CancellationToken cancellationToken = default);
}
