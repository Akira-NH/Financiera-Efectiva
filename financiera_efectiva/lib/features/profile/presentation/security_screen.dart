import 'package:flutter/material.dart';

import '../../../core/services/client_database_service.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _biometricEnabled = false;
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas nuevas no coinciden')),
      );
      return;
    }

    final changed = ClientDatabaseService.instance.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          changed
              ? 'Contraseña actualizada correctamente'
              : 'La contraseña actual no es correcta',
        ),
      ),
    );

    if (!changed) return;
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seguridad')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            value: _biometricEnabled,
            onChanged: (value) => setState(() {
              _biometricEnabled = value;
            }),
            title: const Text('Acceso biométrico'),
            subtitle: const Text('Preparado para integración futura'),
          ),
          const SizedBox(height: 16),
          Text(
            'Cambiar contraseña',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  label: 'Contraseña actual',
                  controller: _currentPasswordController,
                  obscureText: true,
                  validator: Validators.password,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Nueva contraseña',
                  controller: _newPasswordController,
                  obscureText: true,
                  validator: Validators.password,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Confirmar nueva contraseña',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Actualizar contraseña',
                  icon: Icons.save,
                  onPressed: _changePassword,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
