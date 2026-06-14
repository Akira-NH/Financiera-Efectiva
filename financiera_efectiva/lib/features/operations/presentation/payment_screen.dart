import 'package:flutter/material.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/financial_firestore_service.dart';
import '../../../core/utils/formatters.dart';
import '../../dashboard/domain/entities/financial_summary.dart';
import '../domain/entities/service_bill.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Future<List<ServiceBill>> _billsFuture;
  late Future<FinancialSummary> _summaryFuture;
  ServiceBill? _selectedBill;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _billsFuture = FinancialFirestoreService.instance.getServiceBills();
    _summaryFuture = FinancialFirestoreService.instance.getSummary();
  }

  void _reloadData() {
    setState(() {
      _billsFuture = FinancialFirestoreService.instance.getServiceBills();
      _summaryFuture = FinancialFirestoreService.instance.getSummary();
    });
  }

  Future<void> _confirmPayment() async {
    final bill = _selectedBill;
    if (bill == null || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      await FinancialFirestoreService.instance.payServiceBill(bill);
      if (!mounted) return;
      _showMessage('Pago exitoso. Saldo actualizado.');
      setState(() => _selectedBill = null);
      _reloadData();
    } catch (error) {
      if (!mounted) return;
      final message = error is AppException
          ? error.message
          : 'No se pudo realizar el pago.';
      _showMessage(message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pago de servicios')),
      body: FutureBuilder<List<ServiceBill>>(
        future: _billsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('No se pudieron cargar los servicios.\n${snapshot.error}'),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bills = snapshot.data!;
          final selectedBill = _selectedBill;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Servicios disponibles',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              _AvailableBalance(future: _summaryFuture),
              const SizedBox(height: 12),
              for (final bill in bills)
                _ServiceTile(
                  bill: bill,
                  selected: selectedBill?.id == bill.id,
                  onTap: bill.canPay
                      ? () => setState(() => _selectedBill = bill)
                      : null,
                ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: selectedBill == null
                    ? const _EmptySelection()
                    : _SelectedBillPanel(
                        key: ValueKey(selectedBill.id),
                        bill: selectedBill,
                        isSaving: _isSaving,
                        onCancel: () => setState(() => _selectedBill = null),
                        onConfirm: _confirmPayment,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AvailableBalance extends StatelessWidget {
  const _AvailableBalance({required this.future});

  final Future<FinancialSummary> future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FinancialSummary>(
      future: future,
      builder: (context, snapshot) {
        final amount = snapshot.data?.savingsBalance;
        return Card(
          child: ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Saldo disponible'),
            trailing: Text(
              amount == null ? '--' : Formatters.currency(amount),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        );
      },
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.bill,
    required this.selected,
    required this.onTap,
  });

  final ServiceBill bill;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        enabled: onTap != null,
        selected: selected,
        leading: CircleAvatar(
          backgroundColor: selected
              ? colorScheme.primary
              : colorScheme.primary.withValues(alpha: .12),
          child: Icon(
            _iconForBill(bill),
            color: selected ? colorScheme.onPrimary : colorScheme.primary,
          ),
        ),
        title: Text('${bill.type}: ${bill.companyName}'),
        subtitle: Text(
          bill.canPay
              ? 'Vence ${bill.dueDateLabel}'
              : 'Recibo pagado. Espera el próximo vencimiento.',
        ),
        trailing: Text(
          Formatters.currency(bill.amount),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        onTap: onTap,
      ),
    );
  }

  IconData _iconForBill(ServiceBill bill) {
    return switch (bill.type) {
      'Agua' => Icons.water_drop_outlined,
      'Luz' => Icons.bolt_outlined,
      _ => Icons.wifi_outlined,
    };
  }
}

class _SelectedBillPanel extends StatelessWidget {
  const _SelectedBillPanel({
    required this.bill,
    required this.isSaving,
    required this.onCancel,
    required this.onConfirm,
    super.key,
  });

  final ServiceBill bill;
  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalle del recibo',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _DetailRow('Empresa', bill.companyName),
            _DetailRow('Monto a pagar', Formatters.currency(bill.amount)),
            _DetailRow('Fecha de vencimiento', bill.dueDateLabel),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isSaving ? null : onCancel,
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isSaving ? null : onConfirm,
                    icon: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle_outline),
                    label: Text(isSaving ? 'Pagando...' : 'Confirmar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _EmptySelection extends StatelessWidget {
  const _EmptySelection();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Selecciona un servicio para ver el recibo.'),
      ),
    );
  }
}
