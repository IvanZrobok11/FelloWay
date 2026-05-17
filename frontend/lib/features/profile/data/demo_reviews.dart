import '../domain/user_review.dart';

List<UserReview> demoReviewsForUser(String userId) {
  if (userId.isEmpty) return const [];
  return [
    UserReview(
      id: 'r1',
      rating: 5,
      comment: 'Great collaboration on the trip chat.',
      authorLabel: 'Alex K.',
      eventTitle: 'Flutter Summit',
      createdAt: DateTime.utc(2025, 11, 2, 12, 0),
    ),
    UserReview(
      id: 'r2',
      rating: 4,
      comment: 'Punctual and friendly.',
      authorLabel: 'Maria S.',
      eventTitle: 'DevOps Days',
      createdAt: DateTime.utc(2025, 9, 15, 8, 30),
    ),
  ];
}
