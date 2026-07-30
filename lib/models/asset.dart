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
  final double principal;
  final AssetType type;
  final String account;
  final String note;
  final DateTime updatedAt;

  const Asset({
    required this.id,
    required this.name,
    required this.value,
    this.principal = 0,
    required this.type,
    this.account = '',
    required this.note,
    required this.updatedAt,
  });

  double get profit => value - principal;
  double get profitRate => principal > 0 ? profit / principal * 100 : 0;

  Asset copyWith({
    int? id,
    String? name,
    double? value,
    double? principal,
    AssetType? type,
    String? account,
    String? note,
    DateTime? updatedAt,
  }) {
    return Asset(
      id: id ?? this.id,
      name: name ?? this.name,
      value: value ?? this.value,
      principal: principal ?? this.principal,
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
        'principal': principal,
        'type': type.label,
        'account': account,
        'note': note,
        'updatedAt': updatedAt.toIso8601String(),
      };
}

class SnapshotItem {
  final double totalValue;
  final double totalPrincipal;
  final DateTime date;

  const SnapshotItem({
    required this.totalValue,
    required this.totalPrincipal,
    required this.date,
  });

  double get profit => totalValue - totalPrincipal;
  double get profitRate => totalPrincipal > 0 ? profit / totalPrincipal * 100 : 0;
}

class HistoryItem {
  final double value;
  final double principal;
  final DateTime date;

  const HistoryItem({
    required this.value,
    required this.principal,
    required this.date,
  });
}
