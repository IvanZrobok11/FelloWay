using Testcontainers.PostgreSql;

namespace FelloWay.Api.Tests.Infrastructure;

/// <summary>
/// Shared PostgreSQL for integration tests (Testcontainers or <c>FELLOWAY_TEST_CONNECTION</c>).
/// </summary>
public sealed class IntegrationTestFixture : IAsyncLifetime
{
    private PostgreSqlContainer? _container;
    private string? _connectionString;

    public string ConnectionString =>
        _connectionString
        ?? throw new InvalidOperationException(
            "Integration tests require PostgreSQL. Start Docker Desktop, set FELLOWAY_TEST_CONNECTION, "
            + "or see specs/006-hybrid-test-database/quickstart.md");

    public async Task InitializeAsync()
    {
        var fromEnv = Environment.GetEnvironmentVariable("FELLOWAY_TEST_CONNECTION");
        if (!string.IsNullOrWhiteSpace(fromEnv))
        {
            _connectionString = fromEnv;
            return;
        }

        _container = new PostgreSqlBuilder()
            .WithImage("postgres:16-alpine")
            .WithDatabase("postgres")
            .WithUsername("postgres")
            .WithPassword("postgres")
            .Build();

        await _container.StartAsync();
        _connectionString = _container.GetConnectionString();
    }

    public async Task DisposeAsync()
    {
        if (_container is not null)
        {
            await _container.DisposeAsync();
        }
    }
}
