namespace FelloWay.Api.Tests.Infrastructure;

/// <summary>
/// In-memory test host using production <see cref="FelloWay.Infrastructure.Auth.ProductionOAuthTokenExchanger"/> only.
/// </summary>
public class ProductionOAuthWebApplicationFactory : FelloWayWebApplicationFactory
{
    protected override bool RegisterTestOAuthExchanger => false;
}
