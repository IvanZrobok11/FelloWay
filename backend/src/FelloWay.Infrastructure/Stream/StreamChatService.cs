using FelloWay.Application.Common.Interfaces;
using GetStream;
using GetStream.Models;
using Microsoft.Extensions.Options;

namespace FelloWay.Infrastructure.Stream;

public sealed class StreamChatService(IOptions<StreamOptions> options) : IStreamChatService
{
    private readonly StreamOptions _options = options.Value;

    public async Task EnsureUserAsync(
        Guid userId,
        string? displayName,
        CancellationToken cancellationToken = default)
    {
        var client = TryCreateClient();
        if (client is null)
        {
            return;
        }

        var userIdString = userId.ToString();
        await client.UpdateUsersAsync(
            new UpdateUsersRequest
            {
                Users = new Dictionary<string, UserRequest>
                {
                    [userIdString] = new UserRequest
                    {
                        ID = userIdString,
                        Name = string.IsNullOrWhiteSpace(displayName) ? userIdString : displayName,
                    },
                },
            },
            cancellationToken);
    }

    public Task<string> CreateUserTokenAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        var client = TryCreateClient();
        if (client is null)
        {
            return Task.FromResult($"dev-stream-token-{userId:N}");
        }

        var token = client.CreateUserToken(userId.ToString());
        return Task.FromResult(token);
    }

    private StreamClient? TryCreateClient()
    {
        if (!_options.IsConfigured)
        {
            return null;
        }

        return new StreamClient(_options.ApiKey!, _options.ApiSecret!);
    }
}
