namespace FelloWay.Admin.Pages.Events;

internal static class EventFormMapping
{
    /// <summary>datetime-local has no timezone; form labels say UTC.</summary>
    public static DateTimeOffset ToUtcOffset(DateTime value)
    {
        var utc = value.Kind switch
        {
            DateTimeKind.Utc => value,
            DateTimeKind.Local => value.ToUniversalTime(),
            _ => DateTime.SpecifyKind(value, DateTimeKind.Utc),
        };
        return new DateTimeOffset(utc, TimeSpan.Zero);
    }

    public static DateTime ToFormDateTime(DateTimeOffset value) => value.UtcDateTime;
}
