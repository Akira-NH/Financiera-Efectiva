class CreditRequest {
  const CreditRequest(this.client, this.amount, this.segment, this.status);

  final String client;
  final String amount;
  final String segment;
  final String status;

  factory CreditRequest.fromJson(Map<String, Object?> json) {
    return CreditRequest(
      json['cliente'] as String? ?? '',
      json['monto'] as String? ?? '',
      json['segmento'] as String? ?? '',
      json['estado'] as String? ?? '',
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
