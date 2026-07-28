import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tag.dart';
import '../repositories/tag_repository.dart';
import 'database_provider.dart';

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  return TagRepository(ref.watch(appDatabaseProvider));
});

final allTagsProvider = StreamProvider<List<Tag>>((ref) {
  return ref.watch(tagRepositoryProvider).watchAll();
});
