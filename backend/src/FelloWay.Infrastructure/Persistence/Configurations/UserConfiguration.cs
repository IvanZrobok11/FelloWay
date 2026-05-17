using FelloWay.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FelloWay.Infrastructure.Persistence.Configurations;

public class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        builder.ToTable("users");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.DisplayName).HasMaxLength(120);
        builder.Property(x => x.Bio);
        builder.Property(x => x.AvatarUrl).HasMaxLength(512);
        builder.Property(x => x.AggregateRating).HasPrecision(3, 2);
        builder.Property(x => x.Role).HasConversion<string>().HasMaxLength(20);
        builder.HasOne(x => x.HomeCity).WithMany().HasForeignKey(x => x.HomeCityId);
    }
}
