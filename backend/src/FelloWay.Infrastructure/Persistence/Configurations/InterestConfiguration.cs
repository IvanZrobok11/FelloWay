using FelloWay.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FelloWay.Infrastructure.Persistence.Configurations;

public class InterestConfiguration : IEntityTypeConfiguration<Interest>
{
    public void Configure(EntityTypeBuilder<Interest> builder)
    {
        builder.ToTable("interests");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Name).HasMaxLength(80).IsRequired();
        builder.Property(x => x.SortOrder).IsRequired();
        builder.HasIndex(x => x.SortOrder);
    }
}
