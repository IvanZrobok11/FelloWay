import '../../features/events/data/demo_events.dart';
import '../../features/events/domain/event.dart';
import '../../features/profile/data/demo_reviews.dart';
import '../../features/profile/domain/user_profile.dart';
import '../../features/profile/domain/user_review.dart';
import '../../features/trips/data/demo_trips.dart';
import '../../features/trips/domain/trip_chat.dart';
import 'mock_event_attendance_store.dart';

/// Shared demo payloads for [AppConfig.useMockApi]. Repositories use this;
/// widgets should not branch on mock mode.
class MockApiCatalog {
  MockApiCatalog._();

  static UserProfile get demoUserProfile => UserProfile(
    id: 'demo',
    displayName: 'Demo User',
    interests: const ['IT'],
    hobbies: 'Coffee',
    homeCityLabel: 'Kyiv',
    ratingAverage: 4.2,
  );

  static List<EventSummary> eventSummaries() {
    return demoEventSummaries().map(_summaryWithStoredAttend).toList();
  }

  static Event eventDetail(String id) {
    final base = demoEventDetail(id);
    return _eventWithAttend(base, MockEventAttendanceStore.statusFor(id));
  }

  static List<TripChatSummary> tripsForEvent(String eventId) =>
      demoTripsForEvent(eventId);

  static List<TripJoinRequest> demoJoinRequests() => const [
    TripJoinRequest(
      userId: 'u-low',
      displayName: 'Pat',
      homeCityLabel: 'Odesa',
      ratingAverage: 2.8,
    ),
    TripJoinRequest(
      userId: 'u-ok',
      displayName: 'Jan',
      homeCityLabel: 'Kyiv',
      ratingAverage: 4.5,
    ),
  ];

  static List<UserReview> reviewsForUser(String userId) =>
      demoReviewsForUser(userId);

  static EventSummary _summaryWithStoredAttend(EventSummary s) {
    final st = MockEventAttendanceStore.statusFor(s.id);
    if (st == s.attendStatus) return s;
    return EventSummary(
      id: s.id,
      title: s.title,
      startsAt: s.startsAt,
      endsAt: s.endsAt,
      city: s.city,
      venueName: s.venueName,
      imageUrls: s.imageUrls,
      tags: s.tags,
      capacity: s.capacity,
      priceLabel: s.priceLabel,
      officialUrl: s.officialUrl,
      attendStatus: st,
      attendeePreview: s.attendeePreview,
      latitude: s.latitude,
      longitude: s.longitude,
    );
  }

  static Event _eventWithAttend(Event e, AttendStatus status) {
    if (e.attendStatus == status) return e;
    return Event(
      id: e.id,
      title: e.title,
      startsAt: e.startsAt,
      endsAt: e.endsAt,
      city: e.city,
      venueName: e.venueName,
      imageUrls: e.imageUrls,
      tags: e.tags,
      capacity: e.capacity,
      priceLabel: e.priceLabel,
      officialUrl: e.officialUrl,
      attendStatus: status,
      attendeePreview: e.attendeePreview,
      latitude: e.latitude,
      longitude: e.longitude,
      attendees: e.attendees,
    );
  }
}
