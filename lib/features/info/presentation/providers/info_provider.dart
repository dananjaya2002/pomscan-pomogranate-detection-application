library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/info_repository.dart';
import '../../domain/entities/info_item.dart';

final infoRepositoryProvider = Provider<InfoRepository>(
  (_) => const InfoRepository(),
);

final infoProvider = FutureProvider.family<List<InfoItem>, InfoType>(
  (ref, type) => ref.read(infoRepositoryProvider).load(type),
);
