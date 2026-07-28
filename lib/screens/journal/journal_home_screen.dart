import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/mood.dart';
import '../../providers/journal_providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/entry_card.dart';
import '../../widgets/mood_selector.dart';

class JournalHomeScreen extends ConsumerStatefulWidget {
  const JournalHomeScreen({super.key});

  @override
  ConsumerState<JournalHomeScreen> createState() => _JournalHomeScreenState();
}

class _JournalHomeScreenState extends ConsumerState<JournalHomeScreen> {
  final _contentController = TextEditingController();
  Mood _selectedMood = Mood.neutral;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _quickCapture() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(journalRepositoryProvider).create(
            title: '',
            content: content,
            mood: _selectedMood,
            entryDate: DateTime.now(),
          );
      _contentController.clear();
      setState(() => _selectedMood = Mood.neutral);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entriesAsync = ref.watch(allEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('随手记'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/journal/search'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick capture area
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _contentController,
                  maxLines: 3,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: '记录此刻...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                    suffixIcon: _isSubmitting
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.send_rounded),
                            color: theme.colorScheme.primary,
                            onPressed: () => _quickCapture(),
                          ),
                  ),
                  textInputAction: TextInputAction.newline,
                  onSubmitted: (_) => _quickCapture(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    MoodSelector(
                      selectedMood: _selectedMood,
                      onChanged: (mood) =>
                          setState(() => _selectedMood = mood),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      icon: const Icon(Icons.edit_note, size: 18),
                      label: const Text('详细记录'),
                      onPressed: () => context.push('/journal/new'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Timeline
          Expanded(
            child: entriesAsync.when(
              data: (entries) {
                if (entries.isEmpty) {
                  return const EmptyState(
                    icon: Icons.auto_stories,
                    title: '还没有记录',
                    subtitle: '在上方输入框快速记录你的想法和感受',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return EntryCard(
                      entry: entry,
                      onTap: () => context.push('/journal/${entry.id}'),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('加载失败: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
