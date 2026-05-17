using FelloWay.Application.Common.Interfaces;
using FelloWay.Application.Users;
using FelloWay.Application.Users.Models;
using FluentValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FelloWay.Api.Controllers;

[ApiController]
[Authorize]
[Route("users")]
public class UsersController(
    IUserProfileService userProfileService,
    IUserTrustService userTrustService,
    ICurrentUserService currentUser,
    IValidator<UpdateUserProfileRequest> updateValidator) : ControllerBase
{
    public sealed record UpdateUserProfileBody(
        string? DisplayName,
        string? Bio,
        Guid? HomeCityId,
        List<Guid>? InterestIds);

    [HttpGet("me")]
    public async Task<ActionResult<UserProfileDto>> GetMe(CancellationToken cancellationToken)
    {
        if (!currentUser.UserId.HasValue)
        {
            return Unauthorized();
        }

        return Ok(await userProfileService.GetCurrentAsync(currentUser.UserId.Value, cancellationToken));
    }

    [HttpPut("me")]
    public async Task<ActionResult<UserProfileDto>> UpdateMe(
        [FromBody] UpdateUserProfileBody body,
        CancellationToken cancellationToken)
    {
        if (!currentUser.UserId.HasValue)
        {
            return Unauthorized();
        }

        var request = new UpdateUserProfileRequest(
            body.DisplayName,
            body.Bio,
            body.HomeCityId,
            body.InterestIds);

        await updateValidator.ValidateAndThrowAsync(request, cancellationToken);
        var profile = await userProfileService.UpdateCurrentAsync(
            currentUser.UserId.Value,
            request,
            cancellationToken);
        return Ok(profile);
    }

    [HttpPost("me/avatar")]
    [RequestSizeLimit(5 * 1024 * 1024)]
    public async Task<ActionResult<object>> UploadAvatar(IFormFile file, CancellationToken cancellationToken)
    {
        if (!currentUser.UserId.HasValue)
        {
            return Unauthorized();
        }

        if (file.Length == 0)
        {
            return BadRequest(new { message = "File is required." });
        }

        await using var stream = file.OpenReadStream();
        var url = await userProfileService.UploadAvatarAsync(
            currentUser.UserId.Value,
            stream,
            file.ContentType,
            cancellationToken);
        return Ok(new { avatarUrl = url });
    }

    [HttpPost("{id:guid}/block")]
    public async Task<IActionResult> BlockUser(Guid id, CancellationToken cancellationToken)
    {
        if (!currentUser.UserId.HasValue)
        {
            return Unauthorized();
        }

        await userTrustService.BlockUserAsync(currentUser.UserId.Value, id, cancellationToken);
        return NoContent();
    }

    [HttpGet("{id:guid}/reviews")]
    public async Task<ActionResult<object>> ListReviews(Guid id, CancellationToken cancellationToken)
    {
        var items = await userTrustService.ListReviewsForUserAsync(id, cancellationToken);
        return Ok(new
        {
            items = items.Select(r => new
            {
                id = r.Id,
                authorId = r.AuthorId,
                authorLabel = r.AuthorLabel,
                rating = r.Rating,
                comment = r.Comment,
                eventTitle = r.EventTitle,
                createdAt = r.CreatedAt,
            }),
        });
    }

    public sealed record PushPreferencesBody(
        bool GlobalEnabled,
        bool EventMessages,
        bool TripMessages,
        bool DirectMessages);

    [HttpPut("me/push-preferences")]
    public async Task<IActionResult> UpdatePushPreferences(
        [FromBody] PushPreferencesBody body,
        CancellationToken cancellationToken)
    {
        if (!currentUser.UserId.HasValue)
        {
            return Unauthorized();
        }

        await userTrustService.UpdatePushPreferencesAsync(
            currentUser.UserId.Value,
            new PushPreferencesDto(
                body.GlobalEnabled,
                body.EventMessages,
                body.TripMessages,
                body.DirectMessages),
            cancellationToken);
        return NoContent();
    }
}
