import 'package:dio/dio.dart';

import '../../../app/config/app_config.dart';
import '../../../shared/errors/app_failure.dart';
import '../../../shared/errors/result.dart';
import '../../../shared/mocks/mock_api_catalog.dart';
import '../../../shared/network/api_client.dart';
import '../domain/trip_chat.dart';

class CreateTripDraft {
  const CreateTripDraft({
    required this.routeLabel,
    required this.departureAt,
    required this.transportRole,
    required this.targetCityLabel,
    required this.capacity,
  });

  final String routeLabel;
  final DateTime departureAt;
  final TripTransportRole transportRole;
  final String targetCityLabel;
  final int capacity;

  Map<String, dynamic> toJson() {
    return {
      'routeLabel': routeLabel,
      'departureAt': departureAt.toUtc().toIso8601String(),
      'transportRole': _roleString(transportRole),
      'targetCityLabel': targetCityLabel,
      'capacity': capacity,
    };
  }

  static String _roleString(TripTransportRole r) {
    switch (r) {
      case TripTransportRole.driver:
        return 'driver';
      case TripTransportRole.passenger:
        return 'passenger';
      case TripTransportRole.either:
        return 'either';
    }
  }
}

// Live mode: mock-only until wired to backend (see specs/005-api-backend-integration).
class TripsRepository {
  TripsRepository(this._api, this._config);

  final ApiClient _api;
  final AppConfig _config;

  Future<Result<List<TripChatSummary>>> listTrips(String eventId) async {
    if (_config.useMockApi) {
      return Success(MockApiCatalog.tripsForEvent(eventId));
    }
    try {
      final res = await _api.dio.get<Map<String, dynamic>>(
        '/events/$eventId/trips',
      );
      final raw = res.data?['items'] as List<dynamic>? ?? [];
      return Success(
        raw
            .map((e) => _mapSummary(e as Map<String, dynamic>, eventId))
            .toList(),
      );
    } catch (e) {
      return Failure(_api.mapDioError(e));
    }
  }

  Future<Result<TripChatSummary>> createTrip(
    String eventId,
    CreateTripDraft draft,
  ) async {
    if (_config.useMockApi) {
      final id = 'demo-trip-${DateTime.now().millisecondsSinceEpoch}';
      return Success(
        TripChatSummary(
          id: id,
          eventId: eventId,
          routeLabel: draft.routeLabel,
          departureAt: draft.departureAt,
          transportRole: draft.transportRole,
          targetCityLabel: draft.targetCityLabel,
          capacity: draft.capacity,
          memberCount: 1,
          ownerUserId: 'me',
          myMembership: TripMyMembership.owner,
        ),
      );
    }
    try {
      final res = await _api.dio.post<Map<String, dynamic>>(
        '/events/$eventId/trips',
        data: draft.toJson(),
      );
      final data = res.data;
      if (data == null) {
        return const Failure(ValidationFailure('Empty trip response'));
      }
      return Success(_mapSummary(data, eventId));
    } on DioException catch (e) {
      return Failure(_api.mapDioError(e));
    }
  }

  Future<Result<bool>> requestJoin(String tripId) async {
    if (_config.useMockApi) {
      return const Success(true);
    }
    try {
      await _api.dio.post<void>('/trips/$tripId/join');
      return const Success(true);
    } on DioException catch (e) {
      return Failure(_api.mapDioError(e));
    }
  }

  Future<Result<bool>> cancelJoinRequest(String tripId) async {
    if (_config.useMockApi) {
      return const Success(true);
    }
    try {
      await _api.dio.delete<void>('/trips/$tripId/join');
      return const Success(true);
    } on DioException catch (e) {
      return Failure(_api.mapDioError(e));
    }
  }

  Future<Result<List<TripJoinRequest>>> listJoinRequests(String tripId) async {
    if (_config.useMockApi) {
      return Success(MockApiCatalog.demoJoinRequests());
    }
    try {
      final res = await _api.dio.get<Map<String, dynamic>>(
        '/trips/$tripId/join-requests',
      );
      final raw = res.data?['items'] as List<dynamic>? ?? [];
      return Success(
        raw.map((e) {
          final m = e as Map<String, dynamic>;
          return TripJoinRequest(
            userId: m['userId']?.toString() ?? '',
            displayName:
                m['displayName'] as String? ?? m['name'] as String? ?? '',
            homeCityLabel:
                m['homeCityLabel'] as String? ?? m['city'] as String? ?? '',
            ratingAverage:
                (m['ratingAverage'] as num?)?.toDouble() ??
                (m['rating'] as num?)?.toDouble(),
          );
        }).toList(),
      );
    } catch (e) {
      return Failure(_api.mapDioError(e));
    }
  }

  Future<Result<bool>> approveJoin(String tripId, String userId) async {
    if (_config.useMockApi) {
      return const Success(true);
    }
    try {
      await _api.dio.post<void>('/trips/$tripId/approve/$userId');
      return const Success(true);
    } on DioException catch (e) {
      return Failure(_api.mapDioError(e));
    }
  }

  TripChatSummary _mapSummary(Map<String, dynamic> json, String eventId) {
    return TripChatSummary(
      id: json['id']?.toString() ?? '',
      eventId: json['eventId']?.toString() ?? eventId,
      routeLabel:
          json['routeLabel'] as String? ?? json['route'] as String? ?? '',
      departureAt:
          DateTime.tryParse(json['departureAt'] as String? ?? '') ??
          DateTime.now(),
      transportRole: TripChatSummary.parseRole(
        json['transportRole'] as String?,
      ),
      targetCityLabel:
          json['targetCityLabel'] as String? ?? json['city'] as String? ?? '',
      capacity: json['capacity'] as int? ?? 4,
      memberCount: json['memberCount'] as int? ?? 0,
      ownerUserId: json['ownerUserId']?.toString() ?? '',
      myMembership: TripChatSummary.parseMembership(
        json['myMembership'] as String?,
      ),
    );
  }
}
