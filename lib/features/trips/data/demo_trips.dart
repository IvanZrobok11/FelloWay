import '../domain/trip_chat.dart';

/// Demo trips for [AppConfig.isDemoBackend] (e.g. `demo-1` event).
List<TripChatSummary> demoTripsForEvent(String eventId) {
  if (eventId != 'demo-1' && !eventId.startsWith('demo')) {
    return const [];
  }
  final dep = DateTime.now().add(const Duration(days: 1));
  return [
    TripChatSummary(
      id: 'demo-trip-1',
      eventId: eventId,
      routeLabel: 'ICC → Boryspil',
      departureAt: dep,
      transportRole: TripTransportRole.driver,
      targetCityLabel: 'Kyiv',
      capacity: 4,
      memberCount: 1,
      ownerUserId: 'a1',
      myMembership: TripMyMembership.none,
    ),
    TripChatSummary(
      id: 'demo-trip-2',
      eventId: eventId,
      routeLabel: 'Central station share',
      departureAt: dep.add(const Duration(hours: 2)),
      transportRole: TripTransportRole.passenger,
      targetCityLabel: 'Lviv',
      capacity: 3,
      memberCount: 2,
      ownerUserId: 'a2',
      myMembership: TripMyMembership.pending,
    ),
  ];
}
