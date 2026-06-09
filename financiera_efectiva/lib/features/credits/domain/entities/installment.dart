class Installment {
  const Installment({
    required this.number,
    required this.dueDate,
    required this.amount,
    required this.isPaid,
  });

  final int number;
  final String dueDate;
  final num amount;
  final bool isPaid;
}
