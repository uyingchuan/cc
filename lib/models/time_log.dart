import 'package:flutter/material.dart';

enum TimeCategory {
  work('工作', Icons.work, 0xFF3B82F6),
  study('学习', Icons.school, 0xFF6366F1),
  exercise('运动', Icons.fitness_center, 0xFF10B981),
  rest('休息', Icons.bed, 0xFF9E9E9E),
  entertainment('娱乐', Icons.videogame_asset, 0xFF8B5CF6),
  dining('用餐', Icons.restaurant, 0xFFFF9800),
  travel('出行', Icons.directions_walk, 0xFF14B8A6),
  social('社交', Icons.people, 0xFFEC4899),
  other('其他', Icons.more_horiz, 0xFF757575);

  const TimeCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final int color;

  static TimeCategory fromValue(int v) =>
      TimeCategory.values.firstWhere((c) => c.index == v,
          orElse: () => TimeCategory.other);
}

class TimeLog {
  final int id;
  final TimeCategory category;
  final DateTime startTime;
  final int durationMin;
  final String note;
  final DateTime createdAt;

  const TimeLog({
    required this.id,
    required this.category,
    required this.startTime,
    required this.durationMin,
    this.note = '',
    required this.createdAt,
  });

  String get durationStr {
    if (durationMin < 60) return '${durationMin}分钟';
    final h = durationMin ~/ 60;
    final r = durationMin % 60;
    return r > 0 ? '${h}小时${r}分钟' : '${h}小时';
  }

  String get timeStr {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }

  TimeLog copyWith({
    int? id,
    TimeCategory? category,
    DateTime? startTime,
    int? durationMin,
    String? note,
    DateTime? createdAt,
  }) {
    return TimeLog(
      id: id ?? this.id,
      category: category ?? this.category,
      startTime: startTime ?? this.startTime,
      durationMin: durationMin ?? this.durationMin,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.label,
        'startTime': startTime.toIso8601String(),
        'durationMin': durationMin,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };
}
