import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/date_utils.dart';
import '../../models/mood.dart';
import '../../providers/journal_providers.dart';
import '../../widgets/empty_state.dart';

class JournalHomeScreen extends ConsumerStatefulWidget {
  const JournalHomeScreen({super.key});

  @override
  ConsumerState<JournalHomeScreen> createState() => _JournalHomeScreenState();
}

class _JournalHomeScreenState extends ConsumerState<JournalHomeScreen> {
  final _contentController = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();
  Mood _selectedMood = Mood.neutral;
  bool _isSubmitting = false;
  Timer? _refreshTimer;
  int _previousLength = 0;

  @override
  void dispose() {
    _contentController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
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
      _focusNode.requestFocus();
      _scrollToBottom();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showMoodPicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('选择心情',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: Mood.values.map((mood) {
                    final isSelected = _selectedMood == mood;
                    final color = Color(mood.color);
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedMood = mood);
                        Navigator.pop(ctx);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 80,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withAlpha(25)
                              : theme.colorScheme.surfaceContainerHighest
                                  .withAlpha(120),
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected
                              ? Border.all(color: color, width: 1.5)
                              : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(mood.icon, size: 32, color: color),
                            const SizedBox(height: 6),
                            Text(mood.label,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: isSelected
                                        ? color
                                        : theme.colorScheme.onSurface,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entriesAsync = ref.watch(allEntriesProvider);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    // Reset timer on each build
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('随手记'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/journal/search'),
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => context.push('/journal/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat timeline
          Expanded(
            child: GestureDetector(
              onTap: () => _focusNode.unfocus(),
              child: entriesAsync.when(
                data: (entries) {
                  if (entries.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 120),
                        EmptyState(
                          icon: Icons.auto_stories,
                          title: '还没有记录',
                          subtitle: '在下方输入框记录你的想法和感受',
                        ),
                      ],
                    );
                  }

                  // Reverse: oldest first (chat style)
                  final reversed = entries.reversed.toList();

                  // Auto-scroll on new entries
                  if (reversed.length > _previousLength) {
                    _previousLength = reversed.length;
                    if (_previousLength > 7) {
                      _scrollToBottom();
                    }
                  }

                  // Build chat items with date separators
                  final items = <Widget>[];
                  String? lastDateKey;
                  for (final entry in reversed) {
                    final dateKey = DateFormat('yyyy-MM-dd').format(entry.entryDate);
                    if (dateKey != lastDateKey) {
                      lastDateKey = dateKey;
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      final dateDay = DateTime(
                          entry.entryDate.year, entry.entryDate.month, entry.entryDate.day);
                      String label;
                      if (dateDay == today) {
                        label = '今天';
                      } else if (dateDay == today.subtract(const Duration(days: 1))) {
                        label = '昨天';
                      } else if (entry.entryDate.year == now.year) {
                        label = DateFormat('M月d日').format(entry.entryDate);
                      } else {
                        label = DateFormat('yyyy年M月d日').format(entry.entryDate);
                      }
                      items.add(Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(label,
                              style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant)),
                        ),
                      ));
                    }

                    // Chat bubble
                    final moodColor = Color(entry.mood.color);
                    items.add(Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      child: GestureDetector(
                        onTap: () => context.push('/journal/${entry.id}'),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Mood icon
                            Container(
                              width: 36,
                              height: 36,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                color: moodColor.withAlpha(25),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(entry.mood.icon, size: 20, color: moodColor),
                            ),
                            const SizedBox(width: 8),
                            // Content bubble
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(entry.content,
                                        style: theme.textTheme.bodyMedium),
                                    const SizedBox(height: 2),
                                    Text(
                                      formatDate(entry.entryDate),
                                      style: theme.textTheme.labelSmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                          fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ));
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: items.length,
                    itemBuilder: (_, i) => items[i],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('加载失败: $err')),
              ),
            ),
          ),

          // Bottom input bar
          Container(
            padding: EdgeInsets.only(
              left: 8,
              right: 8,
              top: 8,
              bottom: bottomPadding > 0 ? 8 : bottomSafe + 8,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                // Mood icon
                GestureDetector(
                  onTap: _showMoodPicker,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(_selectedMood.color).withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _selectedMood.icon,
                      size: 24,
                      color: Color(_selectedMood.color),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Text field
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    focusNode: _focusNode,
                    maxLines: 4,
                    minLines: 1,
                    textInputAction: TextInputAction.newline,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: '记录此刻...',
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Send button
                _isSubmitting
                    ? SizedBox(
                        width: 40,
                        height: 40,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: _send,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
