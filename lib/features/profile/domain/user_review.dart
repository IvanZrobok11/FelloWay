class UserReview {
  const UserReview({
    required this.id,
    required this.rating,
    this.comment,
    this.authorLabel,
    this.eventTitle,
    this.createdAt,
  });

  final String id;
  final int rating;
  final String? comment;
  final String? authorLabel;
  final String? eventTitle;
  final DateTime? createdAt;

  factory UserReview.fromJson(Map<String, dynamic> json) {
    return UserReview(
      id: json['id']?.toString() ?? '',
      rating:
          (json['rating'] as num?)?.round() ??
          (json['stars'] as num?)?.round() ??
          0,
      comment: json['comment'] as String? ?? json['text'] as String?,
      authorLabel:
          json['authorLabel'] as String? ?? json['authorName'] as String?,
      eventTitle: json['eventTitle'] as String? ?? json['event'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }
}
