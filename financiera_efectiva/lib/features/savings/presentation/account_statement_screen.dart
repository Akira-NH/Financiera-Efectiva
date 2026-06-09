import 'package:flutter/material.dart';

import '../../../core/services/financial_firestore_service.dart';
import '../../../core/utils/formatters.dart';

class AccountStatementScreen extends StatelessWidget {
  const AccountStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estados de cuenta')),
      body: FutureBuilder(
        future: FinancialFirestoreService.instance.getStatements(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final statements = snapshot.data!;
          if (statements.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Aún no tienes estados de cuenta.'),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: statements.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, index) {
              final statement = statements[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(statement.period),
                subtitle: Text(
                  'Inicial ${Formatters.currency(statement.openingBalance)}',
                ),
                trailing: Text(Formatters.currency(statement.closingBalance)),
              );
            },
          );
        },
      ),
    );
  }
}
