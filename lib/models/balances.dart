import 'package:equatable/equatable.dart';

import '../core/money_formatter.dart';
import 'currency.dart';

class Balances extends Equatable {
  const Balances(this.amountsMinor);

  final Map<Currency, int> amountsMinor;

  factory Balances.fromJson(Map<String, dynamic> json) {
    final amounts = <Currency, int>{};
    for (final currency in Currency.values) {
      final value = json[currency.code];
      if (value is! num) {
        throw FormatException('Missing balance for ${currency.code}');
      }
      amounts[currency] = MoneyFormatter.toMinor(value);
    }
    return Balances(Map.unmodifiable(amounts));
  }

  int of(Currency currency) => amountsMinor[currency] ?? 0;

  Balances deduct(Currency currency, int amountMinor) {
    final updated = Map<Currency, int>.of(amountsMinor);
    updated[currency] = of(currency) - amountMinor;
    return Balances(Map.unmodifiable(updated));
  }

  @override
  List<Object?> get props => [amountsMinor];
}
