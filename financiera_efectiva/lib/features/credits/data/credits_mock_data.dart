import '../domain/entities/installment.dart';
import '../domain/entities/loan.dart';

class CreditsMockData {
  const CreditsMockData._();

  static const activeLoan = Loan(
    id: 'CRE-44882',
    amount: 3000000,
    pendingBalance: 650000,
    status: 'Al día',
  );

  static const installments = [
    Installment(number: 1, dueDate: '05/04/2026', amount: 180000, isPaid: true),
    Installment(number: 2, dueDate: '05/05/2026', amount: 180000, isPaid: true),
    Installment(
      number: 3,
      dueDate: '05/06/2026',
      amount: 180000,
      isPaid: false,
    ),
  ];
}
