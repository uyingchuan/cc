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

class BillPeriodStats {
  final double thisWeek;
  final double lastWeek;
  final double thisMonth;
  final double lastMonth;

  const BillPeriodStats({
    this.thisWeek = 0,
    this.lastWeek = 0,
    this.thisMonth = 0,
    this.lastMonth = 0,
  });
}

final billStatsProvider = Provider<BillPeriodStats>((ref) {
  final bills = ref.watch(allBillsProvider).asData?.value ?? [];
  return _computeStats(bills);
});

BillPeriodStats _computeStats(List<Bill> bills) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
  final thisWeekEnd = thisWeekStart.add(const Duration(days: 6));

  final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
  final lastWeekEnd = thisWeekStart.subtract(const Duration(days: 1));

  final thisMonthStart = DateTime(now.year, now.month, 1);
  final thisMonthEnd = DateTime(now.year, now.month + 1, 0);

  final lastMonthStart = DateTime(now.year, now.month - 1, 1);
  final lastMonthEnd = DateTime(now.year, now.month, 0);

  double sum(DateTime start, DateTime end) {
    return bills.where((b) {
      final d = DateTime(b.billDate.year, b.billDate.month, b.billDate.day);
      return !d.isBefore(start) && !d.isAfter(end);
    }).fold(0.0, (s, b) => s + b.amount);
  }

  return BillPeriodStats(
    thisWeek: sum(thisWeekStart, thisWeekEnd),
    lastWeek: sum(lastWeekStart, lastWeekEnd),
    thisMonth: sum(thisMonthStart, thisMonthEnd),
    lastMonth: sum(lastMonthStart, lastMonthEnd),
  );
}
