import 'package:flutter/material.dart';

import '../../../app/routes/route_names.dart';
import '../../../core/services/financial_firestore_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_top_bar.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({this.showAppBar = true, super.key});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? const AppTopBar() : null,
      body: FutureBuilder(
        future: FinancialFirestoreService.instance.getActiveLoan(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('No se pudo cargar el crédito.\n${snapshot.error}'),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final loan = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loan.id),
                    const SizedBox(height: 8),
                    Text(
                      'Préstamo activo: ${Formatters.currency(loan.amount)}',
                    ),
                    Text(
                      'Saldo pendiente: ${Formatters.currency(loan.pendingBalance)}',
                    ),
                    Text('Estado: ${loan.status}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, RouteNames.loanDetail),
                icon: const Icon(Icons.info_outline),
                label: const Text('Detalle del préstamo'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, RouteNames.paymentSchedule);
                },
                icon: const Icon(Icons.calendar_month),
                label: const Text('Cronograma de cuotas'),
              ),
            ],
          );
        },
      ),
    );
  }
}
