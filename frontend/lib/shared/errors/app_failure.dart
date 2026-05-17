/// User-safe or loggable failure for UI and repositories.
sealed class AppFailure implements Exception {
  const AppFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message);
}

final class AuthFailure extends AppFailure {
  const AuthFailure(super.message);
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message);
}
