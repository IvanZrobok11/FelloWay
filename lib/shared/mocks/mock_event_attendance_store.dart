import '../../features/events/domain/event.dart';

/// In-memory attend state for mock API mode only (`GET /events` stubs do not
/// persist joins).
class MockEventAttendanceStore {
  MockEventAttendanceStore._();

  static final Map<String, AttendStatus> _byEventId = {};

  static AttendStatus statusFor(String eventId) =>
      _byEventId[eventId] ?? AttendStatus.notAttending;

  static void setStatus(String eventId, AttendStatus status) {
    _byEventId[eventId] = status;
  }

  /// For tests.
  static void clear() => _byEventId.clear();
}
