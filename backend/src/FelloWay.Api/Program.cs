using FelloWay.Api.Extensions;
using FelloWay.Api.Middleware;
using FelloWay.Api.Options;
using FelloWay.Api.Services;
using FelloWay.Application;
using FelloWay.Application.Common.Interfaces;
using FelloWay.Infrastructure;
using FelloWay.Infrastructure.Jobs;
using FluentValidation;
using Hangfire;

var builder = WebApplication.CreateBuilder(args);

builder.Services.Configure<FrontendOptions>(builder.Configuration.GetSection(FrontendOptions.SectionName));
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddFelloWaySwagger();
builder.Services.AddHttpContextAccessor();

builder.Services.AddApplication();
builder.Services.AddInfrastructure(builder.Configuration, builder.Environment);
builder.Services.AddScoped<ICurrentUserService, CurrentUserService>();
builder.Services.AddFelloWayAuthentication(builder.Configuration, builder.Environment);
builder.Services.AddValidatorsFromAssemblyContaining<Program>();

builder.Services.AddFelloWayHealthChecks();
builder.Services.AddFelloWayCors(builder.Configuration, builder.Environment);

var app = builder.Build();

// Database must exist before Hangfire dashboard/storage connects.
await app.ApplyDatabaseAsync();

var wwwroot = Path.Combine(app.Environment.ContentRootPath, "wwwroot");
Directory.CreateDirectory(Path.Combine(wwwroot, "avatars"));
app.UseStaticFiles();
app.UseCors(CorsExtensions.PolicyName);

var hangfireEnabled = !app.Configuration.GetValue("Database:DisableHangfire", false);

if (!app.Environment.IsProdLike())
{
    app.UseSwagger();
    app.UseSwaggerUI();
    if (hangfireEnabled)
    {
        app.UseHangfireDashboard("/hangfire");
    }
}

app.UseMiddleware<CorrelationIdMiddleware>();
app.UseMiddleware<ExceptionHandlingMiddleware>();
app.UseAuthentication();
app.UseAuthorization();
app.MapFelloWayHealthChecks();
app.MapControllers();

if (!app.Environment.IsProdLike() && hangfireEnabled)
{
    RecurringJob.AddOrUpdate<PostEventReviewReminderJob>(
        "post-event-review-reminder",
        job => job.RunAsync(CancellationToken.None),
        Cron.Daily);
}

app.Run();

public partial class Program;
