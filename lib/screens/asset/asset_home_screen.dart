import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/asset_providers.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';

class AssetHomeScreen extends ConsumerWidget {
  const AssetHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final assetsAsync = ref.watch(allAssetsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('资产')),
      body: assetsAsync.when(
        data: (assets) {
          if (assets.isEmpty) {
            return const EmptyState(
              icon: Icons.account_balance_wallet,
              title: '还没有资产记录',
              subtitle: '点击右下角添加你的资产',
            );
          }

          final total = assets.fold<double>(0, (sum, a) => sum + a.value);

          return ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              // Total card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withAlpha(180),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('总资产',
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      '¥${NumberFormat('#,##0.00').format(total)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Asset list
              ...assets.map((asset) => Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(asset.name,
                                style:
                                    const TextStyle(fontWeight: FontWeight.w500)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Color(asset.type.color).withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              asset.type.label,
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(asset.type.color),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        asset.account.isNotEmpty
                            ? '${asset.account} · ${DateFormat('M月d日 HH:mm').format(asset.updatedAt)}'
                            : '更新于 ${DateFormat('M月d日 HH:mm').format(asset.updatedAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Text(
                        '¥${NumberFormat('#,##0.00').format(asset.value)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      onTap: () => context.push('/assets/${asset.id}/edit'),
                      onLongPress: () async {
                        final confirmed = await showConfirmDialog(
                          context,
                          title: '删除资产',
                          message: '确定要删除「${asset.name}」吗？',
                          confirmLabel: '删除',
                          destructive: true,
                        );
                        if (confirmed) {
                          ref.read(assetRepositoryProvider).delete(asset.id);
                        }
                      },
                    ),
                  )),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('加载失败: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/assets/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
