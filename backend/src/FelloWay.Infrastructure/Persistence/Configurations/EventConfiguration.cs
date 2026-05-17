using FelloWay.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FelloWay.Infrastructure.Persistence.Configurations;

public class EventConfiguration : IEntityTypeConfiguration<Event>
{
    public void Configure(EntityTypeBuilder<Event> builder)
    {
        builder.ToTable("events");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Title).HasMaxLength(200).IsRequired();
        builder.Property(x => x.Venue).HasMaxLength(200);
        builder.Property(x => x.CoverImageUrl).HasMaxLength(512);
        builder.Property(x => x.OfficialUrl).HasMaxLength(512);
        builder.Property(x => x.Status).HasConversion<string>().HasMaxLength(20);
        builder.HasOne(x => x.City).WithMany().HasForeignKey(x => x.CityId);
        builder.HasIndex(x => new { x.Status, x.StartsAt });
    }
}
