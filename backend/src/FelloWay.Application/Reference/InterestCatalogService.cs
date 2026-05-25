using FelloWay.Application.Common.Interfaces;
using FelloWay.Application.Reference.Models;
using Microsoft.EntityFrameworkCore;

namespace FelloWay.Application.Reference;

public class InterestCatalogService(IApplicationDbContext db) : IInterestCatalogService
{
    public async Task<IReadOnlyList<InterestCatalogItemDto>> GetAllAsync(
        CancellationToken cancellationToken = default) =>
        await db.Interests
            .OrderBy(i => i.SortOrder)
            .Select(i => new InterestCatalogItemDto(i.Id, i.Name, i.SortOrder))
            .ToListAsync(cancellationToken);
}
