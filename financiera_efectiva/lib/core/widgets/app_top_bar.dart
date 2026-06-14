import 'package:flutter/material.dart';

import '../../app/routes/route_names.dart';
import '../../app/theme/app_colors.dart';
import '../services/financial_firestore_service.dart';
import '../../features/operations/domain/entities/service_bill.dart';
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
          content: FutureBuilder<List<ServiceNotification>>(
            future: FinancialFirestoreService.instance.getServiceNotifications(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(
                  width: 260,
                  height: 96,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final notifications = snapshot.data!;
              if (notifications.isEmpty) {
                return const SizedBox(
                  width: 260,
                  child: Text('No tienes recibos pendientes por ahora.'),
                );
              }

              return SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final notification in notifications)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(_iconForNotification(notification)),
                        title: Text(notification.title),
                        subtitle: Text(notification.message),
                      ),
                  ],
                ),
              );
            },
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

  IconData _iconForNotification(ServiceNotification notification) {
    return switch (notification.iconName) {
      'Agua' => Icons.water_drop_outlined,
      'Luz' => Icons.bolt_outlined,
      _ => Icons.wifi_outlined,
    };
  }
}
