import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Mobile performance baseline', () {
    test(
      'tracks startup, inference latency, and memory trends',
      () {
        // TODO: Implement Android-first perf baselines.
        // Metrics to capture:
        // - cold start time
        // - average inference latency (ms)
        // - dropped-frame ratio
        // - memory usage during scan session
      },
      skip: true,
    );
  });
}
