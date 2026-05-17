using FelloWay.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FelloWay.Infrastructure.Persistence.Configurations;

public class PushPreferencesConfiguration : IEntityTypeConfiguration<PushPreferences>
{
    public void Configure(EntityTypeBuilder<PushPreferences> builder)
    {
        builder.ToTable("push_preferences");
        builder.HasKey(x => x.UserId);
        builder.HasOne(x => x.User).WithMany().HasForeignKey(x => x.UserId);
    }
}
