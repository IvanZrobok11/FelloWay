namespace FelloWay.Application.Common.Interfaces;

public interface IEventChannelSyncService
{
    Task AddMemberAsync(Guid eventId, Guid userId, CancellationToken cancellationToken = default);

    Task RemoveMemberAsync(Guid eventId, Guid userId, CancellationToken cancellationToken = default);
}
