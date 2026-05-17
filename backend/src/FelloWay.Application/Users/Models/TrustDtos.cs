namespace FelloWay.Application.Users.Models;

public sealed record ReviewDto(
    Guid Id,
    Guid AuthorId,
    string? AuthorLabel,
    int Rating,
    string? Comment,
    string? EventTitle,
    DateTimeOffset CreatedAt);

public sealed record PushPreferencesDto(
    bool GlobalEnabled,
    bool EventMessages,
    bool TripMessages,
    bool DirectMessages);

public sealed record SubmitReviewRequest(int Rating, string? Comment);

public sealed record AdminEventSummaryDto(
    Guid Id,
    string Title,
    DateTimeOffset StartsAt,
    string City,
    string Status);

public sealed record AdminReportDto(
    Guid Id,
    Guid ReporterId,
    string TargetType,
    string TargetId,
    string Reason,
    string Status,
    DateTimeOffset CreatedAt);
