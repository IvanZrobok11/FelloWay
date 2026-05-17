using FelloWay.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FelloWay.Infrastructure.Persistence.Configurations;

public class EventInterestConfiguration : IEntityTypeConfiguration<EventInterest>
{
    public void Configure(EntityTypeBuilder<EventInterest> builder)
    {
        builder.ToTable("event_interests");
        builder.HasKey(x => new { x.EventId, x.InterestId });
        builder.HasOne(x => x.Event).WithMany(e => e.EventInterests).HasForeignKey(x => x.EventId);
        builder.HasOne(x => x.Interest).WithMany().HasForeignKey(x => x.InterestId);
    }
}
