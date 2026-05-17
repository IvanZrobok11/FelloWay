using FelloWay.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FelloWay.Infrastructure.Persistence.Configurations;

public class TripJoinRequestConfiguration : IEntityTypeConfiguration<TripJoinRequest>
{
    public void Configure(EntityTypeBuilder<TripJoinRequest> builder)
    {
        builder.ToTable("trip_join_requests");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Status).HasConversion<string>().HasMaxLength(20);
        builder.HasOne(x => x.Trip).WithMany(t => t.JoinRequests).HasForeignKey(x => x.TripId);
        builder.HasOne(x => x.Requester).WithMany().HasForeignKey(x => x.RequesterUserId);
        builder.HasOne(x => x.RequesterCity).WithMany().HasForeignKey(x => x.RequesterCityId);
        builder.HasIndex(x => new { x.TripId, x.Status });
    }
}
