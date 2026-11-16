class ApiConfig {
  ApiConfig._();

  static const String baseUrl =
      'https://unbordered-flutter-assignment.tech-c06.workers.dev';

  static const String balancesPath = '/account/balances';
  static const String ordersPath = '/orders';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  static const Duration orderTimeout = Duration(seconds: 10);
}
