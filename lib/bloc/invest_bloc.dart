import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../core/failures.dart';
import '../models/fund.dart';
import '../models/order.dart';
import '../services/invest_api.dart';
import 'invest_event.dart';
import 'invest_state.dart';

class InvestBloc extends Bloc<InvestEvent, InvestState> {
  InvestBloc(this._api) : super(const InvestState()) {
    on<BalancesRequested>(_onBalancesRequested);
    on<CurrencyChanged>(
      (event, emit) => emit(state.copyWith(currency: event.currency)),
    );
    on<AmountChanged>(
      (event, emit) =>
          emit(state.copyWith(amountText: event.text, amountTouched: true)),
    );
    on<OrderStarted>(
      (event, emit) => emit(
        state.copyWith(
          orderStatus: OrderStatus.idle,
          idempotencyKey: const Uuid().v4(),
        ),
      ),
    );
    on<OrderSubmitted>(_onOrderSubmitted, transformer: droppable());
    on<OrderClosed>(_onOrderClosed);
  }

  final InvestApi _api;

  Future<void> _onBalancesRequested(
    BalancesRequested event,
    Emitter<InvestState> emit,
  ) async {
    emit(state.copyWith(balanceStatus: BalanceStatus.loading));
    try {
      final balances = await _api.getBalances();
      emit(
        state.copyWith(balanceStatus: BalanceStatus.loaded, balances: balances),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(
          balanceStatus: BalanceStatus.failure,
          balanceError: failure.message,
        ),
      );
    }
  }

  Future<void> _onOrderSubmitted(
    OrderSubmitted event,
    Emitter<InvestState> emit,
  ) async {
    final amountMinor = state.amountMinor;
    if (state.orderStatus == OrderStatus.success ||
        !state.canContinue ||
        amountMinor == null) {
      return;
    }

    emit(state.copyWith(orderStatus: OrderStatus.submitting));
    try {
      final order = await _api.placeOrder(
        OrderRequest(
          fundId: Fund.globalIndex.id,
          currency: state.currency,
          amountMinor: amountMinor,
          idempotencyKey: state.idempotencyKey,
        ),
      );
      emit(state.copyWith(orderStatus: OrderStatus.success, order: order));
    } on Failure catch (failure) {
      emit(
        state.copyWith(orderStatus: OrderStatus.failure, orderFailure: failure),
      );
    }
  }

  void _onOrderClosed(OrderClosed event, Emitter<InvestState> emit) {
    final order = state.order;
    final balances = state.balances;
    if (state.orderStatus == OrderStatus.success &&
        order != null &&
        balances != null) {
      emit(
        state.copyWith(
          balances: balances.deduct(order.currency, order.amountMinor),
          amountText: '',
          amountTouched: false,
          orderStatus: OrderStatus.idle,
        ),
      );
    } else {
      emit(state.copyWith(orderStatus: OrderStatus.idle));
    }
  }
}
