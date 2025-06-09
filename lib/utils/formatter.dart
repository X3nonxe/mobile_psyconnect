import 'package:intl/intl.dart';

class TFormatter {
  static String formatDate(DateTime? date) {
    date ??= DateTime.now();
    final onlyDate = DateFormat('dd MMM yyyy').format(date);
    final onlyTime = DateFormat('hh:mm').format(date);
    
    return '$onlyDate at $onlyTime';
  }

  static String formatCurrency(double amount) {
    final formatter = NumberFormat.simpleCurrency();
    return formatter.format(amount);
  }

  static String formatNumber(int number) {
    final formatter = NumberFormat.decimalPattern();
    return formatter.format(number);
  }
}