using FelloWay.Application.Admin;
using FelloWay.Application.Auth;
using FelloWay.Application.Events;
using FelloWay.Application.Trips;
using FelloWay.Application.Users;
using FelloWay.Application.Validators;
using FluentValidation;
using Microsoft.Extensions.DependencyInjection;

namespace FelloWay.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddValidatorsFromAssemblyContaining<OAuthTokenRequestValidator>();
        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<IUserProfileService, UserProfileService>();
        services.AddScoped<IEventService, EventService>();
        services.AddScoped<ITripService, TripService>();
        services.AddScoped<IUserTrustService, UserTrustService>();
        services.AddScoped<IAdminModerationService, AdminModerationService>();
        return services;
    }
}
