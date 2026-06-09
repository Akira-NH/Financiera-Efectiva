import '../domain/entities/account_statement.dart';
import '../domain/entities/deposit.dart';
import '../domain/entities/savings_account.dart';

class SavingsMockData {
  const SavingsMockData._();

  static const account = SavingsAccount(
    number: 'AHO-102938',
    balance: 1000,
    status: 'Activa',
  );

  static const deposits = [
    Deposit(date: '19/05/2026', amount: 250000, reference: 'DEP-001'),
    Deposit(date: '12/05/2026', amount: 150000, reference: 'DEP-002'),
  ];

  static const statements = [
    AccountStatement(
      period: 'Mayo 2026',
      openingBalance: 1550000,
      closingBalance: 1800000,
    ),
    AccountStatement(
      period: 'Abril 2026',
      openingBalance: 1320000,
      closingBalance: 1550000,
    ),
  ];
}
