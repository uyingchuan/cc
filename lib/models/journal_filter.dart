import 'package:flutter/material.dart';

import 'mood.dart';
import 'tag.dart';

class JournalFilter {
  final String? searchQuery;
  final Mood? mood;
  final List<Tag> selectedTags;
  final DateTimeRange? dateRange;

  const JournalFilter({
    this.searchQuery,
    this.mood,
    this.selectedTags = const [],
    this.dateRange,
  });

  JournalFilter copyWith({
    String? searchQuery,
    Mood? mood,
    List<Tag>? selectedTags,
    DateTimeRange? dateRange,
    bool clearSearchQuery = false,
    bool clearMood = false,
    bool clearDateRange = false,
  }) {
    return JournalFilter(
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      mood: clearMood ? null : (mood ?? this.mood),
      selectedTags: selectedTags ?? this.selectedTags,
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
    );
  }
}
