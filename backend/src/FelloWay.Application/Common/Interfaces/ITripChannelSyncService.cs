namespace FelloWay.Application.Common.Interfaces;

public interface ITripChannelSyncService
{
    Task<string> CreateTripChannelAsync(Guid tripId, Guid eventId, CancellationToken cancellationToken = default);

    Task AddMemberAsync(Guid tripId, Guid userId, CancellationToken cancellationToken = default);

    Task RemoveMemberAsync(Guid tripId, Guid userId, CancellationToken cancellationToken = default);
}
