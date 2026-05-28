using FelloWay.Admin.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace FelloWay.Admin.Pages.Events;

[Authorize]
public class IndexModel(AdminApiClient apiClient) : PageModel
{
    public IReadOnlyList<AdminEventListItem> Events { get; private set; } = Array.Empty<AdminEventListItem>();

    [TempData]
    public string? StatusMessage { get; set; }

    public string? ErrorMessage { get; private set; }

    public async Task OnGetAsync()
    {
        try
        {
            Events = await apiClient.GetEventsAsync(HttpContext.RequestAborted);
        }
        catch (Exception)
        {
            ErrorMessage = "Could not load events from the API.";
        }
    }
}
