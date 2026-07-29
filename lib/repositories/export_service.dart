import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/export_payload.dart';
import 'journal_repository.dart';
import 'tag_repository.dart';

class ExportService {
  final JournalRepository _journalRepo;
  final TagRepository _tagRepo;

  ExportService(this._journalRepo, this._tagRepo);

  Future<ExportPayload> buildPayload({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final now = DateTime.now();
    final start = startDate ?? now.subtract(const Duration(days: 7));
    final end = endDate ?? now;

    final entries = await _journalRepo.filterByDateRange(start, end);
    final tags = await _tagRepo.getAll();

    final moodCounts = <String, int>{};
    final tagCounts = <String, int>{};
    final dayCounts = <String, int>{};
    int totalChars = 0;

    final exportEntries = <ExportEntry>[];
    for (final entry in entries) {
      final moodLabel = entry.mood.label;
      moodCounts[moodLabel] = (moodCounts[moodLabel] ?? 0) + 1;

      for (final tag in entry.tags) {
        tagCounts[tag.name] = (tagCounts[tag.name] ?? 0) + 1;
      }

      final dayName = DateFormat('EEEE', 'zh_CN').format(entry.entryDate);
      dayCounts[dayName] = (dayCounts[dayName] ?? 0) + 1;

      totalChars += entry.content.length;

      exportEntries.add(ExportEntry(
        id: entry.id,
        entryDate: _fmt(entry.entryDate),
        title: entry.title,
        content: entry.content,
        mood: entry.mood.label,
        tags: entry.tags.map((t) => t.name).toList(),
        createdAt: _fmt(entry.createdAt),
      ));
    }

    final sortedTags = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topTags = sortedTags.take(10).map((e) => e.key).toList();

    String? mostActiveDay;
    if (dayCounts.isNotEmpty) {
      mostActiveDay =
          dayCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    }

    return ExportPayload(
      version: 1,
      appName: '随手记',
      module: 'journal',
      exportedAt: _fmt(DateTime.now()),
      summary: ExportSummary(
        totalEntries: entries.length,
        dateRange: ExportDateRange(
          from: DateFormat('yyyy-MM-dd').format(start),
          to: DateFormat('yyyy-MM-dd').format(end),
        ),
        moodDistribution: moodCounts,
        topTags: topTags,
        avgCharsPerEntry:
            entries.isEmpty ? 0 : totalChars ~/ entries.length,
        mostActiveDay: mostActiveDay,
      ),
      entries: exportEntries,
      tags: tags
          .map((t) => ExportTag(name: t.name, color: t.color))
          .toList(),
    );
  }

  Future<void> exportToFile({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final payload = await buildPayload(startDate: startDate, endDate: endDate);
    final json = const JsonEncoder.withIndent('  ').convert(payload.toJson());
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/cc_export_$timestamp.json');
    await file.writeAsString(json);
    final xFile = XFile(file.path);
    await SharePlus.instance.share(ShareParams(files: [xFile]));
  }

  String _fmt(DateTime dt) {
    return DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(dt);
  }
}
