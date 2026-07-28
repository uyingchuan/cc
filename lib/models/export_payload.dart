class ExportPayload {
  final int version;
  final String appName;
  final String module;
  final String exportedAt;
  final ExportSummary summary;
  final List<ExportEntry> entries;
  final List<ExportTag> tags;

  const ExportPayload({
    required this.version,
    required this.appName,
    required this.module,
    required this.exportedAt,
    required this.summary,
    required this.entries,
    required this.tags,
  });

  Map<String, dynamic> toJson() => {
        'version': version,
        'app_name': appName,
        'module': module,
        'exported_at': exportedAt,
        'summary': summary.toJson(),
        'entries': entries.map((e) => e.toJson()).toList(),
        'tags': tags.map((t) => t.toJson()).toList(),
      };
}

class ExportSummary {
  final int totalEntries;
  final ExportDateRange dateRange;
  final Map<String, int> moodDistribution;
  final List<String> topTags;
  final int avgCharsPerEntry;
  final String? mostActiveDay;

  const ExportSummary({
    required this.totalEntries,
    required this.dateRange,
    required this.moodDistribution,
    required this.topTags,
    required this.avgCharsPerEntry,
    this.mostActiveDay,
  });

  Map<String, dynamic> toJson() => {
        'total_entries': totalEntries,
        'date_range': dateRange.toJson(),
        'mood_distribution': moodDistribution,
        'top_tags': topTags,
        'avg_chars_per_entry': avgCharsPerEntry,
        if (mostActiveDay != null) 'most_active_day': mostActiveDay,
      };
}

class ExportDateRange {
  final String from;
  final String to;

  const ExportDateRange({required this.from, required this.to});

  Map<String, dynamic> toJson() => {'from': from, 'to': to};
}

class ExportEntry {
  final int id;
  final String entryDate;
  final String title;
  final String content;
  final String mood;
  final List<String> tags;
  final String createdAt;

  const ExportEntry({
    required this.id,
    required this.entryDate,
    required this.title,
    required this.content,
    required this.mood,
    required this.tags,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'entry_date': entryDate,
        'title': title,
        'content': content,
        'mood': mood,
        'tags': tags,
        'created_at': createdAt,
      };
}

class ExportTag {
  final String name;
  final int color;

  const ExportTag({required this.name, required this.color});

  Map<String, dynamic> toJson() => {'name': name, 'color': color};
}
