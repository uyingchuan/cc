import 'package:drift/drift.dart';

import '../database/app_database.dart' hide JournalEntry, Tag;
import '../database/app_database.dart' as db show JournalEntry;
import '../models/journal_entry.dart' as model;
import '../models/mood.dart';
import '../models/tag.dart' as model;

class JournalRepository {
  final AppDatabase _db;

  JournalRepository(this._db);

  Stream<List<model.JournalEntry>> watchAll() async* {
    await for (final data in _db.journalDao.watchAll()) {
      yield await Future.wait(data.map(_toEntry));
    }
  }

  Future<model.JournalEntry?> getById(int id) async {
    final data = await _db.journalDao.getById(id);
    if (data == null) return null;
    return _toEntry(data);
  }

  Future<List<model.JournalEntry>> search(String query) async {
    final data = await _db.journalDao.search(query);
    return Future.wait(data.map(_toEntry));
  }

  Future<List<model.JournalEntry>> getAllEntries() async {
    final data = await _db.journalDao.getAll();
    return Future.wait(data.map(_toEntry));
  }

  Future<List<model.JournalEntry>> filterByMood(Mood mood) async {
    final data = await _db.journalDao.filterByMood(mood.value);
    return Future.wait(data.map(_toEntry));
  }

  Future<List<model.JournalEntry>> filterByDateRange(
      DateTime start, DateTime end) async {
    final data = await _db.journalDao.filterByDateRange(start, end);
    return Future.wait(data.map(_toEntry));
  }

  Future<List<model.JournalEntry>> filterByTag(int tagId) async {
    final data = await _db.journalDao.filterByTag(tagId);
    return Future.wait(data.map(_toEntry));
  }

  Future<int> create({
    required String title,
    required String content,
    required Mood mood,
    required DateTime entryDate,
    List<int> tagIds = const [],
  }) async {
    final now = DateTime.now();
    final entryId = await _db.journalDao.insertEntry(
      JournalEntriesCompanion(
        title: Value(title),
        content: Value(content),
        mood: Value(mood.value),
        entryDate: Value(entryDate),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    if (tagIds.isNotEmpty) {
      await _db.journalDao.setEntryTags(entryId, tagIds);
    }
    return entryId;
  }

  Future<void> update({
    required int id,
    required String title,
    required String content,
    required Mood mood,
    required DateTime entryDate,
    List<int> tagIds = const [],
  }) async {
    await _db.journalDao.updateEntry(
      id,
      JournalEntriesCompanion(
        title: Value(title),
        content: Value(content),
        mood: Value(mood.value),
        entryDate: Value(entryDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await _db.journalDao.setEntryTags(id, tagIds);
  }

  Future<void> delete(int id) => _db.journalDao.deleteEntry(id);

  Future<int> entryCount() => _db.journalDao.entryCount();

  Future<model.JournalEntry> _toEntry(db.JournalEntry data) async {
    final tagData = await _db.journalDao.getTagsForEntry(data.id);
    return model.JournalEntry(
      id: data.id,
      title: data.title,
      content: data.content,
      mood: Mood.fromValue(data.mood),
      entryDate: data.entryDate,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      tags: tagData
          .map((t) => model.Tag(
                id: t.id,
                name: t.name,
                color: t.color,
                createdAt: t.createdAt,
              ))
          .toList(),
    );
  }
}
