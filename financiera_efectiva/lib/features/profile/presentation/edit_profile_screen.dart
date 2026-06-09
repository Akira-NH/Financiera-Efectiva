import 'package:flutter/material.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const AppTextField(label: 'Nombre completo'),
          const SizedBox(height: 16),
          const AppTextField(label: 'Telefono'),
          const SizedBox(height: 16),
          const AppTextField(label: 'Correo'),
          const SizedBox(height: 24),
          AppButton(
            label: 'Guardar cambios',
            icon: Icons.save,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
