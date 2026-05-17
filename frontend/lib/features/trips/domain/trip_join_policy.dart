/// Client-side rules mirroring FR-016 / FR-017 for UX copy only; server decides.
class TripJoinPolicy {
  const TripJoinPolicy._();

  static String normalizeCity(String raw) => raw.trim().toLowerCase();

  /// Same-city join is auto-approved on the backend (FR-016).
  static bool expectAutoApprove({
    required String requesterHomeCity,
    required String tripTargetCity,
  }) {
    final a = normalizeCity(requesterHomeCity);
    final b = normalizeCity(tripTargetCity);
    if (a.isEmpty || b.isEmpty) return false;
    return a == b;
  }

  /// Show low-rating warning to trip owner when reviewing requests (FR-024).
  static bool isLowRatingWarning(
    double? ratingAverage, {
    double threshold = 3.5,
  }) {
    if (ratingAverage == null) return false;
    return ratingAverage < threshold;
  }
}
