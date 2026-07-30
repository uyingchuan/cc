// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_dao.dart';

// ignore_for_file: type=lint
mixin _$AssetDaoMixin on DatabaseAccessor<AppDatabase> {
  $AssetsTable get assets => attachedDatabase.assets;
  $AssetHistoriesTable get assetHistories => attachedDatabase.assetHistories;
  AssetDaoManager get managers => AssetDaoManager(this);
}

class AssetDaoManager {
  final _$AssetDaoMixin _db;
  AssetDaoManager(this._db);
  $$AssetsTableTableManager get assets =>
      $$AssetsTableTableManager(_db.attachedDatabase, _db.assets);
  $$AssetHistoriesTableTableManager get assetHistories =>
      $$AssetHistoriesTableTableManager(
        _db.attachedDatabase,
        _db.assetHistories,
      );
}
