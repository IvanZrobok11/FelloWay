enum AttendStatus { unknown, notAttending, attending }

class EventAttendeePreview {
  const EventAttendeePreview({
    required this.id,
    required this.displayName,
    required this.city,
  });

  final String id;
  final String displayName;
  final String city;
}

class EventSummary {
  const EventSummary({
    required this.id,
    required this.title,
    required this.startsAt,
    required this.endsAt,
    required this.city,
    required this.venueName,
    required this.imageUrls,
    required this.tags,
    this.capacity,
    this.priceLabel,
    this.officialUrl,
    this.attendStatus = AttendStatus.unknown,
    this.attendeePreview = const [],
    this.latitude,
    this.longitude,
  });

  final String id;
  final String title;
  final DateTime startsAt;
  final DateTime endsAt;
  final String city;
  final String venueName;
  final List<String> imageUrls;
  final List<String> tags;
  final int? capacity;
  final String? priceLabel;
  final String? officialUrl;
  final AttendStatus attendStatus;
  final List<EventAttendeePreview> attendeePreview;
  final double? latitude;
  final double? longitude;

  EventSummary copyWith({
    AttendStatus? attendStatus,
    List<EventAttendeePreview>? attendeePreview,
  }) {
    return EventSummary(
      id: id,
      title: title,
      startsAt: startsAt,
      endsAt: endsAt,
      city: city,
      venueName: venueName,
      imageUrls: imageUrls,
      tags: tags,
      capacity: capacity,
      priceLabel: priceLabel,
      officialUrl: officialUrl,
      attendStatus: attendStatus ?? this.attendStatus,
      attendeePreview: attendeePreview ?? this.attendeePreview,
      latitude: latitude,
      longitude: longitude,
    );
  }
}

class Event extends EventSummary {
  Event({
    required super.id,
    required super.title,
    required super.startsAt,
    required super.endsAt,
    required super.city,
    required super.venueName,
    required super.imageUrls,
    required super.tags,
    super.capacity,
    super.priceLabel,
    super.officialUrl,
    super.attendStatus = AttendStatus.unknown,
    super.attendeePreview = const [],
    super.latitude,
    super.longitude,
    required this.attendees,
  });

  final List<EventAttendeePreview> attendees;
}
