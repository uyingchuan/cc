import 'package:drift/drift.dart';

import '../database/app_database.dart' hide Asset;
import '../database/app_database.dart' as db;
import '../models/asset.dart' as model;

class AssetRepository {
  final AppDatabase _db;

  AssetRepository(this._db);

  Stream<List<model.Asset>> watchAll() async* {
    await for (final data in _db.assetDao.watchAll()) {
      yield data.map(_toModel).toList();
    }
  }

  Future<List<model.Asset>> getAll() async {
    final data = await _db.assetDao.getAll();
    return data.map(_toModel).toList();
  }

  Future<model.Asset?> getById(int id) async {
    final data = await _db.assetDao.getById(id);
    if (data == null) return null;
    return _toModel(data);
  }

  Future<int> create({
    required String name,
    required double value,
    required model.AssetType type,
    String account = '',
    String note = '',
  }) {
    final now = DateTime.now();
    return _db.assetDao.insert(
      db.AssetsCompanion(
        name: Value(name),
        value: Value(value),
        type: Value(type.index),
        account: Value(account),
        note: Value(note),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> update({
    required int id,
    required String name,
    required double value,
    required model.AssetType type,
    String account = '',
    String note = '',
  }) {
    return _db.assetDao.updateAsset(
      id,
      db.AssetsCompanion(
        name: Value(name),
        value: Value(value),
        type: Value(type.index),
        account: Value(account),
        note: Value(note),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> delete(int id) => _db.assetDao.deleteAsset(id);

  model.Asset _toModel(db.Asset data) {
    return model.Asset(
      id: data.id,
      name: data.name,
      value: data.value,
      type: model.AssetType.fromValue(data.type),
      account: data.account,
      note: data.note,
      updatedAt: data.updatedAt,
    );
  }
}
