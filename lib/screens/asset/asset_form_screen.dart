import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/asset.dart';
import '../../providers/asset_providers.dart';

class AssetFormScreen extends ConsumerStatefulWidget {
  final int? assetId;
  final Asset? asset;

  const AssetFormScreen({super.key, this.assetId, this.asset});

  @override
  ConsumerState<AssetFormScreen> createState() => _AssetFormScreenState();
}

class _AssetFormScreenState extends ConsumerState<AssetFormScreen> {
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  final _principalController = TextEditingController();
  final _accountController = TextEditingController();
  final _noteController = TextEditingController();
  AssetType _type = AssetType.cash;
  bool _isSaving = false;
  bool _initialized = false;

  bool get isEditing => widget.assetId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    _principalController.dispose();
    _accountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _fillFromAsset(Asset a) {
    _nameController.text = a.name;
    _valueController.text = a.value.toString();
    _principalController.text = a.principal > 0 ? a.principal.toString() : '';
    _accountController.text = a.account;
    _noteController.text = a.note;
    _type = a.type;
    _initialized = true;
  }

  Future<void> _loadAsset() async {
    if (widget.asset != null) {
      _fillFromAsset(widget.asset!);
      return;
    }
    if (widget.assetId == null) return;
    ref.invalidate(assetProvider(widget.assetId!));
    final asset = await ref.read(assetProvider(widget.assetId!).future);
    if (asset == null) return;
    _fillFromAsset(asset);
  }

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadAsset();
    } else {
      _initialized = true;
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final valueText = _valueController.text.trim();
    if (name.isEmpty || valueText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入名称和金额')),
      );
      return;
    }
    final value = double.tryParse(valueText);
    if (value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的金额')),
      );
      return;
    }

    final principalText = _principalController.text.trim();
    final principal = double.tryParse(principalText) ?? 0;

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(assetRepositoryProvider);
      if (isEditing) {
        await repo.update(
          id: widget.assetId!,
          name: name,
          value: value,
          principal: principal,
          type: _type,
          account: _accountController.text.trim(),
          note: _noteController.text.trim(),
        );
      } else {
        await repo.create(
          name: name,
          value: value,
          principal: principal,
          type: _type,
          account: _accountController.text.trim(),
          note: _noteController.text.trim(),
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
        title: Text(isEditing ? '编辑资产' : '添加资产'),
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
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '资产名称',
                hintText: '如：储蓄卡、支付宝、基金',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              autofocus: !isEditing,
            ),
            const SizedBox(height: 16),
            // Type selector
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AssetType.values.map((type) {
                final isSelected = _type == type;
                final color = Color(type.color);
                return ChoiceChip(
                  label: Text(type.label),
                  selected: isSelected,
                  selectedColor: color.withAlpha(40),
                  labelStyle: TextStyle(
                    color: isSelected ? color : null,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  onSelected: (_) => setState(() => _type = type),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _accountController,
              decoration: InputDecoration(
                labelText: '账户（可选）',
                hintText: '如：支付宝、微信、招商银行',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _valueController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: '金额',
                prefixText: '¥ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _principalController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: '本金（可选）',
                hintText: '投入成本，用于计算收益',
                prefixText: '¥ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
