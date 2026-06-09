import 'package:flutter/material.dart';

import '../data/repositories/sales_repository.dart';
import '../widgets/app_shell_widgets.dart';

class CustomerScreen extends StatelessWidget {
  const CustomerScreen({super.key, required this.repository});

  final SalesRepository repository;

  @override
  Widget build(BuildContext context) {
    final client = repository.clients.first;

    return AppScrollView(
      children: [
        SectionTitle(
          title: 'Ficha del cliente',
          subtitle: '${client.name} | DNI ${client.dni}',
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            InfoPanel(
              title: 'Datos generales',
              icon: Icons.person_outline,
              rows: [
                InfoRow('Telefono', client.phone),
                InfoRow('Ubicacion', client.location),
                InfoRow('Edad', '${client.age} anos'),
                InfoRow('Calificacion SBS', client.sbsRating),
              ],
            ),
            InfoPanel(
              title: 'Negocio',
              icon: Icons.store_mall_directory_outlined,
              rows: [
                InfoRow('Nombre', client.businessName),
                InfoRow('Rubro', client.businessType),
                InfoRow('Antiguedad', client.businessAge),
                InfoRow('Local', client.premises),
              ],
            ),
            InfoPanel(
              title: 'Productos activos',
              icon: Icons.credit_card,
              rows: [
                const InfoRow('Credito vigente', 'S/ 8,500'),
                const InfoRow('Cuota', 'S/ 860'),
                const InfoRow('Pago puntual', '92%'),
                InfoRow('Deuda SBS', 'S/ ${client.totalDebt}'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        const CreditHistory(),
      ],
    );
  }
}

class CreditHistory extends StatelessWidget {
  const CreditHistory({super.key});

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['Credito 00124', 'Cancelado', 'S/ 6,000', '0 dias mora'],
      ['Credito 00188', 'Vigente', 'S/ 8,500', '2 dias mora max.'],
      ['Renovacion', 'Pendiente', 'S/ 12,000', 'Preaprobado'],
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PanelHeader('Historial crediticio', Icons.history),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Producto')),
                  DataColumn(label: Text('Estado')),
                  DataColumn(label: Text('Monto')),
                  DataColumn(label: Text('Comportamiento')),
                ],
                rows: [
                  for (final row in rows)
                    DataRow(cells: [for (final cell in row) DataCell(Text(cell))]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
