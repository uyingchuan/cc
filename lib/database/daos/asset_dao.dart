import 'package:drift/drift.dart';

import '../app_database.dart';

part 'asset_dao.g.dart';

@DriftAccessor(tables: [Assets, AssetHistories])
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

  Future<void> upsertHistory(int assetId, double value, double principal) {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return customStatement(
      'INSERT OR REPLACE INTO asset_histories (asset_id, value, principal, date) '
      'VALUES (?, ?, ?, ?)',
      [assetId, value, principal, today.millisecondsSinceEpoch],
    );
  }

  Future<List<AssetHistory>> getHistory(int assetId) {
    return (select(assetHistories)
          ..where((e) => e.assetId.equals(assetId))
          ..orderBy([(e) => OrderingTerm(expression: e.date, mode: OrderingMode.asc)]))
        .get();
  }
}
