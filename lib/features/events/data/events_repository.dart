import 'package:dio/dio.dart';

import '../../../shared/errors/app_failure.dart';
import '../../../shared/errors/result.dart';
import '../../../shared/network/api_client.dart';
import '../domain/event.dart';

class EventsPage {
  const EventsPage({required this.items, this.nextCursor});

  final List<EventSummary> items;
  final String? nextCursor;
}

class EventsRepository {
  EventsRepository(this._api);

  final ApiClient _api;

  Future<Result<EventsPage>> listEvents({
    String? query,
    String? city,
    String? interest,
    String? cursor,
  }) async {
    try {
      final res = await _api.dio.get<Map<String, dynamic>>(
        '/events',
        queryParameters: <String, dynamic>{
          if (query != null && query.isNotEmpty) 'q': query,
          if (city != null && city.isNotEmpty) 'city': city,
          if (interest != null && interest.isNotEmpty) 'interest': interest,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        },
      );
      final data = res.data ?? const <String, dynamic>{};
      final rawItems = data['items'] as List<dynamic>? ?? const [];
      final items = rawItems
          .map((e) => _mapSummary(e as Map<String, dynamic>))
          .toList();
      final next = data['nextCursor'] as String?;
      return Success(EventsPage(items: items, nextCursor: next));
    } catch (e) {
      return Failure(_api.mapDioError(e));
    }
  }

  Future<Result<Event>> getEvent(String id) async {
    try {
      final res = await _api.dio.get<Map<String, dynamic>>('/events/$id');
      final data = res.data;
      if (data == null) {
        return const Failure(ValidationFailure('Empty event response'));
      }
      return Success(_mapDetail(data));
    } catch (e) {
      return Failure(_api.mapDioError(e));
    }
  }

  Future<Result<bool>> attend(String id) async {
    try {
      await _api.dio.post<void>('/events/$id/attend');
      return const Success(true);
    } on DioException catch (e) {
      return Failure(_api.mapDioError(e));
    }
  }

  Future<Result<bool>> leave(String id) async {
    try {
      await _api.dio.delete<void>('/events/$id/attend');
      return const Success(true);
    } on DioException catch (e) {
      return Failure(_api.mapDioError(e));
    }
  }

  EventSummary _mapSummary(Map<String, dynamic> json) {
    return EventSummary(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      startsAt:
          DateTime.tryParse(json['startsAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      endsAt:
          DateTime.tryParse(json['endsAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      city: json['city'] as String? ?? '',
      venueName: json['venueName'] as String? ?? json['venue'] as String? ?? '',
      imageUrls:
          (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const [],
      capacity: json['capacity'] as int?,
      priceLabel: json['priceLabel'] as String? ?? json['price']?.toString(),
      officialUrl: json['officialUrl'] as String?,
      attendStatus: _parseAttend(json['attendStatus'] as String?),
      attendeePreview: _parsePreview(json['attendeePreview'] as List<dynamic>?),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Event _mapDetail(Map<String, dynamic> json) {
    final base = _mapSummary(json);
    final attendeesRaw = json['attendees'] as List<dynamic>?;
    final attendees = attendeesRaw != null && attendeesRaw.isNotEmpty
        ? _parsePreview(attendeesRaw)
        : base.attendeePreview;
    return Event(
      id: base.id,
      title: base.title,
      startsAt: base.startsAt,
      endsAt: base.endsAt,
      city: base.city,
      venueName: base.venueName,
      imageUrls: base.imageUrls,
      tags: base.tags,
      capacity: base.capacity,
      priceLabel: base.priceLabel,
      officialUrl: base.officialUrl,
      attendStatus: base.attendStatus,
      attendeePreview: base.attendeePreview,
      latitude: base.latitude,
      longitude: base.longitude,
      attendees: attendees,
    );
  }

  static AttendStatus _parseAttend(String? raw) {
    switch (raw) {
      case 'attending':
        return AttendStatus.attending;
      case 'not_attending':
      case 'none':
        return AttendStatus.notAttending;
      default:
        return AttendStatus.unknown;
    }
  }

  static List<EventAttendeePreview> _parsePreview(List<dynamic>? raw) {
    if (raw == null) return const [];
    return raw.map((e) {
      final m = e as Map<String, dynamic>;
      return EventAttendeePreview(
        id: m['id']?.toString() ?? '',
        displayName: m['displayName'] as String? ?? m['name'] as String? ?? '',
        city: m['city'] as String? ?? '',
      );
    }).toList();
  }
}
