import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/journal_entry.dart';
import '../repositories/journal_repository.dart';
import 'database_provider.dart';

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepository(ref.watch(appDatabaseProvider));
});

final allEntriesProvider = StreamProvider<List<JournalEntry>>((ref) {
  return ref.watch(journalRepositoryProvider).watchAll();
});

final entryProvider =
    FutureProvider.family<JournalEntry?, int>((ref, id) {
  return ref.watch(journalRepositoryProvider).getById(id);
});

final entryCountProvider = FutureProvider<int>((ref) {
  return ref.watch(journalRepositoryProvider).entryCount();
});
