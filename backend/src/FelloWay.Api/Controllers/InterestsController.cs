using FelloWay.Application.Reference;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FelloWay.Api.Controllers;

[ApiController]
[AllowAnonymous]
[Route("interests")]
public class InterestsController(IInterestCatalogService interestCatalogService) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<object>> GetAll(CancellationToken cancellationToken)
    {
        var items = await interestCatalogService.GetAllAsync(cancellationToken);
        return Ok(new
        {
            items = items.Select(i => new
            {
                id = i.Id,
                name = i.Name,
                sortOrder = i.SortOrder,
            }),
        });
    }
}
