import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/bill.dart';
import '../../providers/bill_providers.dart';

class BillFormScreen extends ConsumerStatefulWidget {
  final int? billId;

  const BillFormScreen({super.key, this.billId});

  @override
  ConsumerState<BillFormScreen> createState() => _BillFormScreenState();
}

class _BillFormScreenState extends ConsumerState<BillFormScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  BillCategory _category = BillCategory.food;
  DateTime _billDate = DateTime.now();
  bool _isSaving = false;
  bool _initialized = false;

  bool get isEditing => widget.billId != null;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadBill() async {
    if (widget.billId == null) return;
    final bill = await ref.read(billProvider(widget.billId!).future);
    if (bill == null) return;

    _amountController.text = bill.amount.toString();
    _noteController.text = bill.note;
    _category = bill.category;
    _billDate = bill.billDate;
    _initialized = true;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadBill();
    } else {
      _initialized = true;
    }
  }

  Future<void> _save() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入金额')),
      );
      return;
    }
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的金额')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(billRepositoryProvider);
      if (isEditing) {
        await repo.update(
          id: widget.billId!,
          amount: amount,
          category: _category,
          note: _noteController.text.trim(),
          billDate: _billDate,
        );
      } else {
        await repo.create(
          amount: amount,
          category: _category,
          note: _noteController.text.trim(),
          billDate: _billDate,
        );
      }
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '编辑账单' : '记一笔'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('保存'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Category selector
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: BillCategory.values.map((cat) {
                final isSelected = _category == cat;
                final color = Color(cat.color);
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(cat.icon, size: 16,
                          color: isSelected ? color : null),
                      const SizedBox(width: 4),
                      Text(cat.label),
                    ],
                  ),
                  selected: isSelected,
                  selectedColor: color.withAlpha(40),
                  labelStyle: TextStyle(
                    color: isSelected ? color : null,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  onSelected: (_) => setState(() => _category = cat),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Date picker
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _billDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _billDate = picked);
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_billDate.year}年${_billDate.month}月${_billDate.day}日',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Amount
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: !isEditing,
              decoration: InputDecoration(
                labelText: '金额',
                prefixText: '¥ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Note
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: '备注（可选）',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
