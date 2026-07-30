import 'package:drift/drift.dart';

import '../app_database.dart';

part 'bill_dao.g.dart';

@DriftAccessor(tables: [Bills])
class BillDao extends DatabaseAccessor<AppDatabase> with _$BillDaoMixin {
  BillDao(super.db);

  Stream<List<Bill>> watchAll() {
    return (select(bills)
          ..orderBy(
              [(e) => OrderingTerm(expression: e.billDate, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<List<Bill>> getAll() {
    return (select(bills)
          ..orderBy(
              [(e) => OrderingTerm(expression: e.billDate, mode: OrderingMode.desc)]))
        .get();
  }

  Future<Bill?> getById(int id) {
    return (select(bills)..where((e) => e.id.equals(id))).getSingleOrNull();
  }

  Future<int> insert(BillsCompanion entry) {
    return into(bills).insert(entry);
  }

  Future<void> updateBill(int id, BillsCompanion entry) {
    return (update(bills)..where((e) => e.id.equals(id))).write(entry);
  }

  Future<void> deleteBill(int id) {
    return (delete(bills)..where((e) => e.id.equals(id))).go();
  }
}
