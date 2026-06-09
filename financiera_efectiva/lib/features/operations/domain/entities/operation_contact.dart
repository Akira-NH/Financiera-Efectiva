class OperationContact {
  const OperationContact({
    required this.id,
    required this.fullName,
    required this.email,
    required this.documentNumber,
    this.photoUrl,
  });

  final String id;
  final String fullName;
  final String email;
  final String documentNumber;
  final String? photoUrl;

  String get initials {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    final first = parts.first[0];
    final second = parts.length > 1 ? parts.last[0] : '';
    return '$first$second'.toUpperCase();
  }
}
