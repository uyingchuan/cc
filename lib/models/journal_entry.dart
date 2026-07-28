import 'mood.dart';
import 'tag.dart';

class JournalEntry {
  final int id;
  final String title;
  final String content;
  final Mood mood;
  final DateTime entryDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Tag> tags;

  const JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.mood,
    required this.entryDate,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
  });

  JournalEntry copyWith({
    int? id,
    String? title,
    String? content,
    Mood? mood,
    DateTime? entryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Tag>? tags,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      entryDate: entryDate ?? this.entryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'mood': mood.label,
        'moodValue': mood.value,
        'entryDate': entryDate.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'tags': tags.map((t) => t.toJson()).toList(),
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: (json['id'] as num).toInt(),
        title: json['title'] as String,
        content: json['content'] as String,
        mood: Mood.fromValue((json['moodValue'] as num).toInt()),
        entryDate: DateTime.parse(json['entryDate'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        tags: (json['tags'] as List<dynamic>?)
                ?.map((t) => Tag.fromJson(t as Map<String, dynamic>))
                .toList() ??
            [],
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is JournalEntry && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'JournalEntry(id: $id, title: $title)';
}
