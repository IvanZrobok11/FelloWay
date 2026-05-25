using FelloWay.Application.Reference.Models;

namespace FelloWay.Application.Reference;

public interface IInterestCatalogService
{
    Task<IReadOnlyList<InterestCatalogItemDto>> GetAllAsync(CancellationToken cancellationToken = default);
}
