class OperationHistoryItem {
  const OperationHistoryItem({
    required this.type,
    required this.date,
    required this.amount,
    required this.status,
  });

  final String type;
  final String date;
  final num amount;
  final String status;
}
