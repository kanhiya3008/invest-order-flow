import 'package:intl/intl.dart';

import '../models/currency.dart';

class MoneyFormatter {
  MoneyFormatter._();

  static int toMinor(num value) => (value * 100).round();

  static double fromMinor(int minor) => minor / 100;

  static String format(int minor, Currency currency) {
    final formatter = NumberFormat.currency(
      locale: currency.locale,
      symbol: currency.symbol,
      decimalDigits: 2,
    );
    return formatter.format(fromMinor(minor));
  }
}
