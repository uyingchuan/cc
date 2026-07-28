import 'package:drift/drift.dart';

import '../app_database.dart';

part 'tag_dao.g.dart';

@DriftAccessor(tables: [Tags, EntryTags])
class TagDao extends DatabaseAccessor<AppDatabase> with _$TagDaoMixin {
  TagDao(super.db);

  Future<List<Tag>> getAll() {
    return (select(tags)..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
  }

  Stream<List<Tag>> watchAll() {
    return (select(tags)..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  Future<Tag?> getByName(String name) {
    return (select(tags)..where((t) => t.name.equals(name))).getSingleOrNull();
  }

  Future<int> insertTag(TagsCompanion tag) {
    return into(tags).insert(tag);
  }

  Future<void> updateTag(int id, TagsCompanion tag) {
    return (update(tags)..where((t) => t.id.equals(id))).write(tag);
  }

  Future<void> deleteTag(int id) {
    return (delete(tags)..where((t) => t.id.equals(id))).go();
  }

  Future<int> entryCountForTag(int tagId) {
    final query = selectOnly(entryTags)
      ..addColumns([entryTags.entryId])
      ..where(entryTags.tagId.equals(tagId));
    return query.map((r) => r.read(entryTags.entryId)).get().then((l) => l.length);
  }
}
