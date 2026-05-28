using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Http;

namespace FelloWay.Admin.Pages.Events;

public sealed class EventFormInput
{
    [Required]
    public string Title { get; set; } = string.Empty;

    public string? Description { get; set; }

    [Required]
    public DateTimeOffset StartsAt { get; set; }

    [Required]
    public DateTimeOffset EndsAt { get; set; }

    [Required]
    public Guid CityId { get; set; }

    public string? Venue { get; set; }

    public int? Capacity { get; set; }

    public string? OfficialUrl { get; set; }

    public string Status { get; set; } = "active";

    public IFormFile? CoverFile { get; set; }
}
