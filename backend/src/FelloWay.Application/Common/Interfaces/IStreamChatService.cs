namespace FelloWay.Application.Common.Interfaces;

public interface IStreamChatService
{
    Task EnsureUserAsync(Guid userId, string? displayName, CancellationToken cancellationToken = default);

    Task<string> CreateUserTokenAsync(Guid userId, CancellationToken cancellationToken = default);
}
