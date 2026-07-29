enum AssetType {
  cash('现金', 0xFF10B981),
  fixedIncome('固收', 0xFF3B82F6),
  equity('权益', 0xFF8B5CF6),
  commodity('商品', 0xFFF59E0B),
  other('其他', 0xFF9E9E9E);

  const AssetType(this.label, this.color);

  final String label;
  final int color;

  static AssetType fromValue(int v) =>
      AssetType.values.firstWhere((t) => t.index == v, orElse: () => AssetType.other);
}

class Asset {
  final int id;
  final String name;
  final double value;
  final AssetType type;
  final String account;
  final String note;
  final DateTime updatedAt;

  const Asset({
    required this.id,
    required this.name,
    required this.value,
    required this.type,
    this.account = '',
    required this.note,
    required this.updatedAt,
  });

  Asset copyWith({
    int? id,
    String? name,
    double? value,
    AssetType? type,
    String? account,
    String? note,
    DateTime? updatedAt,
  }) {
    return Asset(
      id: id ?? this.id,
      name: name ?? this.name,
      value: value ?? this.value,
      type: type ?? this.type,
      account: account ?? this.account,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'value': value,
        'type': type.label,
        'account': account,
        'note': note,
        'updatedAt': updatedAt.toIso8601String(),
      };
}
