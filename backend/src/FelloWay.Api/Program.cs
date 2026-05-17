using FelloWay.Api.Extensions;
using FelloWay.Api.Middleware;
using FelloWay.Api.Services;
using FelloWay.Application;
using FelloWay.Application.Common.Interfaces;
using FelloWay.Infrastructure;
using FelloWay.Infrastructure.Jobs;
using FelloWay.Infrastructure.Persistence;
using FelloWay.Infrastructure.Persistence.Seed;
using FluentValidation;
using Hangfire;
using Microsoft.EntityFrameworkCore;

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

var wwwroot = Path.Combine(app.Environment.ContentRootPath, "wwwroot");
Directory.CreateDirectory(Path.Combine(wwwroot, "avatars"));
app.UseStaticFiles();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
    if (!app.Environment.IsEnvironment("Testing"))
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

if (app.Environment.IsDevelopment())
{
    using var scope = app.Services.CreateScope();
    var db = scope.ServiceProvider.GetRequiredService<FelloWayDbContext>();
    await db.Database.MigrateAsync();
    var seeder = scope.ServiceProvider.GetRequiredService<IDataSeeder>();
    await seeder.SeedAsync();

    if (!app.Environment.IsEnvironment("Testing"))
    {
        RecurringJob.AddOrUpdate<PostEventReviewReminderJob>(
            "post-event-review-reminder",
            job => job.RunAsync(CancellationToken.None),
            Cron.Daily);
    }
}

app.Run();

public partial class Program;
