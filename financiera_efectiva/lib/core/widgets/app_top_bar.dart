import 'package:flutter/material.dart';

import '../../app/routes/route_names.dart';
import '../../app/theme/app_colors.dart';
import 'brand_logo.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: AppColors.navy,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        tooltip: 'Perfil',
        icon: const Icon(Icons.account_circle_outlined),
        onPressed: () => Navigator.pushNamed(context, RouteNames.profile),
      ),
      title: const BrandLogo(compact: true, light: true),
      actions: [
        IconButton(
          tooltip: 'Notificaciones',
          icon: const Icon(Icons.notifications_none),
          onPressed: () => _showNotifications(context),
        ),
      ],
    );
  }

  void _showNotifications(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Notificaciones'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.credit_score),
                title: Text('Cuota próxima'),
                subtitle: Text('Tu siguiente cuota vence pronto.'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.savings),
                title: Text('Movimiento registrado'),
                subtitle: Text('Se actualizo tu historial financiero.'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
