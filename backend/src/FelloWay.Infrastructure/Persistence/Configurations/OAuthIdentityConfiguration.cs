using FelloWay.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FelloWay.Infrastructure.Persistence.Configurations;

public class OAuthIdentityConfiguration : IEntityTypeConfiguration<OAuthIdentity>
{
    public void Configure(EntityTypeBuilder<OAuthIdentity> builder)
    {
        builder.ToTable("oauth_identities");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Provider).HasMaxLength(32).IsRequired();
        builder.Property(x => x.ProviderSubject).HasMaxLength(256).IsRequired();
        builder.HasIndex(x => new { x.Provider, x.ProviderSubject }).IsUnique();
        builder.HasOne(x => x.User).WithMany(x => x.OAuthIdentities).HasForeignKey(x => x.UserId);
    }
}
