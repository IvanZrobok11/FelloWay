using System.ComponentModel.DataAnnotations;
using System.Security.Claims;
using FelloWay.Admin.Services;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace FelloWay.Admin.Pages;

[AllowAnonymous]
[IgnoreAntiforgeryToken]
public class LoginModel(AdminCredentialValidator credentialValidator) : PageModel
{
    [BindProperty]
    public LoginInput Input { get; set; } = new();

    public string? ErrorMessage { get; private set; }

    public IActionResult OnGet()
    {
        if (User.Identity?.IsAuthenticated == true)
        {
            return RedirectToPage("/Index");
        }

        return Page();
    }

    public async Task<IActionResult> OnPostAsync()
    {
        if (!ModelState.IsValid)
        {
            return Page();
        }

        if (!credentialValidator.Validate(Input.Username, Input.Password))
        {
            ErrorMessage = "Invalid username or password.";
            return Page();
        }

        var claims = new[]
        {
            new Claim(ClaimTypes.Name, Input.Username),
            new Claim(ClaimTypes.Role, "admin-operator"),
        };
        var identity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
        var principal = new ClaimsPrincipal(identity);
        await HttpContext.SignInAsync(
            CookieAuthenticationDefaults.AuthenticationScheme,
            principal,
            new AuthenticationProperties
            {
                IsPersistent = false,
                ExpiresUtc = DateTimeOffset.UtcNow.AddHours(8),
            });

        return RedirectToPage("/Index");
    }

    public sealed class LoginInput
    {
        [Required]
        public string Username { get; set; } = string.Empty;

        [Required]
        [DataType(DataType.Password)]
        public string Password { get; set; } = string.Empty;
    }
}
