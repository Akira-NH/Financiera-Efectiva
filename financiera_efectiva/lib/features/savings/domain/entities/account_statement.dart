class AccountStatement {
  const AccountStatement({
    required this.period,
    required this.openingBalance,
    required this.closingBalance,
  });

  final String period;
  final num openingBalance;
  final num closingBalance;
}
