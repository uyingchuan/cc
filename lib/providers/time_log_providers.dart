import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/time_log.dart';
import '../repositories/time_log_repository.dart';
import 'database_provider.dart';

final timeLogRepositoryProvider = Provider<TimeLogRepository>((ref) {
  return TimeLogRepository(ref.watch(appDatabaseProvider));
});

class SelectedDate extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void goTo(DateTime d) => state = d;
}

class FocusedDay extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void goTo(DateTime d) => state = d;
}

final selectedDateProvider =
    NotifierProvider<SelectedDate, DateTime>(SelectedDate.new);
final focusedDayProvider =
    NotifierProvider<FocusedDay, DateTime>(FocusedDay.new);

final dateLogsProvider = StreamProvider<List<TimeLog>>((ref) {
  final date = ref.watch(selectedDateProvider);
  return ref.watch(timeLogRepositoryProvider).watchDate(date);
});

final timeLogProvider = FutureProvider.family<TimeLog?, int>((ref, id) {
  return ref.watch(timeLogRepositoryProvider).getById(id);
});
