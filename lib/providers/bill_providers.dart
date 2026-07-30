import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bill.dart';
import '../repositories/bill_repository.dart';
import 'database_provider.dart';

final billRepositoryProvider = Provider<BillRepository>((ref) {
  return BillRepository(ref.watch(appDatabaseProvider));
});

final allBillsProvider = StreamProvider<List<Bill>>((ref) {
  return ref.watch(billRepositoryProvider).watchAll();
});

final billProvider = FutureProvider.family<Bill?, int>((ref, id) {
  return ref.watch(billRepositoryProvider).getById(id);
});
