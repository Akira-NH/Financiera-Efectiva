import 'package:flutter/material.dart';

import '../../../app/routes/route_names.dart';
import '../../../core/services/financial_firestore_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../domain/entities/deposit.dart';
import '../domain/entities/savings_account.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({this.showAppBar = true, super.key});

  final bool showAppBar;

  Future<({SavingsAccount account, List<Deposit> deposits})> _loadData() async {
    final account = await FinancialFirestoreService.instance
        .getSavingsAccount();
    final deposits = await FinancialFirestoreService.instance.getDeposits();
    return (account: account, deposits: deposits);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? const AppTopBar() : null,
      body: FutureBuilder(
        future: _loadData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final account = snapshot.data!.account;
          final deposits = snapshot.data!.deposits;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(account.number),
                    const SizedBox(height: 8),
                    Text(
                      Formatters.currency(account.balance),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text('Estado: ${account.status}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Depósitos', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (deposits.isEmpty)
                const Text('Aún no tienes depósitos registrados.')
              else
                ...deposits.map(
                  (deposit) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.add_circle_outline),
                    title: Text(Formatters.currency(deposit.amount)),
                    subtitle: Text('${deposit.date} - ${deposit.reference}'),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, RouteNames.accountStatement);
                },
                icon: const Icon(Icons.description),
                label: const Text('Ver estados de cuenta'),
              ),
            ],
          );
        },
      ),
    );
  }
}
