import 'app_failure.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  R fold<R>(
    R Function(T data) onSuccess,
    R Function(AppFailure error) onFailure,
  );
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;

  @override
  R fold<R>(
    R Function(T data) onSuccess,
    R Function(AppFailure error) onFailure,
  ) => onSuccess(value);
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);

  final AppFailure error;

  @override
  R fold<R>(
    R Function(T data) onSuccess,
    R Function(AppFailure error) onFailure,
  ) => onFailure(error);
}
