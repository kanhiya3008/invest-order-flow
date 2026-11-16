import 'package:equatable/equatable.dart';

import '../models/currency.dart';

sealed class InvestEvent extends Equatable {
  const InvestEvent();

  @override
  List<Object?> get props => [];
}

final class BalancesRequested extends InvestEvent {
  const BalancesRequested();
}

final class CurrencyChanged extends InvestEvent {
  const CurrencyChanged(this.currency);

  final Currency currency;

  @override
  List<Object?> get props => [currency];
}

final class AmountChanged extends InvestEvent {
  const AmountChanged(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

final class OrderStarted extends InvestEvent {
  const OrderStarted();
}

final class OrderSubmitted extends InvestEvent {
  const OrderSubmitted();
}

final class OrderClosed extends InvestEvent {
  const OrderClosed();
}
