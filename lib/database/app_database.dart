import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/mood.dart';
import 'daos/asset_dao.dart';
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

class Assets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get value => real()();
  IntColumn get type => integer()();
  TextColumn get account => text().withLength(min: 0, max: 100)();
  TextColumn get note => text().withLength(min: 0, max: 500)();
  DateTimeColumn get updatedAt => dateTime()();
}

@DriftDatabase(
  tables: [JournalEntries, Tags, EntryTags, Assets],
  daos: [JournalDao, TagDao, AssetDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'cc_journal');
  }

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(assets);
        }
        if (from < 3) {
          await m.addColumn(assets, assets.type);
          await customStatement('UPDATE assets SET type = 5 WHERE type IS NULL');
        }
        if (from < 4) {
          await m.addColumn(assets, assets.account);
          // Fix NULL values from potential broken v3 migration
          await customStatement('UPDATE assets SET type = 5 WHERE type IS NULL');
          await customStatement("UPDATE assets SET account = '' WHERE account IS NULL");
        }
      },
    );
  }
}
