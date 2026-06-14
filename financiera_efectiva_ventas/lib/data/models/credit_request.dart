class CreditRequest {
  const CreditRequest(this.client, this.amount, this.segment, this.status);

  final String client;
  final String amount;
  final String segment;
  final String status;

  factory CreditRequest.fromJson(Map<String, Object?> json) {
    final rawAmount = json['monto'] ?? json['amountLabel'] ?? json['amount'];
    return CreditRequest(
      json['cliente'] as String? ?? '',
      rawAmount is num
          ? 'S/ ${rawAmount.toStringAsFixed(2)}'
          : rawAmount as String? ?? '',
      json['segmento'] as String? ?? '',
      json['estado'] as String? ?? json['status'] as String? ?? '',
    );
  }

  Map<String, Object?> toJson() {
    return {
      'cliente': client,
      'monto': amount,
      'segmento': segment,
      'estado': status,
    };
  }
}
