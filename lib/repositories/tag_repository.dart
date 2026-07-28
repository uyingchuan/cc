import 'package:drift/drift.dart';

import '../database/app_database.dart' hide Tag;
import '../database/app_database.dart' as db show Tag;
import '../models/tag.dart' as model;

class TagRepository {
  final AppDatabase _db;

  TagRepository(this._db);

  Stream<List<model.Tag>> watchAll() async* {
    await for (final data in _db.tagDao.watchAll()) {
      yield data.map(_toTag).toList();
    }
  }

  Future<List<model.Tag>> getAll() async {
    final data = await _db.tagDao.getAll();
    return data.map(_toTag).toList();
  }

  Future<model.Tag?> getByName(String name) async {
    final data = await _db.tagDao.getByName(name);
    if (data == null) return null;
    return _toTag(data);
  }

  Future<int> create(String name, int color) {
    return _db.tagDao.insertTag(
      TagsCompanion(
        name: Value(name),
        color: Value(color),
        createdAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> update(int id, String name, int color) {
    return _db.tagDao.updateTag(
      id,
      TagsCompanion(
        name: Value(name),
        color: Value(color),
      ),
    );
  }

  Future<void> delete(int id) => _db.tagDao.deleteTag(id);

  Future<int> entryCountForTag(int tagId) =>
      _db.tagDao.entryCountForTag(tagId);

  model.Tag _toTag(db.Tag t) => model.Tag(
        id: t.id,
        name: t.name,
        color: t.color,
        createdAt: t.createdAt,
      );
}
