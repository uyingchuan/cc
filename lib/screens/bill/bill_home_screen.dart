import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/bill.dart';
import '../../providers/bill_providers.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';

class BillHomeScreen extends ConsumerWidget {
  const BillHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final billsAsync = ref.watch(allBillsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('记账')),
      body: billsAsync.when(
        data: (bills) {
          if (bills.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long,
              title: '还没有账单',
              subtitle: '点击右下角记录你的支出',
            );
          }

          final stats = ref.watch(billStatsProvider);

          final groups = <String, List<Bill>>{};
          for (final bill in bills) {
            final key = DateFormat('yyyy-MM-dd').format(bill.billDate);
            groups.putIfAbsent(key, () => []).add(bill);
          }

          final items = <Widget>[];
          items.add(_buildStatsCard(context, stats));

          for (final key in groups.keys) {
            final groupBills = groups[key]!;
            final date = groupBills.first.billDate;
            final dayTotal =
                groupBills.fold<double>(0, (sum, b) => sum + b.amount);

            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final dateDay = DateTime(date.year, date.month, date.day);
            String label;
            if (dateDay == today) {
              label = '今天';
            } else if (dateDay == today.subtract(const Duration(days: 1))) {
              label = '昨天';
            } else if (date.year == now.year) {
              label = DateFormat('M月d日').format(date);
            } else {
              label = DateFormat('yyyy年M月d日').format(date);
            }

            items.add(Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(
                children: [
                  Text(label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      )),
                  const Spacer(),
                  Text(
                    '¥${NumberFormat('#,##0.00').format(dayTotal)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ));

            for (final bill in groupBills) {
              final catColor = Color(bill.category.color);
              items.add(Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: catColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(bill.category.icon, size: 22, color: catColor),
                  ),
                  title: Text(bill.note.isNotEmpty ? bill.note : bill.category.label,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(bill.category.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                  trailing: Text(
                    '-¥${NumberFormat('#,##0.00').format(bill.amount)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  onTap: () => context.push('/bills/${bill.id}/edit'),
                  onLongPress: () async {
                    final confirmed = await showConfirmDialog(
                      context,
                      title: '删除账单',
                      message: '确定要删除这条账单吗？',
                      confirmLabel: '删除',
                      destructive: true,
                    );
                    if (confirmed) {
                      ref.read(billRepositoryProvider).delete(bill.id);
                    }
                  },
                ),
              ));
            }
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: items,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('加载失败: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/bills/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

Widget _buildStatsCard(BuildContext context, BillPeriodStats stats) {
  final theme = Theme.of(context);

  return Card(
    margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildPeriod(
              context,
              '本周消费',
              stats.thisWeek,
              '上周消费',
              stats.lastWeek,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: 1,
              height: 44,
              color: theme.dividerColor.withAlpha(128),
            ),
          ),
          Expanded(
            child: _buildPeriod(
              context,
              '本月消费',
              stats.thisMonth,
              '上月消费',
              stats.lastMonth,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildPeriod(
  BuildContext context,
  String label,
  double current,
  String prevLabel,
  double previous,
) {
  final theme = Theme.of(context);

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      const SizedBox(height: 6),
      Text(
        '¥${NumberFormat('#,##0.00').format(current)}',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      const SizedBox(height: 10),
      Text(prevLabel,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      const SizedBox(height: 4),
      Text(
        '¥${NumberFormat('#,##0.00').format(previous)}',
        style: TextStyle(
          fontSize: 13,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    ],
  );
}
