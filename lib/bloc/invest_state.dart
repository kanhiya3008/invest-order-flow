import 'package:equatable/equatable.dart';

import '../core/amount_validator.dart';
import '../core/failures.dart';
import '../models/balances.dart';
import '../models/currency.dart';
import '../models/order.dart';

enum BalanceStatus { loading, loaded, failure }

enum OrderStatus { idle, submitting, success, failure }

class InvestState extends Equatable {
  const InvestState({
    this.balanceStatus = BalanceStatus.loading,
    this.balances,
    this.balanceError,
    this.currency = Currency.inr,
    this.amountText = '',
    this.amountTouched = false,
    this.orderStatus = OrderStatus.idle,
    this.idempotencyKey = '',
    this.order,
    this.orderFailure,
  });

  final BalanceStatus balanceStatus;
  final Balances? balances;
  final String? balanceError;
  final Currency currency;
  final String amountText;

  final bool amountTouched;

  final OrderStatus orderStatus;

  final String idempotencyKey;

  final Order? order;

  final Failure? orderFailure;

  static const _validator = AmountValidator();

  int get balanceMinor => balances?.of(currency) ?? 0;

  String? get amountError {
    if (balanceStatus != BalanceStatus.loaded) return null;
    return _validator.validate(
      amountText,
      currency: currency,
      balanceMinor: balanceMinor,
    );
  }

  String? get visibleAmountError => amountTouched ? amountError : null;

  int? get amountMinor => AmountValidator.parseToMinor(amountText);

  bool get canContinue =>
      balanceStatus == BalanceStatus.loaded && amountError == null;

  InvestState copyWith({
    BalanceStatus? balanceStatus,
    Balances? balances,
    String? balanceError,
    Currency? currency,
    String? amountText,
    bool? amountTouched,
    OrderStatus? orderStatus,
    String? idempotencyKey,
    Order? order,
    Failure? orderFailure,
  }) {
    return InvestState(
      balanceStatus: balanceStatus ?? this.balanceStatus,
      balances: balances ?? this.balances,
      balanceError: balanceError ?? this.balanceError,
      currency: currency ?? this.currency,
      amountText: amountText ?? this.amountText,
      amountTouched: amountTouched ?? this.amountTouched,
      orderStatus: orderStatus ?? this.orderStatus,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      order: order ?? this.order,
      orderFailure: orderFailure ?? this.orderFailure,
    );
  }

  @override
  List<Object?> get props => [
    balanceStatus,
    balances,
    balanceError,
    currency,
    amountText,
    amountTouched,
    orderStatus,
    idempotencyKey,
    order,
    orderFailure,
  ];
}
