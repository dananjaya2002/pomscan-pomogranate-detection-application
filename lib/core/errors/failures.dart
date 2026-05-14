library;

sealed class Failure {
  const Failure(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class ModelFailure extends Failure {
  const ModelFailure(super.message);
}

final class CameraFailure extends Failure {
  const CameraFailure(super.message);
}

final class ProcessingFailure extends Failure {
  const ProcessingFailure(super.message);
}

final class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}
