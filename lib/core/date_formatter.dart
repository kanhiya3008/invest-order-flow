import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _orderTime = DateFormat(
    'd MMM yyyy, h:mm a',
    'en_US',
  );

  static String orderTime(DateTime utc) => _orderTime.format(utc.toLocal());
}
