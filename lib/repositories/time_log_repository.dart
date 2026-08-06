import 'package:drift/drift.dart';

import '../database/app_database.dart' hide TimeLog;
import '../database/app_database.dart' as db;
import '../models/time_log.dart' as model;

class TimeLogRepository {
  final AppDatabase _db;

  TimeLogRepository(this._db);

  Stream<List<model.TimeLog>> watchDate(DateTime date) async* {
    await for (final data in _db.timeLogDao.watchDate(date)) {
      yield data.map(_toModel).toList();
    }
  }

  Future<model.TimeLog?> getById(int id) async {
    final data = await _db.timeLogDao.getById(id);
    if (data == null) return null;
    return _toModel(data);
  }

  Future<int> create({
    required model.TimeCategory category,
    required DateTime startTime,
    required int durationMin,
    String note = '',
  }) {
    return _db.timeLogDao.insert(
      db.TimeLogsCompanion(
        category: Value(category.index),
        startTime: Value(startTime),
        durationMin: Value(durationMin),
        note: Value(note),
        createdAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> update({
    required int id,
    required model.TimeCategory category,
    required DateTime startTime,
    required int durationMin,
    String note = '',
  }) {
    return _db.timeLogDao.updateLog(
      id,
      db.TimeLogsCompanion(
        category: Value(category.index),
        startTime: Value(startTime),
        durationMin: Value(durationMin),
        note: Value(note),
      ),
    );
  }

  Future<void> delete(int id) => _db.timeLogDao.deleteLog(id);

  model.TimeLog _toModel(db.TimeLog data) {
    return model.TimeLog(
      id: data.id,
      category: model.TimeCategory.fromValue(data.category),
      startTime: data.startTime,
      durationMin: data.durationMin,
      note: data.note,
      createdAt: data.createdAt,
    );
  }
}
