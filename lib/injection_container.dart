/// Dependency injection container.
///
/// Riverpod providers manage all dependency lifetimes. This file handles
/// any global one-time setup that must run before [runApp] (e.g. platform
/// channel configuration, native library loading).
library;

/// Performs global setup required before the app starts.
///
/// TFLite interpreter loading is deferred to [modelInitProvider] so it
/// runs concurrently with the first Flutter frame, avoiding startup jank.
Future<void> initDependencies() async {
  // Nothing needed at the platform level before runApp for now.
  // tflite_flutter loads its native libs lazily on first interpreter create.
}
