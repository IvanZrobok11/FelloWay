namespace FelloWay.Api.Models;

public sealed class ErrorResponse
{
    public required string Code { get; init; }

    public required string Message { get; init; }

    public IReadOnlyList<FieldError>? Details { get; init; }
}

public sealed class FieldError
{
    public string? Field { get; init; }

    public string? Message { get; init; }
}
