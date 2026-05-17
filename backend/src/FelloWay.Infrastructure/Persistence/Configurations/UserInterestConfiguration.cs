using FelloWay.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FelloWay.Infrastructure.Persistence.Configurations;

public class UserInterestConfiguration : IEntityTypeConfiguration<UserInterest>
{
    public void Configure(EntityTypeBuilder<UserInterest> builder)
    {
        builder.ToTable("user_interests");
        builder.HasKey(x => new { x.UserId, x.InterestId });
        builder.HasOne(x => x.User).WithMany(x => x.UserInterests).HasForeignKey(x => x.UserId);
        builder.HasOne(x => x.Interest).WithMany(x => x.UserInterests).HasForeignKey(x => x.InterestId);
    }
}
