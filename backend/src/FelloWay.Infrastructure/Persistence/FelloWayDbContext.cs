using FelloWay.Application.Common.Interfaces;
using FelloWay.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace FelloWay.Infrastructure.Persistence;

public class FelloWayDbContext(DbContextOptions<FelloWayDbContext> options)
    : DbContext(options), IApplicationDbContext
{
    public DbSet<User> Users => Set<User>();

    public DbSet<City> Cities => Set<City>();

    public DbSet<Interest> Interests => Set<Interest>();

    public DbSet<UserInterest> UserInterests => Set<UserInterest>();

    public DbSet<OAuthIdentity> OAuthIdentities => Set<OAuthIdentity>();

    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();

    public DbSet<Event> Events => Set<Event>();

    public DbSet<EventAttendee> EventAttendees => Set<EventAttendee>();

    public DbSet<EventInterest> EventInterests => Set<EventInterest>();

    public DbSet<Trip> Trips => Set<Trip>();

    public DbSet<TripMember> TripMembers => Set<TripMember>();

    public DbSet<TripJoinRequest> TripJoinRequests => Set<TripJoinRequest>();

    public DbSet<Review> Reviews => Set<Review>();

    public DbSet<BlockedUser> BlockedUsers => Set<BlockedUser>();

    public DbSet<PushPreferences> PushPreferences => Set<PushPreferences>();

    public DbSet<Report> Reports => Set<Report>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(FelloWayDbContext).Assembly);
        base.OnModelCreating(modelBuilder);
    }
}
