enum Mood {
  terrible(1, '很糟', 0xFFE53935),
  sad(2, '难过', 0xFFFF9800),
  neutral(3, '一般', 0xFFFFC107),
  good(4, '不错', 0xFF8BC34A),
  amazing(5, '超棒', 0xFF4CAF50);

  const Mood(this.value, this.label, this.color);

  final int value;
  final String label;
  final int color;

  static Mood fromValue(int v) =>
      Mood.values.firstWhere((m) => m.value == v, orElse: () => Mood.neutral);
}
