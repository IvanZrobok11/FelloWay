using FelloWay.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace FelloWay.Application.Common.Interfaces;

public interface IApplicationDbContext
{
    DbSet<User> Users { get; }

    DbSet<City> Cities { get; }

    DbSet<Interest> Interests { get; }

    DbSet<UserInterest> UserInterests { get; }

    DbSet<OAuthIdentity> OAuthIdentities { get; }

    DbSet<RefreshToken> RefreshTokens { get; }

    DbSet<Event> Events { get; }

    DbSet<EventAttendee> EventAttendees { get; }

    DbSet<EventInterest> EventInterests { get; }

    DbSet<Trip> Trips { get; }

    DbSet<TripMember> TripMembers { get; }

    DbSet<TripJoinRequest> TripJoinRequests { get; }

    DbSet<Review> Reviews { get; }

    DbSet<BlockedUser> BlockedUsers { get; }

    DbSet<PushPreferences> PushPreferences { get; }

    DbSet<Report> Reports { get; }

    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
