import 'dart:async';

import 'package:dio/dio.dart';

import '../core/api_config.dart';
import '../core/failures.dart';
import '../models/balances.dart';
import '../models/order.dart';

abstract interface class InvestApi {
  Future<Balances> getBalances();

  Future<Order> placeOrder(OrderRequest request);
}

class HttpInvestApi implements InvestApi {
  const HttpInvestApi(this._dio);

  final Dio _dio;

  @override
  Future<Balances> getBalances() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConfig.balancesPath,
      );
      return Balances.fromJson(response.data!);
    } catch (error) {
      throw toFailure(error);
    }
  }

  @override
  Future<Order> placeOrder(OrderRequest request) async {
    final cancelToken = CancelToken();
    try {
      final response = await _dio
          .post<Map<String, dynamic>>(
            ApiConfig.ordersPath,
            data: request.toJson(),
            options: Options(
              headers: {'Idempotency-Key': request.idempotencyKey},
            ),
            cancelToken: cancelToken,
          )
          .timeout(ApiConfig.orderTimeout);
      return Order.fromJson(response.data!);
    } on TimeoutException {
      cancelToken.cancel('Order request timed out');
      throw const TimeoutFailure();
    } catch (error) {
      throw toFailure(error);
    }
  }

  static Failure toFailure(Object error) {
    if (error is Failure) return error;
    if (error is TimeoutException) return const TimeoutFailure();
    if (error is! DioException) return const ServerFailure();

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.cancel:
        return const TimeoutFailure();
      case DioExceptionType.connectionError:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        final response = error.response;
        if (response?.statusCode == 400) {
          final data = response?.data;
          final message = data is Map ? data['message'] : null;
          return message is String && message.trim().isNotEmpty
              ? InvalidAmountFailure(message)
              : const InvalidAmountFailure();
        }
        return const ServerFailure();
    }
  }
}
