class ServiceBill {
  const ServiceBill({
    required this.id,
    required this.type,
    required this.companyName,
    required this.amount,
    required this.dueDate,
    required this.allowRepeatedPayments,
    this.isPaid = false,
  });

  final String id;
  final String type;
  final String companyName;
  final num amount;
  final DateTime dueDate;
  final bool allowRepeatedPayments;
  final bool isPaid;

  bool get canPay => allowRepeatedPayments || !isPaid;

  String get billingPeriod {
    final month = dueDate.month.toString().padLeft(2, '0');
    return '${dueDate.year}-$month';
  }

  bool get isDueSoon {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final difference = dueDate.difference(startOfToday).inDays;
    return !isPaid && difference >= 0 && difference <= 5;
  }

  String get dueDateLabel {
    final day = dueDate.day.toString().padLeft(2, '0');
    final month = dueDate.month.toString().padLeft(2, '0');
    return '$day/$month/${dueDate.year}';
  }

  ServiceBill copyWith({bool? isPaid}) {
    return ServiceBill(
      id: id,
      type: type,
      companyName: companyName,
      amount: amount,
      dueDate: dueDate,
      allowRepeatedPayments: allowRepeatedPayments,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}

class ServiceNotification {
  const ServiceNotification({
    required this.title,
    required this.message,
    required this.iconName,
  });

  final String title;
  final String message;
  final String iconName;
}
