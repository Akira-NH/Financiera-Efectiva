import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../data/repositories/sales_repository.dart';
import '../widgets/app_shell_widgets.dart';
import '../widgets/customer_card.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key, required this.repository});

  final SalesRepository repository;

  @override
  Widget build(BuildContext context) {
    return AppScrollView(
      children: [
        const SectionTitle(
          title: 'Cartera diaria',
          subtitle: 'Renovaciones y visitas cargadas automaticamente.',
        ),
        const MetricsGrid(
          metrics: [
            Metric('Renovaciones', '18', Icons.repeat, AppTheme.brandBlue),
            Metric('Visitas hoy', '12', Icons.location_on, AppTheme.brandNavy),
            Metric('Monto potencial', 'S/ 96k', Icons.payments, AppTheme.brandCoral),
            Metric('Mora alerta', '3', Icons.warning_amber, AppTheme.brandGold),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final client in repository.clients)
              SizedBox(width: 360, child: CustomerCard(client: client)),
          ],
        ),
      ],
    );
  }
}
