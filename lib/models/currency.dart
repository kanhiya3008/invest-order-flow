enum Currency {
  inr(
    code: 'INR',
    symbol: '₹',
    locale: 'en_IN',
    minMinor: 1000 * 100,
    maxMinor: 500000 * 100,
  ),
  usd(
    code: 'USD',
    symbol: '\$',
    locale: 'en_US',
    minMinor: 10 * 100,
    maxMinor: 10000 * 100,
  );

  const Currency({
    required this.code,
    required this.symbol,
    required this.locale,
    required this.minMinor,
    required this.maxMinor,
  });

  final String code;

  final String symbol;

  final String locale;

  final int minMinor;

  final int maxMinor;

  static Currency fromCode(String code) {
    for (final currency in Currency.values) {
      if (currency.code == code.toUpperCase()) return currency;
    }
    throw ArgumentError('Unsupported currency code: $code');
  }
}
