import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/invest_bloc.dart';
import '../bloc/invest_event.dart';
import '../bloc/invest_state.dart';
import '../core/money_formatter.dart';
import '../models/fund.dart';
import '../widgets/balance_card.dart';
import '../widgets/currency_selector.dart';
import 'confirm_page.dart';

class InvestPage extends StatefulWidget {
  const InvestPage({super.key});

  @override
  State<InvestPage> createState() => _InvestPageState();
}

class _InvestPageState extends State<InvestPage> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onContinue() {
    FocusScope.of(context).unfocus();
    context.read<InvestBloc>().add(const OrderStarted());
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const ConfirmPage()));
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<InvestBloc>();
    final theme = Theme.of(context);

    return BlocListener<InvestBloc, InvestState>(
      listenWhen: (previous, current) =>
          previous.orderStatus == OrderStatus.success &&
          current.orderStatus == OrderStatus.idle,
      listener: (context, state) => _amountController.clear(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Invest')),
        body: SafeArea(
          child: BlocBuilder<InvestBloc, InvestState>(
            builder: (context, state) {
              final currency = state.currency;
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            Fund.globalIndex.name,
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Fund.globalIndex.description,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          CurrencySelector(
                            selected: currency,
                            onChanged: (value) =>
                                bloc.add(CurrencyChanged(value)),
                          ),
                          const SizedBox(height: 16),
                          BalanceCard(
                            state: state,
                            onRetry: () => bloc.add(const BalancesRequested()),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Min ${MoneyFormatter.format(currency.minMinor, currency)}'
                            '  ·  Max ${MoneyFormatter.format(currency.maxMinor, currency)} per order',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _amountController,
                            onChanged: (text) => bloc.add(AmountChanged(text)),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]'),
                              ),
                              LengthLimitingTextInputFormatter(12),
                            ],
                            decoration: InputDecoration(
                              labelText: 'Amount',
                              prefixText: '${currency.symbol} ',
                              border: const OutlineInputBorder(),
                              errorText: state.visibleAmountError,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: state.canContinue ? _onContinue : null,
                        child: const Text('Continue'),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
