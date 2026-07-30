import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/asset.dart';
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

          final totalValue = assets.fold<double>(0, (sum, a) => sum + a.value);
          final totalPrincipal = assets.fold<double>(0, (sum, a) => sum + a.principal);
          final totalProfit = totalValue - totalPrincipal;
          final totalRate = totalPrincipal > 0 ? totalProfit / totalPrincipal * 100 : 0.0;

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
                      '¥${NumberFormat('#,##0.00').format(totalValue)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _TotalItem('本金', totalPrincipal),
                        _TotalItem('收益',
                            totalProfit,
                            color: totalProfit >= 0 ? Colors.lightGreenAccent : Colors.redAccent),
                        _TotalItem('收益率',
                            totalRate,
                            color: totalRate >= 0 ? Colors.lightGreenAccent : Colors.redAccent,
                            suffix: '%'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () async {
                            await ref.read(assetRepositoryProvider).takeSnapshot();
                            ref.invalidate(snapshotsProvider);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('快照已保存')),
                              );
                            }
                          },
                          icon: const Icon(Icons.camera_alt_outlined, size: 16,
                              color: Colors.white70),
                          label: const Text('记录快照',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => context.push('/assets/snapshots'),
                          child: const Text('快照历史',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Asset list grouped by type
              for (final type in AssetType.values)
                if (assets.any((a) => a.type == type)) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Color(type.color),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(type.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(type.color),
                            )),
                        const Spacer(),
                        Text(
                          '¥${NumberFormat('#,##0.00').format(assets.where((a) => a.type == type).fold<double>(0, (s, a) => s + a.value))}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...assets
                      .where((a) => a.type == type)
                      .map((asset) => Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 3),
                            child: ListTile(
                              title: Text(asset.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)),
                              subtitle: Text(
                                [
                                  if (asset.account.isNotEmpty) asset.account,
                                  '市值 ¥${NumberFormat('#,##0.00').format(asset.value)}',
                                  if (asset.principal > 0)
                                    '${asset.profit >= 0 ? '+' : ''}¥${NumberFormat('#,##0.00').format(asset.profit)}',
                                ].join(' · '),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              leading: IconButton(
                                icon: const Icon(Icons.timeline, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                    minWidth: 32, minHeight: 32),
                                onPressed: () => context.push(
                                  '/assets/${asset.id}/history?name=${Uri.encodeComponent(asset.name)}',
                                ),
                              ),
                              trailing: asset.principal > 0
                                  ? Text(
                                      '${asset.profitRate.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: asset.profit >= 0
                                            ? Colors.green
                                            : theme.colorScheme.error,
                                      ),
                                    )
                                  : null,
                              onTap: () => context.push('/assets/${asset.id}/edit',
                                  extra: asset),
                              onLongPress: () async {
                                final confirmed = await showConfirmDialog(
                                  context,
                                  title: '删除资产',
                                  message: '确定要删除「${asset.name}」吗？',
                                  confirmLabel: '删除',
                                  destructive: true,
                                );
                                if (confirmed) {
                                  ref
                                      .read(assetRepositoryProvider)
                                      .delete(asset.id);
                                }
                              },
                            ),
                          )),
                ],
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

class _TotalItem extends StatelessWidget {
  final String label;
  final double value;
  final Color? color;
  final String? suffix;

  const _TotalItem(this.label, this.value, {this.color, this.suffix});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 2),
        Text(
          suffix != null
              ? '${value.toStringAsFixed(1)}$suffix'
              : '¥${NumberFormat('#,##0.00').format(value)}',
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
