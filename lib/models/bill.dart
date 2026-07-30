import 'package:flutter/material.dart';

enum BillCategory {
  food('餐饮', Icons.restaurant, 0xFFFF9800),
  transport('交通', Icons.directions_car, 0xFF3B82F6),
  shopping('购物', Icons.shopping_bag, 0xFFEC4899),
  entertainment('娱乐', Icons.movie, 0xFF8B5CF6),
  housing('住房', Icons.home, 0xFF795548),
  daily('日用', Icons.cleaning_services, 0xFF14B8A6),
  medical('医疗', Icons.local_hospital, 0xFFEF4444),
  other('其他', Icons.more_horiz, 0xFF9E9E9E);

  const BillCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final int color;

  static BillCategory fromValue(int v) =>
      BillCategory.values.firstWhere((c) => c.index == v,
          orElse: () => BillCategory.other);
}

class Bill {
  final int id;
  final double amount;
  final BillCategory category;
  final String note;
  final DateTime billDate;
  final DateTime createdAt;

  const Bill({
    required this.id,
    required this.amount,
    required this.category,
    this.note = '',
    required this.billDate,
    required this.createdAt,
  });

  Bill copyWith({
    int? id,
    double? amount,
    BillCategory? category,
    String? note,
    DateTime? billDate,
    DateTime? createdAt,
  }) {
    return Bill(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      note: note ?? this.note,
      billDate: billDate ?? this.billDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'category': category.label,
        'note': note,
        'billDate': billDate.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };
}
