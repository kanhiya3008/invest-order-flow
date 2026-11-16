import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/invest_bloc.dart';
import '../bloc/invest_event.dart';
import '../bloc/invest_state.dart';
import '../core/money_formatter.dart';
import '../models/fund.dart';
import '../widgets/summary_row.dart';
import 'result_page.dart';

class ConfirmPage extends StatelessWidget {
  const ConfirmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InvestBloc, InvestState>(
      listenWhen: (previous, current) =>
          previous.orderStatus == OrderStatus.submitting &&
          current.orderStatus != OrderStatus.submitting,
      listener: (context, state) {
        if (ModalRoute.of(context)?.isCurrent ?? false) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => const ResultPage()),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state.orderStatus == OrderStatus.submitting;
        final currency = state.currency;
        final amountMinor = state.amountMinor ?? 0;

        return PopScope(
          canPop: !isSubmitting,
          child: Scaffold(
            appBar: AppBar(title: const Text('Confirm order')),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              SummaryRow(
                                label: 'Fund',
                                value: Fund.globalIndex.name,
                              ),
                              SummaryRow(
                                label: 'Currency',
                                value: currency.code,
                              ),
                              SummaryRow(
                                label: 'Order amount',
                                value: MoneyFormatter.format(
                                  amountMinor,
                                  currency,
                                ),
                                emphasize: true,
                              ),
                              const Divider(),
                              SummaryRow(
                                label: 'Balance after this order',
                                value: MoneyFormatter.format(
                                  state.balanceMinor - amountMinor,
                                  currency,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton(
                          onPressed: isSubmitting
                              ? null
                              : () => context.read<InvestBloc>().add(
                                  const OrderSubmitted(),
                                ),
                          child: isSubmitting
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Confirm'),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('Edit amount'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
