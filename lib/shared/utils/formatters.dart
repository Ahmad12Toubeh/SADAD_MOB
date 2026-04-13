import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String currency(num amount, [String symbol = 'ر.س']) {
    return '${NumberFormat.decimalPattern().format(amount)} $symbol';
  }

  static String date(DateTime date, [String locale = 'ar_SA']) {
    return DateFormat('yyyy/MM/dd', locale).format(date);
  }

  static String dateShort(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'اليوم';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    if (diff.inDays < 30) return 'منذ ${(diff.inDays / 7).floor()} أسابيع';
    if (diff.inDays < 365) return 'منذ ${(diff.inDays / 30).floor()} أشهر';
    return 'منذ ${(diff.inDays / 365).floor()} سنوات';
  }
}
