import 'package:equatable/equatable.dart';

import '../core/money_formatter.dart';
import 'currency.dart';

class OrderRequest extends Equatable {
  const OrderRequest({
    required this.fundId,
    required this.currency,
    required this.amountMinor,
    required this.idempotencyKey,
  });

  final String fundId;
  final Currency currency;
  final int amountMinor;

  final String idempotencyKey;

  Map<String, dynamic> toJson() => {
    'fundId': fundId,
    'currency': currency.code,
    'amount': MoneyFormatter.fromMinor(amountMinor),
  };

  @override
  List<Object?> get props => [fundId, currency, amountMinor, idempotencyKey];
}

class Order extends Equatable {
  const Order({
    required this.orderId,
    required this.status,
    required this.fundId,
    required this.currency,
    required this.amountMinor,
    required this.placedAt,
  });

  final String orderId;
  final String status;
  final String fundId;
  final Currency currency;
  final int amountMinor;

  final DateTime placedAt;

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    orderId: json['orderId'] as String,
    status: json['status'] as String,
    fundId: json['fundId'] as String,
    currency: Currency.fromCode(json['currency'] as String),
    amountMinor: MoneyFormatter.toMinor(json['amount'] as num),
    placedAt: DateTime.parse(json['placedAt'] as String).toUtc(),
  );

  @override
  List<Object?> get props => [
    orderId,
    status,
    fundId,
    currency,
    amountMinor,
    placedAt,
  ];
}
