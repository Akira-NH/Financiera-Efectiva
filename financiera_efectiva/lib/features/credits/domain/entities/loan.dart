class Loan {
  const Loan({
    required this.id,
    required this.amount,
    required this.pendingBalance,
    required this.status,
  });

  final String id;
  final num amount;
  final num pendingBalance;
  final String status;
}
