import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../app/routes/route_names.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/financial_firestore_service.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../domain/entities/operation_contact.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  OperationContact? _contact;
  bool _isSaving = false;
  bool _loadedArguments = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedArguments) return;

    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is OperationContact) {
      _contact = arguments;
    }
    _loadedArguments = true;
  }

  Future<void> _confirm() async {
    if (!_formKey.currentState!.validate()) return;
    final contact = _contact;
    if (contact == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un contacto registrado.')),
      );
      return;
    }

    final amount = num.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingresa un monto válido.')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      await FinancialFirestoreService.instance.recordContactTransfer(
        contact: contact,
        amount: amount,
        description: _descriptionController.text,
      );

      if (!mounted) return;
      Navigator.pushNamed(context, RouteNames.operationConfirmation);
    } catch (error) {
      if (!mounted) return;
      final message = _messageForTransferError(error);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _messageForTransferError(Object error) {
    if (error is AppException) return error.message;
    if (error is TimeoutException) {
      return 'La transferencia tardó demasiado. Intenta nuevamente.';
    }
    if (error is FirebaseException) {
      return switch (error.code) {
        'permission-denied' =>
          'Firestore rechazó la transferencia. Revisa las reglas de clients, savings, movements y operations.',
        'unavailable' =>
          'Firestore no está disponible en este momento. Intenta nuevamente.',
        _ => 'Error de Firestore: ${error.code}',
      };
    }
    return 'No se pudo realizar la transferencia.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Depósito a contacto')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_contact == null)
              _MissingContact(
                onSearch: () => Navigator.pop(context),
              )
            else
              _SelectedContact(contact: _contact!),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Monto',
              controller: _amountController,
              keyboardType: TextInputType.number,
              validator: (value) =>
                  Validators.required(value, fieldName: 'Monto'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Descripción',
              controller: _descriptionController,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: _isSaving ? 'Guardando...' : 'Confirmar depósito',
              icon: Icons.check_circle,
              onPressed: _isSaving || _contact == null ? null : _confirm,
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedContact extends StatelessWidget {
  const _SelectedContact({required this.contact});

  final OperationContact contact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.primary,
            backgroundImage: contact.photoUrl == null
                ? null
                : NetworkImage(contact.photoUrl!),
            child: contact.photoUrl == null
                ? Text(
                    contact.initials,
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.fullName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(contact.email),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MissingContact extends StatelessWidget {
  const _MissingContact({required this.onSearch});

  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text('Primero selecciona un contacto registrado.'),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onSearch,
            icon: const Icon(Icons.search),
            label: const Text('Buscar contacto'),
          ),
        ],
      ),
    );
  }
}
