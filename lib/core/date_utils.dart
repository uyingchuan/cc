import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dateDay = DateTime(date.year, date.month, date.day);
  final diff = today.difference(dateDay).inDays;

  if (diff == 0) return '今天';
  if (diff == 1) return '昨天';
  if (diff < 7) return '$diff天前';

  return DateFormat('M月d日').format(date);
}

String formatDateTime(DateTime dt) {
  return DateFormat('yyyy年M月d日 HH:mm').format(dt);
}

String formatTime(DateTime dt) {
  return DateFormat('HH:mm').format(dt);
}

String formatWeekday(DateTime dt) {
  return DateFormat('EEEE', 'zh_CN').format(dt);
}
