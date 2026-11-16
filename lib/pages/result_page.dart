import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../bloc/invest_bloc.dart';
import '../bloc/invest_event.dart';
import '../bloc/invest_state.dart';
import '../core/date_formatter.dart';
import '../core/failures.dart';
import '../core/money_formatter.dart';
import '../models/fund.dart';
import '../models/order.dart';
import '../widgets/summary_row.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  void _close(BuildContext context) {
    context.read<InvestBloc>().add(const OrderClosed());
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvestBloc, InvestState>(
      buildWhen: (previous, current) =>
          current.orderStatus != OrderStatus.idle,
      builder: (context, state) {
        final isSubmitting = state.orderStatus == OrderStatus.submitting;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && !isSubmitting) _close(context);
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Order status'),
              automaticallyImplyLeading: false,
            ),
            body: SafeArea(
              child: switch (state.orderStatus) {
                OrderStatus.success => _SuccessView(
                  order: state.order!,
                  onDone: () => _close(context),
                ),
                OrderStatus.failure => _FailureView(
                  failure: state.orderFailure!,
                  onTryAgain: () =>
                      context.read<InvestBloc>().add(const OrderSubmitted()),
                  onEditAmount: () => _close(context),
                ),
                OrderStatus.submitting ||
                OrderStatus.idle => const _SubmittingView(),
              },
            ),
          ),
        );
      },
    );
  }
}

class _ResultLayout extends StatelessWidget {
  const _ResultLayout({required this.content, required this.actions});

  final List<Widget> content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: content,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: actions,
          ),
        ),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.order, required this.onDone});

  final Order order;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _ResultLayout(
      content: [
        Lottie.asset(
          'assets/lottie/success.json',
          height: 160,
          repeat: false,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.check_circle,
            size: 120,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Order placed successfully',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 24),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SummaryRow(label: 'Order ID', value: order.orderId),
                SummaryRow(label: 'Fund', value: Fund.globalIndex.name),
                SummaryRow(
                  label: 'Amount',
                  value: MoneyFormatter.format(
                    order.amountMinor,
                    order.currency,
                  ),
                  emphasize: true,
                ),
                SummaryRow(label: 'Currency', value: order.currency.code),
                SummaryRow(
                  label: 'Placed at',
                  value: DateFormatter.orderTime(order.placedAt),
                ),
              ],
            ),
          ),
        ),
      ],
      actions: [FilledButton(onPressed: onDone, child: const Text('Done'))],
    );
  }
}

class _FailureView extends StatelessWidget {
  const _FailureView({
    required this.failure,
    required this.onTryAgain,
    required this.onEditAmount,
  });

  final Failure failure;
  final VoidCallback onTryAgain;
  final VoidCallback onEditAmount;

  (String, String) get _texts => switch (failure) {
    NetworkFailure() => ('No connection', failure.message),
    TimeoutFailure() => (
      'We could not confirm your order',
      'The server did not respond within 10 seconds, so we could not '
          'confirm if your order was placed. You can try again or edit the '
          'amount.',
    ),
    ServerFailure() => ('Order not placed', failure.message),
    InvalidAmountFailure() => ('Amount not accepted', failure.message),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (title, message) = _texts;
    return _ResultLayout(
      content: [
        const SizedBox(height: 24),
        Icon(Icons.error_outline, size: 96, color: theme.colorScheme.error),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
      ],
      actions: [
        FilledButton(onPressed: onTryAgain, child: const Text('Try Again')),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: onEditAmount,
          child: const Text('Edit Amount'),
        ),
      ],
    );
  }
}

class _SubmittingView extends StatelessWidget {
  const _SubmittingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Placing your order...'),
        ],
      ),
    );
  }
}
