using FelloWay.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace FelloWay.Infrastructure.Persistence.Seed;

public static class InterestCatalogSeed
{
    public sealed record CatalogEntry(Guid Id, string Name, int SortOrder);

    public static readonly CatalogEntry[] Catalog =
    [
        new(Guid.Parse("11111111-1111-1111-1111-111111110001"), "ІТ та розробка", 1),
        new(Guid.Parse("11111111-1111-1111-1111-111111110002"), "Маркетинг/Продажі", 2),
        new(Guid.Parse("11111111-1111-1111-1111-111111110003"), "HR та рекрутинг", 3),
        new(Guid.Parse("11111111-1111-1111-1111-111111110004"), "Дизайн та візуалізація", 4),
        new(Guid.Parse("11111111-1111-1111-1111-111111110005"), "Освіта та навчання", 5),
        new(Guid.Parse("11111111-1111-1111-1111-111111110006"), "Здоров'я та медицина", 6),
        new(Guid.Parse("11111111-1111-1111-1111-111111110007"), "Розвиток бізнесу", 7),
        new(Guid.Parse("11111111-1111-1111-1111-111111110008"), "Логістика та ритейл", 8),
        new(Guid.Parse("11111111-1111-1111-1111-111111110009"), "Інвестиції та фінанси", 9),
        new(Guid.Parse("11111111-1111-1111-1111-11111111000a"), "Мілітарі", 10),
    ];

    public static CatalogEntry BySortOrder(int sortOrder) =>
        Catalog.First(e => e.SortOrder == sortOrder);

    /// <summary>
    /// Ensures exactly the canonical catalog exists. Idempotent when already applied.
    /// </summary>
    public static async Task ApplyAsync(FelloWayDbContext db, CancellationToken cancellationToken = default)
    {
        if (await IsCatalogAppliedAsync(db, cancellationToken))
        {
            return;
        }

        db.EventInterests.RemoveRange(await db.EventInterests.ToListAsync(cancellationToken));
        db.UserInterests.RemoveRange(await db.UserInterests.ToListAsync(cancellationToken));
        db.Interests.RemoveRange(await db.Interests.ToListAsync(cancellationToken));
        await db.SaveChangesAsync(cancellationToken);

        foreach (var entry in Catalog)
        {
            db.Interests.Add(new Interest
            {
                Id = entry.Id,
                Name = entry.Name,
                SortOrder = entry.SortOrder,
            });
        }

        await db.SaveChangesAsync(cancellationToken);
    }

    public static async Task<bool> IsCatalogAppliedAsync(
        FelloWayDbContext db,
        CancellationToken cancellationToken = default)
    {
        if (await db.Interests.CountAsync(cancellationToken) != Catalog.Length)
        {
            return false;
        }

        var ids = await db.Interests.Select(i => i.Id).ToListAsync(cancellationToken);
        return Catalog.All(e => ids.Contains(e.Id));
    }
}
