import '../domain/entities/financial_summary.dart';
import '../domain/entities/movement.dart';

class DashboardMockData {
  const DashboardMockData._();

  static const summary = FinancialSummary(
    totalBalance: 1000,
    savingsBalance: 1000,
    activeLoansBalance: 0,
  );

  static const movements = [
    Movement(
      title: 'Deposito cuenta de ahorro',
      date: '19/05/2026',
      amount: 250000,
      isIncome: true,
    ),
    Movement(
      title: 'Pago cuota crédito',
      date: '18/05/2026',
      amount: 180000,
      isIncome: false,
    ),
    Movement(
      title: 'Transferencia recibida',
      date: '17/05/2026',
      amount: 320000,
      isIncome: true,
    ),
  ];
}
