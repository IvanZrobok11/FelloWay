using FelloWay.Application.Common.Interfaces;

namespace FelloWay.Infrastructure.Stream;

public class DevEventChannelSyncService : IEventChannelSyncService
{
    public Task AddMemberAsync(Guid eventId, Guid userId, CancellationToken cancellationToken = default) =>
        Task.CompletedTask;

    public Task RemoveMemberAsync(Guid eventId, Guid userId, CancellationToken cancellationToken = default) =>
        Task.CompletedTask;
}
