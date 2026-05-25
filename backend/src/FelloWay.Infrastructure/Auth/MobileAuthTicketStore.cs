using Microsoft.Extensions.Caching.Memory;

namespace FelloWay.Infrastructure.Auth;

public interface IMobileAuthTicketStore
{
    string Create(Guid userId, TimeSpan? lifetime = null);

    Guid? Consume(string ticket);
}

public sealed class MobileAuthTicketStore(IMemoryCache cache) : IMobileAuthTicketStore
{
    private static readonly TimeSpan DefaultLifetime = TimeSpan.FromSeconds(60);
    private const string KeyPrefix = "mobile-auth-ticket:";

    public string Create(Guid userId, TimeSpan? lifetime = null)
    {
        var ticket = Guid.NewGuid().ToString("N");
        var entry = new TicketEntry(userId, Consumed: false);
        cache.Set(KeyPrefix + ticket, entry, lifetime ?? DefaultLifetime);
        return ticket;
    }

    public Guid? Consume(string ticket)
    {
        if (string.IsNullOrWhiteSpace(ticket))
        {
            return null;
        }

        var key = KeyPrefix + ticket.Trim();
        if (!cache.TryGetValue<TicketEntry>(key, out var entry) || entry.Consumed)
        {
            return null;
        }

        cache.Remove(key);
        return entry.UserId;
    }

    private sealed record TicketEntry(Guid UserId, bool Consumed);
}
