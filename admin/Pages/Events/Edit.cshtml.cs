using FelloWay.Admin.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Mvc.Rendering;

namespace FelloWay.Admin.Pages.Events;

[Authorize]
public class EditModel(AdminApiClient apiClient) : PageModel
{
    [BindProperty]
    public EventFormInput Input { get; set; } = new();

    public IReadOnlyList<AdminCityItem> Cities { get; private set; } = Array.Empty<AdminCityItem>();

    public string? CurrentCoverUrl { get; private set; }

    public string? ErrorMessage { get; private set; }

    public async Task<IActionResult> OnGetAsync(Guid id)
    {
        await LoadCitiesAsync();
        try
        {
            var detail = await apiClient.GetEventAsync(id, HttpContext.RequestAborted);
            MapFromDetail(detail);
            PopulateCitySelect();
            return Page();
        }
        catch (Exception)
        {
            ErrorMessage = "Event not found or API unavailable.";
            return Page();
        }
    }

    public async Task<IActionResult> OnPostAsync(Guid id)
    {
        await LoadCitiesAsync();
        PopulateCitySelect();
        if (string.IsNullOrWhiteSpace(Input.Title))
        {
            ModelState.AddModelError($"{nameof(Input)}.{nameof(Input.Title)}", "Title is required.");
        }

        if (Input.EndsAt <= Input.StartsAt)
        {
            ModelState.AddModelError($"{nameof(Input)}.{nameof(Input.EndsAt)}", "End must be after start.");
        }

        if (!ModelState.IsValid)
        {
            return Page();
        }

        try
        {
            await apiClient.UpdateEventAsync(
                id,
                new AdminEventUpdatePayload(
                    Input.Title.Trim(),
                    Input.Description,
                    Input.StartsAt,
                    Input.EndsAt,
                    Input.CityId,
                    Input.Venue,
                    Input.Capacity,
                    Input.OfficialUrl,
                    Input.Status),
                HttpContext.RequestAborted);

            if (Input.CoverFile is { Length: > 0 })
            {
                await using var stream = Input.CoverFile.OpenReadStream();
                CurrentCoverUrl = await apiClient.UploadCoverAsync(
                    id,
                    stream,
                    Input.CoverFile.FileName,
                    Input.CoverFile.ContentType,
                    HttpContext.RequestAborted);
            }

            TempData["StatusMessage"] = "Event updated.";
            return RedirectToPage("Index");
        }
        catch (Exception)
        {
            ErrorMessage = "Could not save the event.";
            return Page();
        }
    }

    private async Task LoadCitiesAsync()
    {
        try
        {
            Cities = await apiClient.GetCitiesAsync(HttpContext.RequestAborted);
        }
        catch (Exception)
        {
            Cities = Array.Empty<AdminCityItem>();
        }
    }

    private void PopulateCitySelect()
    {
        ViewData["Cities"] = Cities
            .Select(c => new SelectListItem(c.Name, c.Id.ToString(), c.Id == Input.CityId))
            .ToList();
    }

    private void MapFromDetail(AdminEventDetail detail)
    {
        Input.Title = detail.Title;
        Input.Description = detail.Description;
        Input.StartsAt = detail.StartsAt;
        Input.EndsAt = detail.EndsAt;
        Input.CityId = detail.CityId;
        Input.Venue = detail.Venue;
        Input.Capacity = detail.Capacity;
        Input.OfficialUrl = detail.OfficialUrl;
        Input.Status = detail.Status;
        CurrentCoverUrl = detail.CoverImageUrl;
    }
}
