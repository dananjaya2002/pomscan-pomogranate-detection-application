// Smoke test — verifies the app can be pumped without errors.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/main.dart';

void main() {
  testWidgets('App launches without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: PomegranateDetectorApp()),
    );
    // Verify the app initialises without throwing
    expect(tester.takeException(), isNull);
  });
}
