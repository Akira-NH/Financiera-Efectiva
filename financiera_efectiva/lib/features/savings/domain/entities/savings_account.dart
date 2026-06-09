class SavingsAccount {
  const SavingsAccount({
    required this.number,
    required this.balance,
    required this.status,
    this.piggyBankBalance = 0,
  });

  final String number;
  final num balance;
  final String status;
  final num piggyBankBalance;
}
