library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../data/datasources/model_datasource.dart';
import '../../data/repositories/detection_repository_impl.dart';
import '../../domain/usecases/run_detection_usecase.dart';

final staticModelDataSourceProvider = Provider<ModelDataSource>((ref) {
  return ModelDataSource(
    modelAssetPath: AppConstants.staticDetectionModelAssetPath,
  );
});

final staticModelInitProvider = FutureProvider<void>((ref) async {
  final model = ref.read(staticModelDataSourceProvider);
  await model.initialise();
  ref.onDispose(model.dispose);
});

final staticDetectionRepositoryProvider = Provider((ref) {
  return DetectionRepositoryImpl(
    modelDataSource: ref.watch(staticModelDataSourceProvider),
  );
});

final staticRunDetectionUseCaseProvider = Provider((ref) {
  return RunDetectionUseCase(ref.watch(staticDetectionRepositoryProvider));
});
