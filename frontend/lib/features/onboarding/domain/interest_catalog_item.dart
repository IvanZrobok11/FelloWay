/// One row from `GET /interests` or embedded in `GET /users/me`.
class InterestCatalogItem {
  const InterestCatalogItem({
    required this.id,
    required this.name,
    required this.sortOrder,
  });

  final String id;
  final String name;
  final int sortOrder;

  factory InterestCatalogItem.fromJson(Map<String, dynamic> json) {
    return InterestCatalogItem(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }
}
