import 'package:drift/drift.dart';

import '../app_database.dart';

part 'journal_dao.g.dart';

@DriftAccessor(tables: [JournalEntries, EntryTags, Tags])
class JournalDao extends DatabaseAccessor<AppDatabase>
    with _$JournalDaoMixin {
  JournalDao(super.db);

  Future<List<JournalEntry>> getAll() {
    return (select(journalEntries)
          ..orderBy(
              [(e) => OrderingTerm(expression: e.entryDate, mode: OrderingMode.desc)]))
        .get();
  }

  Stream<List<JournalEntry>> watchAll() {
    return (select(journalEntries)
          ..orderBy(
              [(e) => OrderingTerm(expression: e.entryDate, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<JournalEntry?> getById(int id) {
    return (select(journalEntries)..where((e) => e.id.equals(id))).getSingleOrNull();
  }

  Future<List<JournalEntry>> search(String query) {
    final q = '%$query%';
    return (select(journalEntries)
          ..where((e) => e.title.like(q) | e.content.like(q))
          ..orderBy(
              [(e) => OrderingTerm(expression: e.entryDate, mode: OrderingMode.desc)]))
        .get();
  }

  Future<List<JournalEntry>> filterByMood(int mood) {
    return (select(journalEntries)
          ..where((e) => e.mood.equals(mood))
          ..orderBy(
              [(e) => OrderingTerm(expression: e.entryDate, mode: OrderingMode.desc)]))
        .get();
  }

  Future<List<JournalEntry>> filterByDateRange(
      DateTime start, DateTime end) {
    return (select(journalEntries)
          ..where((e) => e.entryDate.isBetweenValues(start, end))
          ..orderBy(
              [(e) => OrderingTerm(expression: e.entryDate, mode: OrderingMode.desc)]))
        .get();
  }

  Future<List<JournalEntry>> filterByTag(int tagId) {
    final query = select(journalEntries).join([
      innerJoin(entryTags, entryTags.entryId.equalsExp(journalEntries.id)),
    ])
      ..where(entryTags.tagId.equals(tagId))
      ..orderBy([OrderingTerm(expression: journalEntries.entryDate, mode: OrderingMode.desc)]);

    return query.map((row) => row.readTable(journalEntries)).get();
  }

  Future<int> insertEntry(JournalEntriesCompanion entry) {
    return into(journalEntries).insert(entry);
  }

  Future<void> updateEntry(int id, JournalEntriesCompanion entry) {
    return (update(journalEntries)..where((e) => e.id.equals(id))).write(entry);
  }

  Future<void> deleteEntry(int id) {
    return (delete(journalEntries)..where((e) => e.id.equals(id))).go();
  }

  Future<int> entryCount() {
    return journalEntries.count().getSingle();
  }

  Future<List<Tag>> getTagsForEntry(int entryId) {
    final query = select(tags).join([
      innerJoin(entryTags, entryTags.tagId.equalsExp(tags.id)),
    ])
      ..where(entryTags.entryId.equals(entryId));
    return query.map((row) => row.readTable(tags)).get();
  }

  Future<void> setEntryTags(int entryId, List<int> tagIds) async {
    await transaction(() async {
      await (delete(entryTags)..where((e) => e.entryId.equals(entryId))).go();
      for (final tagId in tagIds) {
        await into(entryTags).insert(
            EntryTagsCompanion(entryId: Value(entryId), tagId: Value(tagId)));
      }
    });
  }
}
