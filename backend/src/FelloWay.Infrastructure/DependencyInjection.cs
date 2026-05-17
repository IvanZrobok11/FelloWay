using FelloWay.Application.Auth;
using FelloWay.Application.Common.Interfaces;
using FelloWay.Application.Users;
using FelloWay.Infrastructure.Auth;
using FelloWay.Infrastructure.Jobs;
using FelloWay.Infrastructure.Notifications;
using FelloWay.Infrastructure.Persistence;
using FelloWay.Infrastructure.Persistence.Seed;
using FelloWay.Infrastructure.Storage;
using FelloWay.Infrastructure.Stream;
using Hangfire;
using Hangfire.PostgreSql;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

namespace FelloWay.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration,
        IHostEnvironment environment)
    {
        var connectionString = configuration.GetConnectionString("Default")
            ?? "Host=localhost;Database=felloway;Username=postgres;Password=postgres";

        services.AddDbContext<FelloWayDbContext>(options =>
            options.UseNpgsql(connectionString));

        services.AddScoped<IApplicationDbContext>(sp => sp.GetRequiredService<FelloWayDbContext>());
        services.AddScoped<IDataSeeder, DataSeeder>();

        services.AddSingleton<IJwtTokenService, JwtTokenService>();
        services.AddSingleton<IRefreshTokenService, RefreshTokenService>();
        services.AddScoped<IOAuthTokenExchanger, DevOAuthTokenExchanger>();
        services.AddScoped<IStreamChatService, DevStreamChatService>();
        services.AddScoped<IEventChannelSyncService, DevEventChannelSyncService>();
        services.AddScoped<ITripChannelSyncService, DevTripChannelSyncService>();

        var avatarRoot = Path.Combine(environment.ContentRootPath, "wwwroot", "avatars");
        services.Configure<BlobStorageOptions>(opts =>
        {
            opts.AvatarRootPath = avatarRoot;
            opts.PublicBasePath = "/avatars";
        });
        services.AddScoped<IBlobStorageService, LocalBlobStorageService>();
        services.AddSingleton<CustomPushDispatcher>();
        services.AddScoped<PostEventReviewReminderJob>();

        if (!environment.IsEnvironment("Testing"))
        {
            services.AddHangfire(config => config
                .SetDataCompatibilityLevel(CompatibilityLevel.Version_180)
                .UseSimpleAssemblyNameTypeSerializer()
                .UseRecommendedSerializerSettings()
                .UsePostgreSqlStorage(options => options.UseNpgsqlConnection(connectionString)));
            services.AddHangfireServer();
        }

        return services;
    }
}
