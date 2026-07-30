import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/asset_providers.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';

class SnapshotHistoryScreen extends ConsumerStatefulWidget {
  const SnapshotHistoryScreen({super.key});

  @override
  ConsumerState<SnapshotHistoryScreen> createState() =>
      _SnapshotHistoryScreenState();
}

class _SnapshotHistoryScreenState extends ConsumerState<SnapshotHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(snapshotsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final snapshotsAsync = ref.watch(snapshotsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('总资产快照')),
      body: snapshotsAsync.when(
        data: (snapshots) {
          if (snapshots.isEmpty) {
            return const EmptyState(
              icon: Icons.timeline,
              title: '还没有快照',
              subtitle: '在资产页面点击"记录快照"保存当前资产状态',
            );
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: snapshots.map((s) {
              final profit = s.profit;
              final up = profit >= 0;
              return ListTile(
                title: Text(
                  DateFormat('yyyy年M月d日').format(s.date),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  '本金 ¥${NumberFormat('#,##0.00').format(s.totalPrincipal)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '¥${NumberFormat('#,##0.00').format(s.totalValue)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${up ? '+' : ''}¥${NumberFormat('#,##0.00').format(profit)} (${s.profitRate.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        fontSize: 11,
                        color: up ? Colors.green : theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
                onLongPress: () async {
                  final confirmed = await showConfirmDialog(
                    context,
                    title: '删除快照',
                    message: '确定要删除 ${DateFormat('M月d日').format(s.date)} 的快照吗？',
                    confirmLabel: '删除',
                    destructive: true,
                  );
                  if (confirmed) {
                    ref.read(assetRepositoryProvider).deleteSnapshot(s.date);
                    ref.invalidate(snapshotsProvider);
                  }
                },
              );
            }).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('加载失败: $err')),
      ),
    );
  }
}
