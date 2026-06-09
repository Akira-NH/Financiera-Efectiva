import 'package:flutter/material.dart';

import '../../../app/routes/route_names.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/financial_firestore_service.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serviceController = TextEditingController();
  final _referenceController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _serviceController.dispose();
    _referenceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = num.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingresa un monto válido.')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      await FinancialFirestoreService.instance.recordOperation(
        type: 'Pago',
        amount: amount,
        detail: {
          'service': _serviceController.text.trim(),
          'reference': _referenceController.text.trim(),
        },
      );

      if (!mounted) return;
      Navigator.pushNamed(context, RouteNames.operationConfirmation);
    } catch (error) {
      if (!mounted) return;
      final message = error is AppException
          ? error.message
          : 'No se pudo realizar el pago.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pago')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppTextField(
              label: 'Servicio',
              controller: _serviceController,
              validator: (value) =>
                  Validators.required(value, fieldName: 'Servicio'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Referencia',
              controller: _referenceController,
              validator: (value) =>
                  Validators.required(value, fieldName: 'Referencia'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Monto',
              controller: _amountController,
              keyboardType: TextInputType.number,
              validator: (value) =>
                  Validators.required(value, fieldName: 'Monto'),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: _isSaving ? 'Guardando...' : 'Confirmar pago',
              icon: Icons.check_circle,
              onPressed: _isSaving ? null : _confirm,
            ),
          ],
        ),
      ),
    );
  }
}
