import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/asset.dart';
import '../repositories/asset_repository.dart';
import 'database_provider.dart';

final assetRepositoryProvider = Provider<AssetRepository>((ref) {
  return AssetRepository(ref.watch(appDatabaseProvider));
});

final allAssetsProvider = StreamProvider<List<Asset>>((ref) {
  return ref.watch(assetRepositoryProvider).watchAll();
});

final assetProvider = FutureProvider.family<Asset?, int>((ref, id) {
  return ref.watch(assetRepositoryProvider).getById(id);
});
