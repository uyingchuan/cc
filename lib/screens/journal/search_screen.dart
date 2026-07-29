import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/journal_entry.dart';
import '../../providers/journal_providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/entry_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  DateTime? _selectedDate;
  final Map<String, GlobalKey> _dateKeys = {};

  String _groupKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _groupLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);

    if (dateDay == today) return '今天';
    if (dateDay == today.subtract(const Duration(days: 1))) return '昨天';
    if (date.year == now.year) return DateFormat('M月d日').format(date);
    return DateFormat('yyyy年M月d日').format(date);
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      final key = _groupKey(picked);
      final targetKey = _dateKeys[key];
      if (targetKey?.currentContext != null) {
        Scrollable.ensureVisible(
          targetKey!.currentContext!,
          duration: const Duration(milliseconds: 300),
          alignment: 0.1,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(allEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedDate != null
            ? DateFormat('yyyy年M月d日').format(_selectedDate!)
            : '浏览记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: '选择日期',
            onPressed: _pickDate,
          ),
        ],
      ),
      body: entriesAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return const EmptyState(
              icon: Icons.auto_stories,
              title: '还没有记录',
              subtitle: '在随手记页面添加你的第一条记录',
            );
          }

          final groups = <String, List<JournalEntry>>{};
          for (final entry in entries) {
            final key = _groupKey(entry.entryDate);
            groups.putIfAbsent(key, () => []).add(entry);
          }

          final items = <Widget>[];
          for (final key in groups.keys) {
            final groupEntries = groups[key]!;
            final date = groupEntries.first.entryDate;
            _dateKeys[key] = GlobalKey();

            items.add(Padding(
              key: _dateKeys[key],
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                _groupLabel(date),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ));

            for (final entry in groupEntries) {
              items.add(EntryCard(
                entry: entry,
                onTap: () => context.push('/journal/${entry.id}'),
              ));
            }
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: items,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('加载失败: $err')),
      ),
    );
  }
}
