import 'package:flutter/material.dart';

enum Mood {
  angry(1, '愤怒', 0xFFE53935),
  sad(2, '难过', 0xFFFF9800),
  sorrow(3, '悲伤', 0xFF5C6BC0),
  down(4, '低落', 0xFF78909C),
  neutral(5, '普通', 0xFF9E9E9E),
  happy(6, '开心', 0xFF8BC34A),
  joyful(7, '欣喜', 0xFF4CAF50),
  delighted(8, '高兴', 0xFFFFB300);

  const Mood(this.value, this.label, this.color);

  final int value;
  final String label;
  final int color;

  IconData get icon {
    switch (this) {
      case Mood.angry:
        return Icons.sentiment_very_dissatisfied;
      case Mood.sad:
        return Icons.sentiment_dissatisfied;
      case Mood.sorrow:
        return Icons.mood_bad;
      case Mood.down:
        return Icons.cloud;
      case Mood.neutral:
        return Icons.sentiment_neutral;
      case Mood.happy:
        return Icons.sentiment_satisfied;
      case Mood.joyful:
        return Icons.sentiment_very_satisfied;
      case Mood.delighted:
        return Icons.emoji_emotions;
    }
  }

  static Mood fromValue(int v) =>
      Mood.values.firstWhere((m) => m.value == v, orElse: () => Mood.neutral);
}
