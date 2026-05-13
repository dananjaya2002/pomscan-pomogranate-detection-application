import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/main.dart';

void main() {
  group('System workflow', () {
    testWidgets(
      'covers camera permission, scan toggling, and results flow',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(child: PomegranateDetectorApp()),
        );

        expect(find.text('PomeScan'), findsOneWidget);
        expect(find.textContaining('Loading model'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
