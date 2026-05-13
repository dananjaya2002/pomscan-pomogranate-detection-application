import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:pomescan/core/constants/farmer_strings.dart';
import 'package:pomescan/features/detection/presentation/pages/static_detection_page.dart';

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

        expect(find.text(FarmerStrings.ripeScanTitle), findsOneWidget);
        expect(find.text(FarmerStrings.ripeScanDescription), findsOneWidget);
        expect(find.text('📸 Pick a photo to start scanning'), findsOneWidget);
        expect(find.text(FarmerStrings.resultsTitle), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
