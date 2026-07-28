import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/journal_providers.dart';
import '../../providers/tag_providers.dart';
import '../../repositories/export_service.dart';
import '../../widgets/confirm_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          // Tags section
          _SectionHeader(title: '标签管理'),
          ref.watch(allTagsProvider).when(
                data: (tags) => Column(
                  children: [
                    ...tags.map((tag) => ListTile(
                          leading: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Color(tag.color),
                              shape: BoxShape.circle,
                            ),
                          ),
                          title: Text(tag.name),
                          trailing: IconButton(
                            icon:
                                const Icon(Icons.delete_outline, size: 20),
                            onPressed: () async {
                              final confirmed = await showConfirmDialog(
                                context,
                                title: '删除标签',
                                message: '确定要删除「${tag.name}」吗？',
                                confirmLabel: '删除',
                                destructive: true,
                              );
                              if (confirmed) {
                                await ref
                                    .read(tagRepositoryProvider)
                                    .delete(tag.id);
                              }
                            },
                          ),
                        )),
                    ListTile(
                      leading: const Icon(Icons.add, size: 20),
                      title: const Text('添加标签'),
                      onTap: () => _showAddTagDialog(context, ref),
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('加载失败: $err'),
              ),

          const Divider(),

          // Export
          _SectionHeader(title: '数据'),
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: const Text('导出数据'),
            subtitle: const Text('导出为 JSON 文件，可用于 AI 分析'),
            onTap: () async {
              try {
                final service = ExportService(
                  ref.read(journalRepositoryProvider),
                  ref.read(tagRepositoryProvider),
                );
                await service.exportToFile();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('导出成功')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('导出失败: $e')),
                  );
                }
              }
            },
          ),

          const Divider(),

          // About
          _SectionHeader(title: '关于'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('CC'),
            subtitle: Text('v1.0.0'),
          ),
        ],
      ),
    );
  }

  void _showAddTagDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    int selectedColor = 0xFF6366F1;

    final colors = [
      0xFF6366F1,
      0xFFEC4899,
      0xFFF59E0B,
      0xFF10B981,
      0xFF3B82F6,
      0xFF8B5CF6,
      0xFFEF4444,
      0xFF14B8A6,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('添加标签'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: '标签名称',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: colors.map((c) {
                  final isSelected = selectedColor == c;
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedColor = c),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                        boxShadow: isSelected
                            ? [BoxShadow(color: Color(c).withAlpha(100), blurRadius: 6)]
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  ref.read(tagRepositoryProvider).create(name, selectedColor);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
