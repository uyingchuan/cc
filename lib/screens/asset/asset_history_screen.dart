import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/asset_providers.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';

class AssetHistoryScreen extends ConsumerStatefulWidget {
  final String assetName;
  final int assetId;

  const AssetHistoryScreen({
    super.key,
    required this.assetName,
    required this.assetId,
  });

  @override
  ConsumerState<AssetHistoryScreen> createState() => _AssetHistoryScreenState();
}

class _AssetHistoryScreenState extends ConsumerState<AssetHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(assetHistoryProvider(widget.assetId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final historyAsync = ref.watch(assetHistoryProvider(widget.assetId));

    return Scaffold(
      appBar: AppBar(title: Text('${widget.assetName} 历史')),
      body: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return const EmptyState(
              icon: Icons.timeline,
              title: '还没有历史数据',
              subtitle: '更新资产金额后会自动记录历史',
            );
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: history.map((h) {
              final profit = h.value - h.principal;
              final rate = h.principal > 0 ? profit / h.principal * 100 : 0;
              final up = profit >= 0;
              return ListTile(
                title: Text(
                  DateFormat('yyyy年M月d日').format(h.date),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  '本金 ¥${NumberFormat('#,##0.00').format(h.principal)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '¥${NumberFormat('#,##0.00').format(h.value)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${up ? '+' : ''}¥${NumberFormat('#,##0.00').format(profit)} (${rate.toStringAsFixed(1)}%)',
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
                    title: '删除历史',
                    message: '确定要删除 ${DateFormat('M月d日').format(h.date)} 的历史记录吗？',
                    confirmLabel: '删除',
                    destructive: true,
                  );
                  if (confirmed) {
                    ref
                        .read(assetRepositoryProvider)
                        .deleteHistory(widget.assetId, h.date);
                    ref.invalidate(assetHistoryProvider(widget.assetId));
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
