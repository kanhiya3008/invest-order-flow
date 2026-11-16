import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_config.dart';

class ApiClient {
  ApiClient._();

  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (line) => debugPrint(line.toString()),
        ),
      );
    }
    return dio;
  }
}
