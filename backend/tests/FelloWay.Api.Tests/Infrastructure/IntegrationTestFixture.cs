using Testcontainers.PostgreSql;

namespace FelloWay.Api.Tests.Infrastructure;

/// <summary>
/// Optional PostgreSQL container for integration tests that require real Npgsql behavior.
/// Use with Docker available: <c>dotnet test --filter Category=Integration</c>
/// </summary>
public sealed class IntegrationTestFixture : IAsyncLifetime
{
    private readonly PostgreSqlContainer _postgres = new PostgreSqlBuilder()
        .WithImage("postgres:16-alpine")
        .WithDatabase("felloway_test")
        .WithUsername("postgres")
        .WithPassword("postgres")
        .Build();

    public string ConnectionString => _postgres.GetConnectionString();

    public async Task InitializeAsync() => await _postgres.StartAsync();

    public async Task DisposeAsync() => await _postgres.DisposeAsync();
}
