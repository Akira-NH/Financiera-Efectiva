class ClientAccount {
  const ClientAccount({
    required this.id,
    required this.documentType,
    required this.documentNumber,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
  });

  final String id;
  final String documentType;
  final String documentNumber;
  final String fullName;
  final String email;
  final String phone;
  final String password;

  ClientAccount copyWith({
    String? id,
    String? documentType,
    String? documentNumber,
    String? fullName,
    String? email,
    String? phone,
    String? password,
  }) {
    return ClientAccount(
      id: id ?? this.id,
      documentType: documentType ?? this.documentType,
      documentNumber: documentNumber ?? this.documentNumber,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
    );
  }
}
