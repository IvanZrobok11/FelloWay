using FelloWay.Application.Users.Models;
using FluentValidation;

namespace FelloWay.Application.Validators;

public class UpdateUserProfileRequestValidator : AbstractValidator<UpdateUserProfileRequest>
{
    public UpdateUserProfileRequestValidator()
    {
        RuleFor(x => x.DisplayName).MaximumLength(120).When(x => x.DisplayName is not null);
        RuleFor(x => x.Bio).MaximumLength(2000).When(x => x.Bio is not null);
    }
}
