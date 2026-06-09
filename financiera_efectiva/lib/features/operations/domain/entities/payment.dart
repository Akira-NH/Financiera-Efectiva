class Payment {
  const Payment({
    required this.serviceName,
    required this.reference,
    required this.amount,
  });

  final String serviceName;
  final String reference;
  final num amount;
}
