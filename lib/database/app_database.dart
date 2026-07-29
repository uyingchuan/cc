import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/mood.dart';
import 'daos/journal_dao.dart';
import 'daos/tag_dao.dart';

part 'app_database.g.dart';

class JournalEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 0, max: 255)();
  TextColumn get content => text()();
  IntColumn get mood => integer()();
  DateTimeColumn get entryDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  List<TableIndex> get indexes => [
        TableIndex(name: 'idx_entry_date', columns: {entryDate}),
        TableIndex(name: 'idx_created_at', columns: {createdAt}),
        TableIndex(name: 'idx_mood', columns: {mood}),
      ];
}

class MoodConverter extends TypeConverter<Mood, int> {
  const MoodConverter();

  @override
  Mood fromSql(int fromDb) => Mood.fromValue(fromDb);

  @override
  int toSql(Mood value) => value.value;
}

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  IntColumn get color => integer()();
  DateTimeColumn get createdAt => dateTime()();
}

class EntryTags extends Table {
  IntColumn get entryId =>
      integer().references(JournalEntries, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId =>
      integer().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {entryId, tagId};
}

@DriftDatabase(
  tables: [JournalEntries, Tags, EntryTags],
  daos: [JournalDao, TagDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'cc_journal');
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
    );
  }
}
