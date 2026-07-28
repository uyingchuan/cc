import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/journal_entry.dart';
import '../../models/mood.dart';
import '../../providers/filter_providers.dart';
import '../../providers/journal_providers.dart';
import '../../providers/tag_providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/entry_card.dart';
import '../../widgets/tag_chip.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  List<JournalEntry> _results = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final filter = ref.read(journalFilterProvider);
    final query = _searchController.text.trim();
    final repo = ref.read(journalRepositoryProvider);

    setState(() => _isSearching = true);
    try {
      List<JournalEntry> entries;
      if (query.isNotEmpty) {
        entries = await repo.search(query);
      } else {
        entries = await repo.getAllEntries();
      }

      // Apply additional filters
      if (filter.mood != null) {
        entries = entries.where((e) => e.mood == filter.mood).toList();
      }
      if (filter.selectedTags.isNotEmpty) {
        entries = entries
            .where((e) => e.tags
                .any((t) => filter.selectedTags.any((ft) => ft.id == t.id)))
            .toList();
      }

      setState(() => _results = entries);
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(journalFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '搜索关键词...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: _search,
            ),
          ),
          onSubmitted: (_) => _search(),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mood filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('全部'),
                        selected: filter.mood == null,
                        onSelected: (_) {
                          ref.read(journalFilterProvider.notifier).setMood(null);
                          _search();
                        },
                      ),
                      const SizedBox(width: 6),
                      ...Mood.values.map((mood) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            label: Text(mood.label),
                            selected: filter.mood == mood,
                            selectedColor: Color(mood.color).withAlpha(40),
                            onSelected: (_) {
                              ref
                                  .read(journalFilterProvider.notifier)
                                  .setMood(filter.mood == mood ? null : mood);
                              _search();
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // Tag filter
                Consumer(
                  builder: (context, ref, _) {
                    final tagsAsync = ref.watch(allTagsProvider);
                    return tagsAsync.when(
                      data: (tags) => tags.isEmpty
                          ? const SizedBox()
                          : Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: tags.map((tag) {
                                    final isSelected = filter.selectedTags
                                        .any((t) => t.id == tag.id);
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: TagChip(
                                        tag: tag,
                                        selected: isSelected,
                                        onTap: () {
                                          ref
                                              .read(
                                                  journalFilterProvider.notifier)
                                              .toggleTag(tag);
                                          _search();
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                      loading: () => const SizedBox(),
                      error: (_, _) => const SizedBox(),
                    );
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Results
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? const EmptyState(
                        icon: Icons.search_off,
                        title: '没有找到结果',
                        subtitle: '尝试更换关键词或筛选条件',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final entry = _results[index];
                          return EntryCard(
                            entry: entry,
                            onTap: () => context.push('/journal/${entry.id}'),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
