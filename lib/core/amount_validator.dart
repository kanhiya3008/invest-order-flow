import '../models/currency.dart';
import 'money_formatter.dart';

class AmountValidator {
  const AmountValidator();

  static final RegExp _amountPattern = RegExp(r'^\d+(\.\d{1,2})?$');

  static const String requiredMessage = 'Enter an amount';
  static const String formatMessage =
      'Enter a valid amount with up to 2 decimal places';
  static const String positiveMessage = 'Amount must be greater than zero';

  static int? parseToMinor(String input) {
    final text = input.trim();
    if (!_amountPattern.hasMatch(text)) return null;

    final parts = text.split('.');
    final whole = int.tryParse(parts[0]);
    if (whole == null) return null;

    final fraction = parts.length == 2 ? parts[1].padRight(2, '0') : '00';
    return whole * 100 + int.parse(fraction);
  }

  String? validate(
    String input, {
    required Currency currency,
    required int balanceMinor,
  }) {
    final text = input.trim();
    if (text.isEmpty) return requiredMessage;

    if (text.startsWith('-')) return positiveMessage;

    final amountMinor = parseToMinor(text);
    if (amountMinor == null) return formatMessage;
    if (amountMinor <= 0) return positiveMessage;

    if (amountMinor < currency.minMinor) {
      return 'Minimum investment is '
          '${MoneyFormatter.format(currency.minMinor, currency)}';
    }
    if (amountMinor > currency.maxMinor) {
      return 'Maximum per order is '
          '${MoneyFormatter.format(currency.maxMinor, currency)}';
    }
    if (amountMinor > balanceMinor) {
      return 'Amount exceeds your available balance of '
          '${MoneyFormatter.format(balanceMinor, currency)}';
    }
    return null;
  }
}
