using FelloWay.Application.Trips.Models;

namespace FelloWay.Application.Trips;

public interface ITripService
{
    Task<IReadOnlyList<TripDto>> ListForEventAsync(
        Guid eventId,
        Guid userId,
        CancellationToken cancellationToken = default);

    Task<TripDto> CreateAsync(
        Guid eventId,
        Guid userId,
        CreateTripRequest request,
        CancellationToken cancellationToken = default);

    Task RequestJoinAsync(Guid tripId, Guid userId, CancellationToken cancellationToken = default);

    Task CancelJoinRequestAsync(Guid tripId, Guid userId, CancellationToken cancellationToken = default);

    Task<IReadOnlyList<TripJoinRequestDto>> ListPendingJoinRequestsAsync(
        Guid tripId,
        Guid userId,
        CancellationToken cancellationToken = default);

    Task ApproveJoinAsync(Guid tripId, Guid ownerUserId, Guid requesterUserId, CancellationToken cancellationToken = default);

    Task RevokeUserFromEventTripsAsync(Guid eventId, Guid userId, CancellationToken cancellationToken = default);
}
