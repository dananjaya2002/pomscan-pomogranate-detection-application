/// Domain-layer failure types.
library;

/// Base class for all app-level failures.
sealed class Failure {
  const Failure(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Raised when the TFLite model cannot be loaded or run.
final class ModelFailure extends Failure {
  const ModelFailure(super.message);
}

/// Raised when the camera cannot be initialised or a frame cannot be captured.
final class CameraFailure extends Failure {
  const CameraFailure(super.message);
}

/// Raised when pre/post-processing of image data fails.
final class ProcessingFailure extends Failure {
  const ProcessingFailure(super.message);
}

/// Raised when a required permission is denied by the user.
final class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}
