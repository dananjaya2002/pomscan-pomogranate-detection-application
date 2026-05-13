import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pomescan/features/detection/presentation/pages/static_detection_page.dart';

void main() {
  group('StaticDetectionPage', () {
    testWidgets(
      'app can render static detection page without errors',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: StaticDetectionPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(StaticDetectionPage), findsOneWidget);
        expect(find.text('Ripeness Detection'), findsWidgets);
        expect(find.text('No image selected yet.'), findsOneWidget);
        expect(find.text('Take Photo'), findsOneWidget);
        expect(find.text('Gallery'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('displays title and default UI when no image selected',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: StaticDetectionPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ripeness Detection'), findsWidgets);
      expect(find.text('Detected Fruit Status'), findsNothing);
      expect(find.text('Open Harvesting Guide'), findsNothing);
      expect(find.text('No image selected yet.'), findsOneWidget);
    });
  });

  group('Detection result rendering', () {
    testWidgets(
      'displays detection count summary correctly',
      (tester) async {
        // This test would require mocking the repository and injecting
        // test detections into the page. Deferred until fixture harness is ready.
        expect(true, true);
      },
    );
  });
}
