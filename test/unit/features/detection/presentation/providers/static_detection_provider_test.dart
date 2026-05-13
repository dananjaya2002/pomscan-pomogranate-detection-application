import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pomescan/core/constants/app_constants.dart';
import 'package:pomescan/features/detection/data/repositories/detection_repository_impl.dart';
import 'package:pomescan/features/detection/presentation/providers/static_detection_provider.dart';

void main() {
  group('StaticDetectionProvider', () {
    test(
        'staticModelDataSourceProvider returns ModelDataSource with correct path',
        () {
      final container = ProviderContainer();
      final dataSource = container.read(staticModelDataSourceProvider);

      expect(dataSource.modelAssetPath,
          AppConstants.staticDetectionModelAssetPath);
    });

    test('staticDetectionRepositoryProvider returns implementation', () {
      final container = ProviderContainer();
      final repo = container.read(staticDetectionRepositoryProvider);

      expect(repo, isA<DetectionRepositoryImpl>());
    });

    test('providers are cached by Riverpod', () {
      final container = ProviderContainer();

      final dataSource1 = container.read(staticModelDataSourceProvider);
      final dataSource2 = container.read(staticModelDataSourceProvider);

      expect(identical(dataSource1, dataSource2), true);
    });
  });
}
