import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/time_log.dart';
import '../../providers/time_log_providers.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';

class TimeLogHomeScreen extends ConsumerStatefulWidget {
  const TimeLogHomeScreen({super.key});

  @override
  ConsumerState<TimeLogHomeScreen> createState() => _TimeLogHomeScreenState();
}

class _TimeLogHomeScreenState extends ConsumerState<TimeLogHomeScreen> {
  bool _showCalendar = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = ref.watch(selectedDateProvider);
    final logsAsync = ref.watch(dateLogsProvider);
    final focusedDay = ref.watch(focusedDayProvider);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(date.year, date.month, date.day);
    final isToday = selectedDay == today;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => setState(() => _showCalendar = !_showCalendar),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isToday
                    ? '今天'
                    : DateFormat('M月d日').format(date),
              ),
              const SizedBox(width: 4),
              Icon(
                _showCalendar ? Icons.expand_less : Icons.expand_more,
                size: 20,
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Collapsible calendar
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: TableCalendar(
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              focusedDay: focusedDay,
              selectedDayPredicate: (d) =>
                  d.year == date.year &&
                  d.month == date.month &&
                  d.day == date.day,
              onDaySelected: (selected, _) {
                ref.read(selectedDateProvider.notifier).goTo(selected);
                setState(() => _showCalendar = false);
              },
              onPageChanged: (focused) {
                ref.read(focusedDayProvider.notifier).goTo(focused);
              },
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {CalendarFormat.month: '月'},
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(50),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            crossFadeState: _showCalendar
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),

          // Content
          Expanded(
            child: logsAsync.when(
              data: (logs) {
                final catMap = <TimeCategory, int>{};
                for (final l in logs) {
                  catMap[l.category] =
                      (catMap[l.category] ?? 0) + l.durationMin;
                }
                final catList = catMap.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                return ListView(
                  padding: const EdgeInsets.only(bottom: 80),
                  children: [
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6366F1),
                            const Color(0xFF6366F1).withAlpha(180),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${isToday ? "今日" : DateFormat('M月d日').format(date)}时间分布',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 12),
                          if (catList.isEmpty)
                            const Text('暂无记录',
                                style: TextStyle(color: Colors.white54)),
                          for (final e in catList)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  Icon(e.key.icon,
                                      size: 16, color: Colors.white70),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(e.key.label,
                                        style: const TextStyle(
                                            color: Colors.white)),
                                  ),
                                  Text(
                                    e.value < 60
                                        ? '${e.value}分钟'
                                        : '${e.value ~/ 60}小时${e.value % 60}分钟',
                                    style: const TextStyle(
                                        color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    if (logs.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: EmptyState(
                          icon: Icons.timeline,
                          title: '没有记录',
                          subtitle: '点击右下角添加时间日志',
                        ),
                      )
                    else
                      ...logs.map((log) {
                        final color = Color(log.category.color);
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 3),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color.withAlpha(25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(log.category.icon,
                                  size: 22, color: color),
                            ),
                            title: Text(
                              log.note.isNotEmpty
                                  ? log.note
                                  : log.category.label,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${log.category.label} · ${log.timeStr} · ${log.durationStr}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            onTap: () =>
                                context.push('/timelog/${log.id}/edit'),
                            onLongPress: () async {
                              final confirmed = await showConfirmDialog(
                                context,
                                title: '删除记录',
                                message: '确定要删除这条时间记录吗？',
                                confirmLabel: '删除',
                                destructive: true,
                              );
                              if (confirmed) {
                                ref
                                    .read(timeLogRepositoryProvider)
                                    .delete(log.id);
                              }
                            },
                          ),
                        );
                      }),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('加载失败: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/timelog/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
