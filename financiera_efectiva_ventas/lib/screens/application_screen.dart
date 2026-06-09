import 'package:flutter/material.dart';

import '../data/repositories/sales_repository.dart';
import '../widgets/app_shell_widgets.dart';

class ApplicationScreen extends StatefulWidget {
  const ApplicationScreen({super.key, required this.repository});

  final SalesRepository repository;

  @override
  State<ApplicationScreen> createState() => _ApplicationScreenState();
}

class _ApplicationScreenState extends State<ApplicationScreen> {
  bool dniCaptured = true;
  bool legalDocsCaptured = false;
  bool offlineSaved = true;
  final amountController = TextEditingController(text: '12000');
  final termController = TextEditingController(text: '12');

  @override
  void dispose() {
    amountController.dispose();
    termController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScrollView(
      children: [
        const SectionTitle(
          title: 'Nueva solicitud de credito',
          subtitle: 'Captura de datos y documentos en campo.',
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final twoColumns = constraints.maxWidth > 760;
            final width = twoColumns ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: width,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const PanelHeader('Datos de solicitud', Icons.edit_note),
                          const SizedBox(height: 12),
                          TextFormField(
                            initialValue: widget.repository.clients.first.name,
                            decoration: const InputDecoration(labelText: 'Cliente'),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: amountController,
                                  decoration: const InputDecoration(labelText: 'Monto solicitado'),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: termController,
                                  decoration: const InputDecoration(labelText: 'Plazo meses'),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const TextField(
                            decoration: InputDecoration(labelText: 'Destino del credito'),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () {
                              setState(() => offlineSaved = true);
                            },
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('Guardar borrador local'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const PanelHeader('Documentos y envio', Icons.camera_alt_outlined),
                          const SizedBox(height: 8),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: dniCaptured,
                            onChanged: (value) => setState(() => dniCaptured = value),
                            title: const Text('Foto de DNI capturada'),
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: legalDocsCaptured,
                            onChanged: (value) => setState(() => legalDocsCaptured = value),
                            title: const Text('Documentos legales capturados'),
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: offlineSaved,
                            onChanged: (value) => setState(() => offlineSaved = value),
                            title: const Text('Borrador guardado'),
                          ),
                          const Divider(height: 24),
                          const BureauCheck(),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: dniCaptured && legalDocsCaptured ? () {} : null,
                            icon: const Icon(Icons.cloud_upload_outlined),
                            label: const Text('Transmitir al sistema central'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class BureauCheck extends StatelessWidget {
  const BureauCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: .12),
        child: Icon(
          Icons.verified_user_outlined,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      title: const Text('Consulta de buro completada'),
      subtitle: const Text('2 entidades | deuda total S/ 14,200 | riesgo medio'),
      trailing: Icon(
        Icons.check_circle,
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
