class Movement {
  const Movement({
    required this.title,
    required this.date,
    required this.amount,
    required this.isIncome,
  });

  final String title;
  final String date;
  final num amount;
  final bool isIncome;
}
