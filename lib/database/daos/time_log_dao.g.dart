// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_log_dao.dart';

// ignore_for_file: type=lint
mixin _$TimeLogDaoMixin on DatabaseAccessor<AppDatabase> {
  $TimeLogsTable get timeLogs => attachedDatabase.timeLogs;
  TimeLogDaoManager get managers => TimeLogDaoManager(this);
}

class TimeLogDaoManager {
  final _$TimeLogDaoMixin _db;
  TimeLogDaoManager(this._db);
  $$TimeLogsTableTableManager get timeLogs =>
      $$TimeLogsTableTableManager(_db.attachedDatabase, _db.timeLogs);
}
