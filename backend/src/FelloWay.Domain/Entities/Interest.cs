using FelloWay.Domain.Common;

namespace FelloWay.Domain.Entities;

public class Interest : EntityBase
{
    public required string Name { get; set; }

    public int SortOrder { get; set; }

    public ICollection<UserInterest> UserInterests { get; set; } = new List<UserInterest>();
}
