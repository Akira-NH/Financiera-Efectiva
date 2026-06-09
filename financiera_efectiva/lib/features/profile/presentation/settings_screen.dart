import 'package:flutter/material.dart';

import '../../../app/theme/theme_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          SwitchListTile(
            value: _notificationsEnabled,
            onChanged: (value) => setState(() {
              _notificationsEnabled = value;
            }),
            title: const Text('Notificaciones'),
            subtitle: const Text('Alertas de pagos y movimientos'),
          ),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeController.mode,
            builder: (context, mode, _) {
              return SwitchListTile(
                value: mode == ThemeMode.dark,
                onChanged: ThemeController.setDarkMode,
                title: const Text('Modo oscuro'),
                subtitle: const Text('Cambia el tema visual de la app'),
                secondary: const Icon(Icons.dark_mode),
              );
            },
          ),
        ],
      ),
    );
  }
}
