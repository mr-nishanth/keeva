import '../errors/app_failure.dart';

/// A lightweight, type-safe result abstraction representing either a [Success] or a [Failure].
///
/// Eliminates throwing platform/runtime exceptions through domain and application layers.
sealed class Result<T> {
  const Result();

  /// Convenience constructor to create a [Success].
  const factory Result.success(T data) = Success<T>;

  /// Convenience constructor to create a [Failure].
  const factory Result.failure(AppFailure failure) = Failure<T>;

  /// Whether this result represents a successful operation.
  bool get isSuccess => this is Success<T>;

  /// Whether this result represents a failed operation.
  bool get isFailure => this is Failure<T>;

  /// Returns the underlying data if [Success], or null otherwise.
  T? get dataOrNull => switch (this) {
    Success(:final data) => data,
    Failure() => null,
  };

  /// Returns the underlying [AppFailure] if [Failure], or null otherwise.
  AppFailure? get failureOrNull => switch (this) {
    Success() => null,
    Failure(:final failure) => failure,
  };

  /// Evaluates [onSuccess] if this is [Success], or [onFailure] if this is [Failure].
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppFailure failure) onFailure,
  }) {
    return switch (this) {
      Success(:final data) => onSuccess(data),
      Failure(:final failure) => onFailure(failure),
    };
  }

  /// Transforms the success value if this is [Success].
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success(:final data) => Result.success(transform(data)),
      Failure(:final failure) => Result.failure(failure),
    };
  }

  /// Transforms the failure if this is [Failure].
  Result<T> mapFailure(AppFailure Function(AppFailure failure) transform) {
    return switch (this) {
      Success(:final data) => Result.success(data),
      Failure(:final failure) => Result.failure(transform(failure)),
    };
  }
}

/// Represents a successful result containing [data].
final class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Success<T> &&
          other.runtimeType == runtimeType &&
          other.data == data);

  @override
  int get hashCode => Object.hash(runtimeType, data);

  @override
  String toString() => 'Success($data)';
}

/// Represents a failed result containing an [AppFailure].
final class Failure<T> extends Result<T> {
  final AppFailure failure;

  const Failure(this.failure);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Failure<T> &&
          other.runtimeType == runtimeType &&
          other.failure == failure);

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  @override
  String toString() => 'Failure($failure)';
}
