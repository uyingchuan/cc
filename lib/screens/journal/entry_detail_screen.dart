import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/date_utils.dart';
import '../../providers/journal_providers.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/tag_chip.dart';

class EntryDetailScreen extends ConsumerWidget {
  final int entryId;

  const EntryDetailScreen({super.key, required this.entryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final entryAsync = ref.watch(entryProvider(entryId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/journal/$entryId/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirmed = await showConfirmDialog(
                context,
                title: '删除记录',
                message: '确定要删除这条记录吗？此操作不可撤销。',
                confirmLabel: '删除',
                destructive: true,
              );
              if (confirmed && context.mounted) {
                await ref.read(journalRepositoryProvider).delete(entryId);
                if (context.mounted) context.pop();
              }
            },
          ),
        ],
      ),
      body: entryAsync.when(
        data: (entry) {
          if (entry == null) {
            return const Center(child: Text('记录不存在'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and mood
                Row(
                  children: [
                    Text(
                      formatDateTime(entry.entryDate),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(entry.mood.color).withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            entry.mood.icon,
                            size: 16,
                            color: Color(entry.mood.color),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            entry.mood.label,
                            style: TextStyle(
                              color: Color(entry.mood.color),
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Title
                if (entry.title.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    entry.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],

                // Content
                const SizedBox(height: 16),
                Text(
                  entry.content,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.7),
                ),

                // Tags
                if (entry.tags.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: entry.tags
                        .map((t) => TagChip(tag: t))
                        .toList(),
                  ),
                ],

                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('加载失败: $err')),
      ),
    );
  }
}
