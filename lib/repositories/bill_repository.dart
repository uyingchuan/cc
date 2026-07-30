import 'package:drift/drift.dart';

import '../database/app_database.dart' hide Bill;
import '../database/app_database.dart' as db;
import '../models/bill.dart' as model;

class BillRepository {
  final AppDatabase _db;

  BillRepository(this._db);

  Stream<List<model.Bill>> watchAll() async* {
    await for (final data in _db.billDao.watchAll()) {
      yield data.map(_toModel).toList();
    }
  }

  Future<model.Bill?> getById(int id) async {
    final data = await _db.billDao.getById(id);
    if (data == null) return null;
    return _toModel(data);
  }

  Future<int> create({
    required double amount,
    required model.BillCategory category,
    String note = '',
    required DateTime billDate,
  }) {
    return _db.billDao.insert(
      db.BillsCompanion(
        amount: Value(amount),
        category: Value(category.index),
        note: Value(note),
        billDate: Value(billDate),
        createdAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> update({
    required int id,
    required double amount,
    required model.BillCategory category,
    String note = '',
    required DateTime billDate,
  }) {
    return _db.billDao.updateBill(
      id,
      db.BillsCompanion(
        amount: Value(amount),
        category: Value(category.index),
        note: Value(note),
        billDate: Value(billDate),
      ),
    );
  }

  Future<void> delete(int id) => _db.billDao.deleteBill(id);

  model.Bill _toModel(db.Bill data) {
    return model.Bill(
      id: data.id,
      amount: data.amount,
      category: model.BillCategory.fromValue(data.category),
      note: data.note,
      billDate: data.billDate,
      createdAt: data.createdAt,
    );
  }
}
