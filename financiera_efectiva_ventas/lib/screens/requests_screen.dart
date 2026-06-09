import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/models/credit_request.dart';
import '../utils/scoring.dart';
import '../data/repositories/sales_repository.dart';
import '../data/services/firestore_sales_service.dart';
import '../data/services/power_bi_export_service.dart';
import '../widgets/app_shell_widgets.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key, required this.repository});

  final SalesRepository repository;

  @override
  Widget build(BuildContext context) {
    return AppScrollView(
      children: [
        const SectionTitle(
          title: 'Estado de solicitudes',
          subtitle: 'Seguimiento desde preaprobado hasta desembolsado.',
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (final request in repository.requests)
                  RequestTimelineTile(request: request),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ExportPanel(repository: repository),
      ],
    );
  }
}

class RequestTimelineTile extends StatelessWidget {
  const RequestTimelineTile({super.key, required this.request});

  final CreditRequest request;

  @override
  Widget build(BuildContext context) {
    const states = [
      'Preaprobado',
      'Contactado',
      'Visita agendada',
      'Visita realizada',
      'Comite',
      'Aprobado',
      'Desembolsado',
    ];
    final current = states.indexOf(request.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${request.client} | ${request.amount}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              StatusPill(
                label: request.status,
                color: segmentColor(request.segment),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < states.length; i++)
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: i <= current
                            ? Theme.of(context).colorScheme.secondary
                            : const Color(0xFFD8DEE8),
                        child: i <= current
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 6),
                      Text(states[i]),
                      if (i < states.length - 1)
                        Container(
                          width: 28,
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: i < current
                              ? Theme.of(context).colorScheme.secondary
                              : const Color(0xFFD8DEE8),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExportPanel extends StatelessWidget {
  const ExportPanel({super.key, required this.repository});

  final SalesRepository repository;

  @override
  Widget build(BuildContext context) {
    const powerBiExport = PowerBiExportService();
    const firestoreService = FirestoreSalesService();
    final dataset = powerBiExport.buildDataset(
      clients: repository.clients,
      requests: repository.requests,
      routeVisits: repository.routeVisits,
    );
    final syncSummary = firestoreService.buildSyncSummary(repository);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PanelHeader('Exportacion de datos', Icons.dataset_outlined),
            const SizedBox(height: 12),
            const Text(
              'Datos preparados para seguimiento comercial y reportes de gestion.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusPill(
                  label: '${syncSummary.keys.length} colecciones',
                  color: Theme.of(context).colorScheme.primary,
                ),
                StatusPill(
                  label: '${dataset.totalRows} registros',
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const StatusPill(
                  label: 'Firestore activo',
                  color: Color(0xFFF4B740),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    _showCsvPreview(context, 'perfiles_clientes.csv', dataset.clientsCsv);
                  },
                  icon: const Icon(Icons.table_view_outlined),
                  label: const Text('Clientes'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    _showCsvPreview(context, 'creditos_preaprobados.csv', dataset.requestsCsv);
                  },
                  icon: const Icon(Icons.dashboard_customize_outlined),
                  label: const Text('Solicitudes'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    _showCsvPreview(context, 'visitas_ruta.csv', dataset.routeCsv);
                  },
                  icon: const Icon(Icons.route_outlined),
                  label: const Text('Rutas'),
                ),
                FilledButton.icon(
                  onPressed: () => _syncFirestore(context, firestoreService),
                  icon: const Icon(Icons.cloud_sync_outlined),
                  label: const Text('Sincronizar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _syncFirestore(
    BuildContext context,
    FirestoreSalesService firestoreService,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await firestoreService.syncRepository(repository);
      messenger.showSnackBar(
        const SnackBar(content: Text('Datos sincronizados con Firestore')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudo sincronizar con Firestore')),
      );
    }
  }

  void _showCsvPreview(BuildContext context, String fileName, String csv) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(fileName),
          content: SizedBox(
            width: 640,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(csv),
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: csv));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Datos copiados')),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copiar CSV'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
