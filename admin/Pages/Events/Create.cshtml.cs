using FelloWay.Admin.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.AspNetCore.Mvc.Rendering;

namespace FelloWay.Admin.Pages.Events;

[Authorize]
public class CreateModel(AdminApiClient apiClient) : PageModel
{
    [BindProperty]
    public EventFormInput Input { get; set; } = new();

    public IReadOnlyList<AdminCityItem> Cities { get; private set; } = Array.Empty<AdminCityItem>();

    public string? ErrorMessage { get; private set; }

    public async Task<IActionResult> OnGetAsync()
    {
        await LoadCitiesAsync();
        PopulateCitySelect();
        if (Cities.Count > 0 && Input.CityId == Guid.Empty)
        {
            Input.CityId = Cities[0].Id;
        }

        var tomorrow = DateTimeOffset.UtcNow.Date.AddDays(1).AddHours(18);
        Input.StartsAt = tomorrow;
        Input.EndsAt = tomorrow.AddHours(3);
        return Page();
    }

    public async Task<IActionResult> OnPostAsync()
    {
        await LoadCitiesAsync();
        PopulateCitySelect();
        ValidateForm();
        if (!ModelState.IsValid)
        {
            return Page();
        }

        try
        {
            var id = await apiClient.CreateEventAsync(
                new AdminEventCreatePayload(
                    Input.Title.Trim(),
                    Input.Description,
                    Input.StartsAt,
                    Input.EndsAt,
                    Input.CityId,
                    Input.Venue,
                    Input.Capacity,
                    Input.OfficialUrl),
                HttpContext.RequestAborted);

            if (Input.CoverFile is { Length: > 0 })
            {
                await using var stream = Input.CoverFile.OpenReadStream();
                await apiClient.UploadCoverAsync(
                    id,
                    stream,
                    Input.CoverFile.FileName,
                    Input.CoverFile.ContentType,
                    HttpContext.RequestAborted);
            }

            TempData["StatusMessage"] = "Event created.";
            return RedirectToPage("Index");
        }
        catch (Exception)
        {
            ErrorMessage = "Could not create the event. Check API connectivity and validation.";
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
            ErrorMessage = "Could not load cities from the API.";
            Cities = Array.Empty<AdminCityItem>();
        }
    }

    private void PopulateCitySelect()
    {
        ViewData["Cities"] = Cities
            .Select(c => new SelectListItem(c.Name, c.Id.ToString(), c.Id == Input.CityId))
            .ToList();
    }

    private void ValidateForm()
    {
        if (string.IsNullOrWhiteSpace(Input.Title))
        {
            ModelState.AddModelError($"{nameof(Input)}.{nameof(Input.Title)}", "Title is required.");
        }

        if (Input.EndsAt <= Input.StartsAt)
        {
            ModelState.AddModelError($"{nameof(Input)}.{nameof(Input.EndsAt)}", "End must be after start.");
        }

        if (Input.CityId == Guid.Empty)
        {
            ModelState.AddModelError($"{nameof(Input)}.{nameof(Input.CityId)}", "City is required.");
        }
    }
}
