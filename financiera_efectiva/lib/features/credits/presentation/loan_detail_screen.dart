import 'package:flutter/material.dart';

import '../../../core/services/financial_firestore_service.dart';
import '../../../core/utils/formatters.dart';

class LoanDetailScreen extends StatelessWidget {
  const LoanDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del crédito')),
      body: FutureBuilder(
        future: FinancialFirestoreService.instance.getActiveLoan(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No se pudo cargar el detalle.\n${snapshot.error}',
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final loan = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Crédito ${loan.id}'),
                const SizedBox(height: 8),
                Text('Monto inicial: ${Formatters.currency(loan.amount)}'),
                Text(
                  'Saldo pendiente: ${Formatters.currency(loan.pendingBalance)}',
                ),
                Text('Estado: ${loan.status}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
