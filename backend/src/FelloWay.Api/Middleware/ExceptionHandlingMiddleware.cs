using System.Net;
using System.Text.Json;
using FelloWay.Api.Models;
using FelloWay.Domain.Common;
using FluentValidation;

namespace FelloWay.Api.Middleware;

public class ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
{
    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web);

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await next(context);
        }
        catch (ValidationException ex)
        {
            logger.LogWarning(ex, "Validation error");
            var details = ex.Errors
                .Select(e => new FieldError { Field = e.PropertyName, Message = e.ErrorMessage })
                .ToList();
            await WriteValidationErrorAsync(context, details);
        }
        catch (NotFoundException ex)
        {
            logger.LogWarning(ex, "Not found");
            await WriteErrorAsync(context, HttpStatusCode.NotFound, "not_found", ex.Message);
        }
        catch (DomainException ex)
        {
            logger.LogWarning(ex, "Domain error");
            await WriteErrorAsync(context, HttpStatusCode.BadRequest, "domain_error", ex.Message);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Unhandled error");
            await WriteErrorAsync(context, HttpStatusCode.InternalServerError, "internal_error", "An unexpected error occurred.");
        }
    }

    private static async Task WriteErrorAsync(
        HttpContext context,
        HttpStatusCode status,
        string code,
        string message)
    {
        if (context.Response.HasStarted)
        {
            return;
        }

        context.Response.StatusCode = (int)status;
        context.Response.ContentType = "application/json";
        var body = new ErrorResponse { Code = code, Message = message };
        await context.Response.WriteAsync(JsonSerializer.Serialize(body, JsonOptions));
    }

    private static async Task WriteValidationErrorAsync(HttpContext context, IReadOnlyList<FieldError> details)
    {
        if (context.Response.HasStarted)
        {
            return;
        }

        context.Response.StatusCode = (int)HttpStatusCode.BadRequest;
        context.Response.ContentType = "application/json";
        var body = new ErrorResponse
        {
            Code = "validation_failed",
            Message = "Validation failed.",
            Details = details,
        };
        await context.Response.WriteAsync(JsonSerializer.Serialize(body, JsonOptions));
    }
}
