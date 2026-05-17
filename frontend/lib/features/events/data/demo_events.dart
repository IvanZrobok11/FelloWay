import '../domain/event.dart';

/// Sample events used by `MockApiCatalog` when the app uses mock REST responses.
List<EventSummary> demoEventSummaries() {
  final now = DateTime.now();
  return [
    EventSummary(
      id: 'demo-1',
      title: 'Flutter & Friends Kyiv',
      startsAt: now.add(const Duration(days: 14)),
      endsAt: now.add(const Duration(days: 15)),
      city: 'Kyiv',
      venueName: 'ICC',
      imageUrls: const [],
      tags: const ['IT', 'Design'],
      attendStatus: AttendStatus.notAttending,
      attendeePreview: const [
        EventAttendeePreview(id: 'a1', displayName: 'Olena', city: 'Kyiv'),
        EventAttendeePreview(id: 'a2', displayName: 'Andriy', city: 'Lviv'),
      ],
      latitude: 50.45,
      longitude: 30.52,
    ),
    EventSummary(
      id: 'demo-2',
      title: 'Product IT Summit',
      startsAt: now.add(const Duration(days: 30)),
      endsAt: now.add(const Duration(days: 31)),
      city: 'Lviv',
      venueName: 'Arena Lviv',
      imageUrls: const [],
      tags: const ['HR', 'Marketing'],
      attendStatus: AttendStatus.notAttending,
      latitude: 49.84,
      longitude: 24.03,
    ),
  ];
}

Event demoEventDetail(String id) {
  final base = demoEventSummaries().firstWhere(
    (e) => e.id == id,
    orElse: () => demoEventSummaries().first,
  );
  return Event(
    id: base.id,
    title: base.title,
    startsAt: base.startsAt,
    endsAt: base.endsAt,
    city: base.city,
    venueName: base.venueName,
    imageUrls: base.imageUrls,
    tags: base.tags,
    capacity: 500,
    priceLabel: 'Free',
    officialUrl: 'https://example.com',
    attendStatus: base.attendStatus,
    attendeePreview: base.attendeePreview,
    latitude: base.latitude,
    longitude: base.longitude,
    attendees: [
      ...base.attendeePreview,
      const EventAttendeePreview(id: 'a3', displayName: 'Ivan', city: 'Kyiv'),
    ],
  );
}
