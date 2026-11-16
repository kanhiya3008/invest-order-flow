import 'package:flutter_test/flutter_test.dart';
import 'package:invest_order_flow/core/amount_validator.dart';
import 'package:invest_order_flow/models/currency.dart';

void main() {
  const validator = AmountValidator();

  const inrBalance = 25000000;
  const usdBalance = 300000;

  String? validateInr(String input) => validator.validate(
    input,
    currency: Currency.inr,
    balanceMinor: inrBalance,
  );

  String? validateUsd(String input) => validator.validate(
    input,
    currency: Currency.usd,
    balanceMinor: usdBalance,
  );

  group('parseToMinor', () {
    test('converts text to minor units without double rounding', () {
      expect(AmountValidator.parseToMinor('1000'), 100000);
      expect(AmountValidator.parseToMinor('1000.5'), 100050);
      expect(AmountValidator.parseToMinor('1000.05'), 100005);
      expect(AmountValidator.parseToMinor('19.99'), 1999);
    });

    test('returns null for invalid text', () {
      expect(AmountValidator.parseToMinor('abc'), isNull);
      expect(AmountValidator.parseToMinor('1,000'), isNull);
      expect(AmountValidator.parseToMinor('10.123'), isNull);
    });
  });

  group('validate', () {
    test('empty input is required', () {
      expect(validateInr(''), AmountValidator.requiredMessage);
      expect(validateInr('   '), AmountValidator.requiredMessage);
    });

    test('non-number shows the format error', () {
      expect(validateInr('abc'), AmountValidator.formatMessage);
    });

    test('negative and zero must be greater than zero', () {
      expect(validateInr('-500'), AmountValidator.positiveMessage);
      expect(validateInr('0'), AmountValidator.positiveMessage);
      expect(validateInr('0.00'), AmountValidator.positiveMessage);
    });

    test('more than 2 decimal places shows the format error', () {
      expect(validateInr('1000.123'), AmountValidator.formatMessage);
    });

    test('below minimum', () {
      expect(validateInr('999.99'), 'Minimum investment is ₹1,000.00');
      expect(validateUsd('9'), 'Minimum investment is \$10.00');
    });

    test('above maximum', () {
      expect(validateInr('500000.01'), 'Maximum per order is ₹5,00,000.00');
      expect(
        validator.validate(
          '10001',
          currency: Currency.usd,
          balanceMinor: 100000000,
        ),
        'Maximum per order is \$10,000.00',
      );
    });

    test('above available balance', () {
      expect(
        validateInr('250000.01'),
        'Amount exceeds your available balance of ₹2,50,000.00',
      );
      expect(
        validateUsd('5000'),
        'Amount exceeds your available balance of \$3,000.00',
      );
    });

    test('valid INR amounts', () {
      expect(validateInr('1000'), isNull);
      expect(validateInr('5000.50'), isNull);
      expect(validateInr('250000'), isNull);
    });

    test('valid USD amounts', () {
      expect(validateUsd('10'), isNull);
      expect(validateUsd('2999.99'), isNull);
    });
  });
}
