import 'package:flutter/material.dart';

import '../bloc/invest_state.dart';
import '../core/money_formatter.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key, required this.state, required this.onRetry});

  final InvestState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Widget content = switch (state.balanceStatus) {
      BalanceStatus.loading => const Row(
        children: [
          SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Expanded(child: Text('Loading your balance...')),
        ],
      ),
      BalanceStatus.failure => Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Couldn't load your balance. ${state.balanceError ?? ''}",
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
      BalanceStatus.loaded => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Available balance', style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(
            MoneyFormatter.format(state.balanceMinor, state.currency),
            style: theme.textTheme.headlineSmall,
          ),
        ],
      ),
    };

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(padding: const EdgeInsets.all(16), child: content),
    );
  }
}
