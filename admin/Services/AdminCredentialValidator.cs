using FelloWay.Admin.Options;
using Microsoft.Extensions.Options;

namespace FelloWay.Admin.Services;

public sealed class AdminCredentialValidator(IOptions<AdminAuthOptions> options)
{
    public bool Validate(string username, string password)
    {
        var configured = options.Value;
        if (string.IsNullOrWhiteSpace(configured.Username) || string.IsNullOrWhiteSpace(configured.Password))
        {
            return false;
        }

        return string.Equals(username, configured.Username, StringComparison.Ordinal)
            && string.Equals(password, configured.Password, StringComparison.Ordinal);
    }
}
