using FelloWay.Application.Common.Interfaces;

namespace FelloWay.Infrastructure.Stream;

public class DevTripChannelSyncService : ITripChannelSyncService
{
    public Task<string> CreateTripChannelAsync(Guid tripId, Guid eventId, CancellationToken cancellationToken = default) =>
        Task.FromResult($"trip_{tripId:N}");

    public Task AddMemberAsync(Guid tripId, Guid userId, CancellationToken cancellationToken = default) =>
        Task.CompletedTask;

    public Task RemoveMemberAsync(Guid tripId, Guid userId, CancellationToken cancellationToken = default) =>
        Task.CompletedTask;
}
