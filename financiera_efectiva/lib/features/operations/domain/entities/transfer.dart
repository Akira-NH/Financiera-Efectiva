class Transfer {
  const Transfer({
    required this.destinationAccount,
    required this.amount,
    required this.description,
  });

  final String destinationAccount;
  final num amount;
  final String description;
}
