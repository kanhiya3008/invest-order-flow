import 'package:flutter/material.dart';

import '../models/currency.dart';

class CurrencySelector extends StatelessWidget {
  const CurrencySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final Currency selected;
  final ValueChanged<Currency> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Currency>(
      segments: [
        for (final currency in Currency.values)
          ButtonSegment(
            value: currency,
            label: Text('${currency.symbol} ${currency.code}'),
          ),
      ],
      selected: {selected},
      showSelectedIcon: false,
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
