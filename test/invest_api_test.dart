import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invest_order_flow/core/failures.dart';
import 'package:invest_order_flow/models/balances.dart';
import 'package:invest_order_flow/models/currency.dart';
import 'package:invest_order_flow/models/order.dart';
import 'package:invest_order_flow/services/invest_api.dart';

void main() {
  DioException badResponse(int statusCode, Map<String, dynamic> body) {
    final options = RequestOptions(path: '/orders');
    return DioException(
      requestOptions: options,
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: options,
        statusCode: statusCode,
        data: body,
      ),
    );
  }

  group('parsing', () {
    test('balances are converted to paise / cents', () {
      final balances = Balances.fromJson({'INR': 250000.00, 'USD': 3000});

      expect(balances.of(Currency.inr), 25000000);
      expect(balances.of(Currency.usd), 300000);
    });

    test('a missing or wrong balance throws', () {
      expect(
        () => Balances.fromJson({'INR': 250000.00}),
        throwsFormatException,
      );
      expect(
        () => Balances.fromJson({'INR': '250000', 'USD': 3000.00}),
        throwsFormatException,
      );
    });

    test('order response where amount is an int, like the real API', () {
      final order = Order.fromJson({
        'orderId': 'ORD-10231',
        'status': 'PLACED',
        'fundId': 'global-index-fund',
        'currency': 'INR',
        'amount': 5000,
        'placedAt': '2026-11-13T10:44:11.458Z',
      });

      expect(order.amountMinor, 500000);
      expect(order.currency, Currency.inr);
      expect(order.placedAt.isUtc, isTrue);
    });
  });

  group('errors become Failures', () {
    test('500 is a ServerFailure and hides the server message', () {
      final failure = HttpInvestApi.toFailure(
        badResponse(500, {'code': 'SERVER_ERROR', 'message': 'db exploded'}),
      );
      expect(failure, const ServerFailure());
    });

    test('400 is an InvalidAmountFailure with the server message', () {
      final failure = HttpInvestApi.toFailure(
        badResponse(400, {'code': 'INVALID_AMOUNT', 'message': 'Too small'}),
      );
      expect(failure, const InvalidAmountFailure('Too small'));
    });

    test('our 10 second limit is a TimeoutFailure', () {
      expect(
        HttpInvestApi.toFailure(TimeoutException('slow')),
        isA<TimeoutFailure>(),
      );
    });

    test('no connection is a NetworkFailure', () {
      final failure = HttpInvestApi.toFailure(
        DioException(
          requestOptions: RequestOptions(path: '/orders'),
          type: DioExceptionType.connectionError,
        ),
      );
      expect(failure, isA<NetworkFailure>());
    });
  });
}
