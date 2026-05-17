using FelloWay.Application.Common.Interfaces;

namespace FelloWay.Infrastructure.Stream;

public class DevStreamChatService : IStreamChatService
{
    public Task EnsureUserAsync(Guid userId, string? displayName, CancellationToken cancellationToken = default) =>
        Task.CompletedTask;

    public Task<string> CreateUserTokenAsync(Guid userId, CancellationToken cancellationToken = default) =>
        Task.FromResult($"dev-stream-token-{userId:N}");
}
