using FelloWay.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FelloWay.Infrastructure.Persistence.Configurations;

public class TripConfiguration : IEntityTypeConfiguration<Trip>
{
    public void Configure(EntityTypeBuilder<Trip> builder)
    {
        builder.ToTable("trips");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.RouteLabel).HasMaxLength(200).IsRequired();
        builder.Property(x => x.RoleType).HasMaxLength(32).IsRequired();
        builder.Property(x => x.StreamChannelId).HasMaxLength(64);
        builder.HasOne(x => x.Event).WithMany().HasForeignKey(x => x.EventId);
        builder.HasOne(x => x.Creator).WithMany().HasForeignKey(x => x.CreatorUserId);
        builder.HasOne(x => x.OriginCity).WithMany().HasForeignKey(x => x.OriginCityId);
        builder.HasIndex(x => x.EventId);
    }
}
