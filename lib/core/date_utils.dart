import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inMinutes < 1) return '刚刚';

  final today = DateTime(now.year, now.month, now.day);
  final dateDay = DateTime(date.year, date.month, date.day);

  if (dateDay == today) return DateFormat('HH:mm').format(date);
  if (date.year == now.year) return DateFormat('M月d日').format(date);

  return DateFormat('yyyy年M月d日').format(date);
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
