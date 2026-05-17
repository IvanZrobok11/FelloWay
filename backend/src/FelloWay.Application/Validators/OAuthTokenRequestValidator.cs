using FelloWay.Application.Auth.Models;
using FluentValidation;

namespace FelloWay.Application.Validators;

public sealed class OAuthTokenRequestValidator : AbstractValidator<OAuthTokenRequest>
{
    public OAuthTokenRequestValidator()
    {
        RuleFor(x => x.Provider).NotEmpty();
        RuleFor(x => x.Code).NotEmpty();
        RuleFor(x => x.RedirectUri).NotEmpty();
        RuleFor(x => x.CodeVerifier).NotEmpty();
    }
}
