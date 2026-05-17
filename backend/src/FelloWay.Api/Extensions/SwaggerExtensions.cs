using FelloWay.Api.OpenApi;
using Microsoft.OpenApi.Models;

namespace FelloWay.Api.Extensions;

public static class SwaggerExtensions
{
    public static IServiceCollection AddFelloWaySwagger(this IServiceCollection services)
    {
        services.AddSwaggerGen(options =>
        {
            options.SwaggerDoc(
                "v1",
                new OpenApiInfo
                {
                    Title = "FelloWay API",
                    Version = "v1",
                    Description =
                        "FelloWay mobile backend. Contract paths merged from shared/api-contracts. " +
                        "Optional request header: X-Api-Version: 1 (MVP paths are unversioned).",
                });

            options.AddSecurityDefinition(
                "Bearer",
                new OpenApiSecurityScheme
                {
                    Description = "JWT access token",
                    Name = "Authorization",
                    In = ParameterLocation.Header,
                    Type = SecuritySchemeType.Http,
                    Scheme = "bearer",
                    BearerFormat = "JWT",
                });

            options.AddSecurityRequirement(new OpenApiSecurityRequirement
            {
                {
                    new OpenApiSecurityScheme
                    {
                        Reference = new OpenApiReference
                        {
                            Type = ReferenceType.SecurityScheme,
                            Id = "Bearer",
                        },
                    },
                    Array.Empty<string>()
                },
            });

            options.DocumentFilter<SharedContractsDocumentFilter>();
        });

        return services;
    }
}
