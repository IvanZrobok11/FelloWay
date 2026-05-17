using FelloWay.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FelloWay.Infrastructure.Persistence.Configurations;

public class ReviewConfiguration : IEntityTypeConfiguration<Review>
{
    public void Configure(EntityTypeBuilder<Review> builder)
    {
        builder.ToTable("reviews");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Comment);
        builder.HasOne(x => x.SubjectUser).WithMany().HasForeignKey(x => x.SubjectUserId);
        builder.HasOne(x => x.AuthorUser).WithMany().HasForeignKey(x => x.AuthorUserId);
        builder.HasOne(x => x.Event).WithMany().HasForeignKey(x => x.EventId);
        builder.HasIndex(x => x.SubjectUserId);
    }
}
