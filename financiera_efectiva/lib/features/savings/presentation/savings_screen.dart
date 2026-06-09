import 'package:flutter/material.dart';

import '../../../app/routes/route_names.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/financial_firestore_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../domain/entities/deposit.dart';
import '../domain/entities/savings_account.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({this.showAppBar = true, super.key});

  final bool showAppBar;

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  late Future<_SavingsData> _savingsFuture;

  @override
  void initState() {
    super.initState();
    _savingsFuture = _loadData();
  }

  Future<_SavingsData> _loadData() async {
    final account = await FinancialFirestoreService.instance
        .getSavingsAccount();
    final deposits = await FinancialFirestoreService.instance.getDeposits();
    return _SavingsData(account: account, deposits: deposits);
  }

  void _refresh() {
    setState(() {
      _savingsFuture = _loadData();
    });
  }

  void _replaceAccount(SavingsAccount account) {
    setState(() {
      _savingsFuture = _loadData().then(
        (data) => _SavingsData(account: account, deposits: data.deposits),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? const AppTopBar() : null,
      body: FutureBuilder<_SavingsData>(
        future: _savingsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('No se pudo cargar ahorros.\n${snapshot.error}'),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final account = snapshot.data!.account;
          final deposits = snapshot.data!.deposits;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(account.number),
                    const SizedBox(height: 8),
                    Text(
                      Formatters.currency(account.balance),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text('Estado: ${account.status}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _PiggyBankSection(
                account: account,
                onAccountChanged: _replaceAccount,
                onHistoryChanged: _refresh,
              ),
              const SizedBox(height: 16),
              Text('Depósitos', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (deposits.isEmpty)
                const Text('Aún no tienes depósitos registrados.')
              else
                ...deposits.map(
                  (deposit) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.add_circle_outline),
                    title: Text(Formatters.currency(deposit.amount)),
                    subtitle: Text('${deposit.date} - ${deposit.reference}'),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, RouteNames.accountStatement);
                },
                icon: const Icon(Icons.description),
                label: const Text('Ver estados de cuenta'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PiggyBankSection extends StatefulWidget {
  const _PiggyBankSection({
    required this.account,
    required this.onAccountChanged,
    required this.onHistoryChanged,
  });

  final SavingsAccount account;
  final ValueChanged<SavingsAccount> onAccountChanged;
  final VoidCallback onHistoryChanged;

  @override
  State<_PiggyBankSection> createState() => _PiggyBankSectionState();
}

class _PiggyBankSectionState extends State<_PiggyBankSection> {
  final _amountController = TextEditingController();
  bool _isProcessing = false;
  _PiggyAnimation _animation = _PiggyAnimation.idle;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  num? _readAmount() {
    final raw = _amountController.text.trim();
    if (raw.isEmpty) return null;

    final withoutCurrency = raw
        .replaceAll('S/', '')
        .replaceAll('s/', '')
        .replaceAll(RegExp(r'\s+'), '');
    final normalized = withoutCurrency.contains(',')
        ? withoutCurrency.replaceAll('.', '').replaceAll(',', '.')
        : withoutCurrency.replaceAll(',', '');
    return num.tryParse(normalized);
  }

  String? _validateAmount(num? amount, _PiggyAnimation operation) {
    if (amount == null) {
      return 'Ingresa un monto numérico válido.';
    }
    if (amount <= 0) {
      return 'El monto debe ser mayor a cero.';
    }
    if (operation == _PiggyAnimation.deposit &&
        widget.account.balance < amount) {
      return 'Saldo disponible insuficiente para depositar en la alcancía.';
    }
    if (operation == _PiggyAnimation.withdraw &&
        widget.account.piggyBankBalance < amount) {
      return 'Saldo insuficiente en la alcancía para retirar.';
    }
    return null;
  }

  Future<void> _runOperation(_PiggyAnimation operation) async {
    if (_isProcessing) return;

    final amount = _readAmount();
    final validationMessage = _validateAmount(amount, operation);
    if (validationMessage != null) {
      _showMessage(validationMessage);
      return;
    }

    setState(() {
      _isProcessing = true;
      _animation = operation;
    });

    try {
      final service = FinancialFirestoreService.instance;
      final updatedAccount = operation == _PiggyAnimation.deposit
          ? await service.transferToPiggyBank(amount!)
          : await service.withdrawFromPiggyBank(amount!);

      if (!mounted) return;
      _amountController.clear();
      widget.onAccountChanged(updatedAccount);
      widget.onHistoryChanged();
      _showMessage(
        operation == _PiggyAnimation.deposit
            ? 'Depósito enviado a tu alcancía.'
            : 'Retiro devuelto a tu saldo disponible.',
      );
    } catch (error) {
      if (!mounted) return;
      final message = error is AppException
          ? error.message
          : 'No se pudo completar la operación.';
      _showMessage(message);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
        Future<void>.delayed(const Duration(milliseconds: 450), () {
          if (mounted && !_isProcessing) {
            setState(() => _animation = _PiggyAnimation.idle);
          }
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.savings_outlined, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Alcancía Digital',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _PiggyBankBalances(
            availableBalance: widget.account.balance,
            piggyBankBalance: widget.account.piggyBankBalance,
          ),
          const SizedBox(height: 14),
          _MoneyFlowAnimation(animation: _animation),
          const SizedBox(height: 14),
          TextField(
            controller: _amountController,
            enabled: !_isProcessing,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.payments_outlined),
              labelText: 'Monto',
              hintText: 'Ej. 50',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isProcessing
                      ? null
                      : () => _runOperation(_PiggyAnimation.deposit),
                  icon: _isProcessing && _animation == _PiggyAnimation.deposit
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_downward),
                  label: const Text('Depositar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isProcessing
                      ? null
                      : () => _runOperation(_PiggyAnimation.withdraw),
                  icon: _isProcessing && _animation == _PiggyAnimation.withdraw
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_upward),
                  label: const Text('Retirar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PiggyBankBalances extends StatelessWidget {
  const _PiggyBankBalances({
    required this.availableBalance,
    required this.piggyBankBalance,
  });

  final num availableBalance;
  final num piggyBankBalance;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BalanceChip(
            label: 'Disponible',
            amount: availableBalance,
            icon: Icons.account_balance_wallet_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _BalanceChip(
            label: 'Alcancía',
            amount: piggyBankBalance,
            icon: Icons.savings,
          ),
        ),
      ],
    );
  }
}

class _BalanceChip extends StatelessWidget {
  const _BalanceChip({
    required this.label,
    required this.amount,
    required this.icon,
  });

  final String label;
  final num amount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 8),
          Text(label),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              Formatters.currency(amount),
              key: ValueKey(amount),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoneyFlowAnimation extends StatelessWidget {
  const _MoneyFlowAnimation({required this.animation});

  final _PiggyAnimation animation;

  @override
  Widget build(BuildContext context) {
    final alignment = switch (animation) {
      _PiggyAnimation.deposit => Alignment.centerRight,
      _PiggyAnimation.withdraw => Alignment.centerLeft,
      _PiggyAnimation.idle => Alignment.center,
    };

    return SizedBox(
      height: 42,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: .18),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          AnimatedAlign(
            alignment: alignment,
            duration: const Duration(milliseconds: 520),
            curve: Curves.easeInOutCubic,
            child: AnimatedScale(
              scale: animation == _PiggyAnimation.idle ? .85 : 1.05,
              duration: const Duration(milliseconds: 260),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: const Icon(
                  Icons.monetization_on_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingsData {
  const _SavingsData({required this.account, required this.deposits});

  final SavingsAccount account;
  final List<Deposit> deposits;
}

enum _PiggyAnimation { idle, deposit, withdraw }
