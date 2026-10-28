/// Sealed Failure hierarchy for typed error handling.
/// Reference: AGENT.md Section 6.2.
sealed class Failure {
  const Failure(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() =>
      '$runtimeType: $message${cause != null ? ' ($cause)' : ''}';
}

final class CameraFailure extends Failure {
  const CameraFailure(super.message, [super.cause]);
}

final class CalibrationFailure extends Failure {
  const CalibrationFailure(super.message, [super.cause]);
}

final class TfliteFailure extends Failure {
  const TfliteFailure(super.message, [super.cause]);
}

final class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, [super.cause]);
}

final class SyncFailure extends Failure {
  const SyncFailure(super.message, [super.cause]);
}

final class SensorFailure extends Failure {
  const SensorFailure(super.message, [super.cause]);
}

final class PermissionFailure extends Failure {
  const PermissionFailure(super.message, [super.cause]);
}
