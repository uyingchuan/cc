import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/time_log.dart';
import '../../providers/time_log_providers.dart';

class TimeLogFormScreen extends ConsumerStatefulWidget {
  final int? logId;

  const TimeLogFormScreen({super.key, this.logId});

  @override
  ConsumerState<TimeLogFormScreen> createState() => _TimeLogFormScreenState();
}

class _TimeLogFormScreenState extends ConsumerState<TimeLogFormScreen> {
  final _noteController = TextEditingController();
  TimeCategory _category = TimeCategory.work;
  DateTime _startTime = DateTime.now();
  int _durationMin = 30;
  bool _isSaving = false;
  bool _initialized = false;

  bool get isEditing => widget.logId != null;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadLog() async {
    if (widget.logId == null) return;
    final log = await ref.read(timeLogProvider(widget.logId!).future);
    if (log == null) return;

    _category = log.category;
    _startTime = log.startTime;
    _durationMin = log.durationMin;
    _noteController.text = log.note;
    _initialized = true;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadLog();
    } else {
      _initialized = true;
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTime),
    );
    if (picked == null) return;
    final now = DateTime.now();
    setState(() {
      _startTime =
          DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
    });
  }

  Future<void> _pickDuration() async {
    final result = await showDurationPicker(
      context: context,
      initialTime: Duration(minutes: _durationMin),
      baseUnit: BaseUnit.minute,
    );
    if (result != null) {
      setState(() => _durationMin = result.inMinutes);
    }
  }

  String _durationLabel() {
    if (_durationMin < 60) return '${_durationMin}分钟';
    final h = _durationMin ~/ 60;
    final m = _durationMin % 60;
    return m > 0 ? '${h}小时${m}分钟' : '${h}小时';
  }

  Future<void> _save() async {
    if (_durationMin <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择时长')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(timeLogRepositoryProvider);
      if (isEditing) {
        await repo.update(
          id: widget.logId!,
          category: _category,
          startTime: _startTime,
          durationMin: _durationMin,
          note: _noteController.text.trim(),
        );
      } else {
        await repo.create(
          category: _category,
          startTime: _startTime,
          durationMin: _durationMin,
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
        title: Text(isEditing ? '编辑时间日志' : '添加时间日志'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
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
            // Category
            DropdownButtonFormField<TimeCategory>(
              // ignore: deprecated_member_use
              value: _category,
              decoration: InputDecoration(
                labelText: '分类',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: TimeCategory.values.map((cat) {
                final color = Color(cat.color);
                return DropdownMenuItem(
                  value: cat,
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Icon(cat.icon, size: 18, color: color),
                      const SizedBox(width: 8),
                      Text(cat.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _category = v);
              },
            ),
            const SizedBox(height: 16),
            // Start time
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text('开始时间',
                        style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Duration
            GestureDetector(
              onTap: _pickDuration,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text('时长',
                        style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      _durationLabel(),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 2,
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
