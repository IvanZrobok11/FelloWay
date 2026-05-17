using FelloWay.Api.Extensions;
using FelloWay.Api.Middleware;
using FelloWay.Api.Services;
using FelloWay.Application;
using FelloWay.Application.Common.Interfaces;
using FelloWay.Infrastructure;
using FelloWay.Infrastructure.Jobs;
using FluentValidation;
using Hangfire;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddFelloWaySwagger();
builder.Services.AddHttpContextAccessor();

builder.Services.AddApplication();
builder.Services.AddInfrastructure(builder.Configuration, builder.Environment);
builder.Services.AddScoped<ICurrentUserService, CurrentUserService>();
builder.Services.AddJwtAuthentication(builder.Configuration);
builder.Services.AddValidatorsFromAssemblyContaining<Program>();

builder.Services.AddFelloWayHealthChecks();

var app = builder.Build();

// Database must exist before Hangfire dashboard/storage connects.
await app.ApplyDatabaseAsync();

var wwwroot = Path.Combine(app.Environment.ContentRootPath, "wwwroot");
Directory.CreateDirectory(Path.Combine(wwwroot, "avatars"));
app.UseStaticFiles();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
    app.UseHangfireDashboard("/hangfire");
}

app.UseMiddleware<CorrelationIdMiddleware>();
app.UseMiddleware<ExceptionHandlingMiddleware>();
app.UseAuthentication();
app.UseAuthorization();
app.MapFelloWayHealthChecks();
app.MapControllers();

if (app.Environment.IsDevelopment())
{
    RecurringJob.AddOrUpdate<PostEventReviewReminderJob>(
        "post-event-review-reminder",
        job => job.RunAsync(CancellationToken.None),
        Cron.Daily);
}

app.Run();

public partial class Program;
