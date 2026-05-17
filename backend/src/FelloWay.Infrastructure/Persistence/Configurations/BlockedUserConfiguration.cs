using FelloWay.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FelloWay.Infrastructure.Persistence.Configurations;

public class BlockedUserConfiguration : IEntityTypeConfiguration<BlockedUser>
{
    public void Configure(EntityTypeBuilder<BlockedUser> builder)
    {
        builder.ToTable("blocked_users");
        builder.HasKey(x => new { x.BlockerUserId, x.BlockedUserId });
        builder.HasOne(x => x.Blocker).WithMany().HasForeignKey(x => x.BlockerUserId);
        builder.HasOne(x => x.Blocked).WithMany().HasForeignKey(x => x.BlockedUserId);
    }
}
