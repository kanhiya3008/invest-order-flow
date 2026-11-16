import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/invest_bloc.dart';
import 'bloc/invest_event.dart';
import 'core/api_client.dart';
import 'pages/invest_page.dart';
import 'services/invest_api.dart';

class InvestApp extends StatelessWidget {
  const InvestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<InvestApi>(
          create: (_) => HttpInvestApi(ApiClient.create()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                InvestBloc(context.read<InvestApi>())
                  ..add(const BalancesRequested()),
          ),
        ],
        child: MaterialApp(
          title: 'Invest',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorSchemeSeed: const Color(0xFF1B5E20),
            useMaterial3: true,
          ),
          home: const InvestPage(),
        ),
      ),
    );
  }
}
