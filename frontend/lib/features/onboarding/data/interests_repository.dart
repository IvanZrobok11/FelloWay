import '../../../shared/errors/app_failure.dart';
import '../../../shared/errors/result.dart';
import '../../../shared/network/api_client.dart';
import '../domain/interest_catalog_item.dart';

/// Loads the interests catalog from `GET /interests` (server is source of truth).
class InterestsRepository {
  InterestsRepository(this._api);

  final ApiClient _api;

  List<InterestCatalogItem>? _cache;

  Future<Result<List<InterestCatalogItem>>> fetchCatalog({
    bool forceRefresh = false,
  }) async {
    if (_cache != null && !forceRefresh) {
      return Success(_cache!);
    }

    try {
      final res = await _api.dio.get<Map<String, dynamic>>('/interests');
      final data = res.data;
      if (data == null) {
        return const Failure(ValidationFailure('Empty interests response'));
      }

      final items = _parseItems(data);
      _cache = items;
      return Success(items);
    } catch (e) {
      return Failure(_api.mapDioError(e));
    }
  }

  static List<InterestCatalogItem> _parseItems(Map<String, dynamic> data) {
    return (data['items'] as List<dynamic>? ?? const [])
        .map((e) => InterestCatalogItem.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
}
