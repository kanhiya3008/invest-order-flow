import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invest_order_flow/bloc/invest_bloc.dart';
import 'package:invest_order_flow/bloc/invest_event.dart';
import 'package:invest_order_flow/bloc/invest_state.dart';
import 'package:invest_order_flow/core/failures.dart';
import 'package:invest_order_flow/models/balances.dart';
import 'package:invest_order_flow/models/currency.dart';
import 'package:invest_order_flow/models/order.dart';
import 'package:invest_order_flow/services/invest_api.dart';
import 'package:mocktail/mocktail.dart';

class MockInvestApi extends Mock implements InvestApi {}

void main() {
  late MockInvestApi api;

  const balances = Balances({Currency.inr: 25000000, Currency.usd: 300000});

  const ready = InvestState(
    balanceStatus: BalanceStatus.loaded,
    balances: balances,
    amountText: '5000',
    amountTouched: true,
    idempotencyKey: 'key-1',
  );

  final order = Order(
    orderId: 'ORD-10231',
    status: 'PLACED',
    fundId: 'global-index-fund',
    currency: Currency.inr,
    amountMinor: 500000,
    placedAt: DateTime.utc(2026, 11, 13, 10, 44),
  );

  setUpAll(() {
    registerFallbackValue(
      const OrderRequest(
        fundId: 'f',
        currency: Currency.inr,
        amountMinor: 1,
        idempotencyKey: 'k',
      ),
    );
  });

  setUp(() {
    api = MockInvestApi();
  });

  InvestBloc buildBloc() => InvestBloc(api);

  blocTest<InvestBloc, InvestState>(
    'loads balances',
    setUp: () => when(() => api.getBalances()).thenAnswer((_) async => balances),
    build: buildBloc,
    act: (bloc) => bloc.add(const BalancesRequested()),
    expect: () => [
      const InvestState(),
      const InvestState(
        balanceStatus: BalanceStatus.loaded,
        balances: balances,
      ),
    ],
  );

  blocTest<InvestBloc, InvestState>(
    'shows an error when balances fail to load',
    setUp: () => when(() => api.getBalances()).thenThrow(const NetworkFailure()),
    build: buildBloc,
    act: (bloc) => bloc.add(const BalancesRequested()),
    verify: (bloc) {
      expect(bloc.state.balanceStatus, BalanceStatus.failure);
      expect(bloc.state.balanceError, const NetworkFailure().message);
      expect(bloc.state.canContinue, isFalse);
    },
  );

  blocTest<InvestBloc, InvestState>(
    'switching currency checks the amount again: 5000 is fine in INR '
    'but more than the USD balance',
    build: buildBloc,
    seed: () => ready,
    act: (bloc) => bloc.add(const CurrencyChanged(Currency.usd)),
    verify: (bloc) {
      expect(ready.canContinue, isTrue);
      expect(bloc.state.amountError, contains('available balance'));
      expect(bloc.state.canContinue, isFalse);
    },
  );

  blocTest<InvestBloc, InvestState>(
    'three quick taps on Confirm place only one order',
    setUp: () => when(() => api.placeOrder(any())).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return order;
    }),
    build: buildBloc,
    seed: () => ready,
    act: (bloc) => bloc
      ..add(const OrderSubmitted())
      ..add(const OrderSubmitted())
      ..add(const OrderSubmitted()),
    wait: const Duration(milliseconds: 100),
    verify: (bloc) {
      verify(() => api.placeOrder(any())).called(1);
      expect(bloc.state.orderStatus, OrderStatus.success);
    },
  );

  blocTest<InvestBloc, InvestState>(
    'Try Again after a timeout sends the same idempotency key',
    setUp: () {
      var calls = 0;
      when(() => api.placeOrder(any())).thenAnswer((_) async {
        calls++;
        if (calls == 1) throw const TimeoutFailure();
        return order;
      });
    },
    build: buildBloc,
    seed: () => ready,
    act: (bloc) async {
      bloc.add(const OrderSubmitted());
      await Future<void>.delayed(const Duration(milliseconds: 10));
      bloc.add(const OrderSubmitted());
    },
    wait: const Duration(milliseconds: 10),
    verify: (bloc) {
      expect(bloc.state.orderStatus, OrderStatus.success);
      final sent = verify(
        () => api.placeOrder(captureAny()),
      ).captured.cast<OrderRequest>();
      expect(sent, hasLength(2));
      expect(sent.map((r) => r.idempotencyKey), everyElement('key-1'));
    },
  );

  blocTest<InvestBloc, InvestState>(
    'Done after a successful order lowers the balance and clears the amount',
    build: buildBloc,
    seed: () => ready.copyWith(orderStatus: OrderStatus.success, order: order),
    act: (bloc) => bloc.add(const OrderClosed()),
    verify: (bloc) {
      expect(bloc.state.balanceMinor, 25000000 - 500000);
      expect(bloc.state.amountText, isEmpty);
      expect(bloc.state.orderStatus, OrderStatus.idle);
    },
  );
}
