enum TripTransportRole { driver, passenger, either }

enum TripMyMembership { none, pending, member, owner }

class TripChatSummary {
  const TripChatSummary({
    required this.id,
    required this.eventId,
    required this.routeLabel,
    required this.departureAt,
    required this.transportRole,
    required this.targetCityLabel,
    required this.capacity,
    required this.memberCount,
    required this.ownerUserId,
    required this.myMembership,
  });

  final String id;
  final String eventId;
  final String routeLabel;
  final DateTime departureAt;
  final TripTransportRole transportRole;
  final String targetCityLabel;
  final int capacity;
  final int memberCount;
  final String ownerUserId;
  final TripMyMembership myMembership;

  static TripTransportRole parseRole(String? raw) {
    switch (raw) {
      case 'driver':
        return TripTransportRole.driver;
      case 'passenger':
        return TripTransportRole.passenger;
      case 'either':
      default:
        return TripTransportRole.either;
    }
  }

  static TripMyMembership parseMembership(String? raw) {
    switch (raw) {
      case 'pending':
        return TripMyMembership.pending;
      case 'member':
        return TripMyMembership.member;
      case 'owner':
        return TripMyMembership.owner;
      case 'none':
      default:
        return TripMyMembership.none;
    }
  }
}

class TripJoinRequest {
  const TripJoinRequest({
    required this.userId,
    required this.displayName,
    required this.homeCityLabel,
    this.ratingAverage,
  });

  final String userId;
  final String displayName;
  final String homeCityLabel;
  final double? ratingAverage;
}
