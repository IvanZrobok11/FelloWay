using FelloWay.Domain.Enums;

namespace FelloWay.Application.Events;

public static class AttendancePolicy
{
    public static bool CanViewAttendees(AttendanceStatus? status) =>
        status == AttendanceStatus.Joined;

    public static bool CanJoinEvent(EventStatus eventStatus, int joinedCount, int? capacity) =>
        eventStatus == EventStatus.Active &&
        (!capacity.HasValue || joinedCount < capacity.Value);
}
