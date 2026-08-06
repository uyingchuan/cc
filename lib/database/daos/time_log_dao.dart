import 'package:drift/drift.dart';

import '../app_database.dart';

part 'time_log_dao.g.dart';

@DriftAccessor(tables: [TimeLogs])
class TimeLogDao extends DatabaseAccessor<AppDatabase> with _$TimeLogDaoMixin {
  TimeLogDao(super.db);

  Stream<List<TimeLog>> watchDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (select(timeLogs)
          ..where((e) => e.startTime.isBetweenValues(start, end))
          ..orderBy([(e) => OrderingTerm(expression: e.startTime, mode: OrderingMode.asc)]))
        .watch();
  }

  Future<TimeLog?> getById(int id) {
    return (select(timeLogs)..where((e) => e.id.equals(id))).getSingleOrNull();
  }

  Future<int> insert(TimeLogsCompanion entry) {
    return into(timeLogs).insert(entry);
  }

  Future<void> updateLog(int id, TimeLogsCompanion entry) {
    return (update(timeLogs)..where((e) => e.id.equals(id))).write(entry);
  }

  Future<void> deleteLog(int id) {
    return (delete(timeLogs)..where((e) => e.id.equals(id))).go();
  }
}
