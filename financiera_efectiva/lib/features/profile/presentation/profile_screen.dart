import 'package:flutter/material.dart';

import '../../../app/routes/route_names.dart';
import '../../../core/services/client_database_service.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../core/widgets/app_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({this.showAppBar = true, super.key});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final client = ClientDatabaseService.instance.currentClient;
    final user = FirebaseAuthService.instance.currentUser;

    return Scaffold(
      appBar: showAppBar ? AppBar(title: const Text('Perfil')) : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(user?.displayName ?? client?.fullName ?? 'Cliente'),
              subtitle: Text(user?.email ?? client?.email ?? 'Sin correo'),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Editar perfil'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, RouteNames.editProfile),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuración'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, RouteNames.settings),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Seguridad'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, RouteNames.security),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: () async {
              await FirebaseAuthService.instance.signOut();
              ClientDatabaseService.instance.logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteNames.login,
                (_) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
