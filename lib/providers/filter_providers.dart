import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/journal_filter.dart';
import '../models/mood.dart';
import '../models/tag.dart';

class JournalFilterNotifier extends Notifier<JournalFilter> {
  @override
  JournalFilter build() => const JournalFilter();

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query.isEmpty ? null : query);
  }

  void setMood(Mood? mood) {
    state = state.copyWith(mood: mood);
  }

  void setDateRange(DateTimeRange? range) {
    state = state.copyWith(dateRange: range);
  }

  void toggleTag(Tag tag) {
    final current = state.selectedTags;
    final contains = current.any((t) => t.id == tag.id);
    state = state.copyWith(
      selectedTags: contains
          ? current.where((t) => t.id != tag.id).toList()
          : [...current, tag],
    );
  }

  void clearAll() {
    state = const JournalFilter();
  }
}

final journalFilterProvider =
    NotifierProvider<JournalFilterNotifier, JournalFilter>(
        JournalFilterNotifier.new);
