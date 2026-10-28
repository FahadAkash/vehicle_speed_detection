import 'package:vehicle_speed_estimator/core/errors/failures.dart';

/// Functional Result pattern for type-safe operation returns.
/// Reference: AGENT.md Section 6.2.
sealed class Result<T, E extends Failure> {
  const Result();

  factory Result.ok(T value) = Ok<T, E>;
  factory Result.err(E failure) = Err<T, E>;

  bool get isOk => this is Ok<T, E>;
  bool get isErr => this is Err<T, E>;

  T? get valueOrNull => switch (this) {
    Ok<T, E>(value: final v) => v,
    Err<T, E>() => null,
  };

  E? get failureOrNull => switch (this) {
    Ok<T, E>() => null,
    Err<T, E>(failure: final f) => f,
  };

  R when<R>({
    required R Function(T value) ok,
    required R Function(E failure) err,
  }) {
    return switch (this) {
      Ok<T, E>(value: final v) => ok(v),
      Err<T, E>(failure: final f) => err(f),
    };
  }
}

final class Ok<T, E extends Failure> extends Result<T, E> {
  const Ok(this.value);
  final T value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Ok<T, E> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Ok($value)';
}

final class Err<T, E extends Failure> extends Result<T, E> {
  const Err(this.failure);
  final E failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Err<T, E> && other.failure == failure);

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'Err($failure)';
}
