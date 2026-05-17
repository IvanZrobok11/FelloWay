using FelloWay.Application.Events;
using FelloWay.Domain.Enums;

namespace FelloWay.Application.Tests.Events;

public class AttendancePolicyTests
{
    [Theory]
    [InlineData(AttendanceStatus.Joined, true)]
    [InlineData(AttendanceStatus.Left, false)]
    [InlineData(null, false)]
    public void CanViewAttendees_RequiresJoinedStatus(AttendanceStatus? status, bool expected)
    {
        Assert.Equal(expected, AttendancePolicy.CanViewAttendees(status));
    }

    [Fact]
    public void CanJoinEvent_WhenActiveAndBelowCapacity_ReturnsTrue()
    {
        Assert.True(AttendancePolicy.CanJoinEvent(EventStatus.Active, 10, 20));
    }

    [Fact]
    public void CanJoinEvent_WhenAtCapacity_ReturnsFalse()
    {
        Assert.False(AttendancePolicy.CanJoinEvent(EventStatus.Active, 20, 20));
    }
}
