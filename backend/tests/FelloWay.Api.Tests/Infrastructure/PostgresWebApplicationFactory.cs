using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Configuration;
using Npgsql;

namespace FelloWay.Api.Tests.Infrastructure;

/// <summary>
/// Integration-suite host: real PostgreSQL, full Testing startup (EnsureCreated + seed + Hangfire).
/// </summary>
public class PostgresWebApplicationFactory : WebApplicationFactory<Program>
{
    private readonly IntegrationTestFixture _fixture;
    private readonly string _databaseName = $"felloway_it_{Guid.NewGuid():N}";

    public PostgresWebApplicationFactory(IntegrationTestFixture fixture)
    {
        _fixture = fixture;
    }

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Testing");

        var csb = new NpgsqlConnectionStringBuilder(_fixture.ConnectionString)
        {
            Database = _databaseName,
        };

        builder.ConfigureAppConfiguration((_, config) =>
        {
            config.AddInMemoryCollection(
                new Dictionary<string, string?>
                {
                    ["ConnectionStrings:Default"] = csb.ConnectionString,
                });
        });
    }
}
