using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using FelloWay.Application.Common.Interfaces;
using FelloWay.Domain.Enums;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;

namespace FelloWay.Infrastructure.Auth;

public class JwtTokenService(IConfiguration configuration) : IJwtTokenService
{
    public string CreateAccessToken(Guid userId, UserRole role, out int expiresInSeconds)
    {
        expiresInSeconds = 3600;
        var signingKey = configuration["Jwt:SigningKey"]
            ?? "felloway-dev-signing-key-change-in-production-min-32-chars!!";
        var credentials = new SigningCredentials(
            new SymmetricSecurityKey(Encoding.UTF8.GetBytes(signingKey)),
            SecurityAlgorithms.HmacSha256);

        var claims = new List<Claim> { new(ClaimTypes.NameIdentifier, userId.ToString()) };
        if (role == UserRole.Admin)
        {
            claims.Add(new Claim(ClaimTypes.Role, "admin"));
        }

        var token = new JwtSecurityToken(
            issuer: configuration["Jwt:Issuer"] ?? "felloway",
            audience: configuration["Jwt:Audience"] ?? "felloway-mobile",
            claims: claims,
            expires: DateTime.UtcNow.AddSeconds(expiresInSeconds),
            signingCredentials: credentials);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
