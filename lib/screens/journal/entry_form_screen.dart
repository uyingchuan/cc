import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/mood.dart';
import '../../models/tag.dart';
import '../../providers/journal_providers.dart';
import '../../widgets/mood_selector.dart';
import '../../widgets/tag_selector.dart';

class EntryFormScreen extends ConsumerStatefulWidget {
  final int? entryId;

  const EntryFormScreen({super.key, this.entryId});

  @override
  ConsumerState<EntryFormScreen> createState() => _EntryFormScreenState();
}

class _EntryFormScreenState extends ConsumerState<EntryFormScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  Mood _mood = Mood.neutral;
  DateTime _entryDate = DateTime.now();
  List<Tag> _selectedTags = [];
  bool _isSaving = false;
  bool _initialized = false;

  bool get isEditing => widget.entryId != null;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadEntry() async {
    if (widget.entryId == null) return;
    final entry = await ref.read(entryProvider(widget.entryId!).future);
    if (entry == null) return;

    _titleController.text = entry.title;
    _contentController.text = entry.content;
    _mood = entry.mood;
    _entryDate = entry.entryDate;
    _selectedTags = entry.tags;
    _initialized = true;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadEntry();
    } else {
      _initialized = true;
    }
  }

  Future<void> _save() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入内容')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(journalRepositoryProvider);
      final tagIds = _selectedTags.map((t) => t.id).toList();

      if (isEditing) {
        await repo.update(
          id: widget.entryId!,
          title: _titleController.text.trim(),
          content: content,
          mood: _mood,
          entryDate: _entryDate,
          tagIds: tagIds,
        );
      } else {
        await repo.create(
          title: _titleController.text.trim(),
          content: content,
          mood: _mood,
          entryDate: _entryDate,
          tagIds: tagIds,
        );
      }
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '编辑记录' : '新增记录'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('保存'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date picker
            Row(
              children: [
                const Text('日期：', style: TextStyle(fontSize: 14)),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _entryDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _entryDate = picked);
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_entryDate.year}年${_entryDate.month}月${_entryDate.day}日',
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Mood
            const Text('心情：', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            MoodSelector(
              selectedMood: _mood,
              onChanged: (mood) => setState(() => _mood = mood),
            ),

            const SizedBox(height: 16),

            // Title
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '标题（可选）',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),

            const SizedBox(height: 12),

            // Content
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: '记录你想记录的一切...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),

            const SizedBox(height: 16),

            // Tags
            const Text('标签：', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            TagSelector(
              selectedTags: _selectedTags,
              onChanged: (tags) => setState(() => _selectedTags = tags),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
