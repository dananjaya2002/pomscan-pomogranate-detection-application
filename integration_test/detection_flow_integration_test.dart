import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../lib/features/detection/presentation/pages/static_detection_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Detection integration flow', () {
    testWidgets(
      'static image path preprocesses and returns detections',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: StaticDetectionPage(),
            ),
          ),
        );

        expect(find.text('Ripeness Detection'), findsWidgets);
        expect(find.text('No image selected yet.'), findsOneWidget);
        expect(find.text('Detected Fruit Status'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
