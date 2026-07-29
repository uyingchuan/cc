import 'package:drift/drift.dart';

import '../app_database.dart';

part 'asset_dao.g.dart';

@DriftAccessor(tables: [Assets])
class AssetDao extends DatabaseAccessor<AppDatabase> with _$AssetDaoMixin {
  AssetDao(super.db);

  Future<List<Asset>> getAll() {
    return (select(assets)
          ..orderBy(
              [(e) => OrderingTerm(expression: e.updatedAt, mode: OrderingMode.desc)]))
        .get();
  }

  Stream<List<Asset>> watchAll() {
    return (select(assets)
          ..orderBy(
              [(e) => OrderingTerm(expression: e.updatedAt, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<Asset?> getById(int id) {
    return (select(assets)..where((e) => e.id.equals(id))).getSingleOrNull();
  }

  Future<int> insert(AssetsCompanion entry) {
    return into(assets).insert(entry);
  }

  Future<void> updateAsset(int id, AssetsCompanion entry) {
    return (update(assets)..where((e) => e.id.equals(id))).write(entry);
  }

  Future<void> deleteAsset(int id) {
    return (delete(assets)..where((e) => e.id.equals(id))).go();
  }
}
