import 'package:flutter/material.dart';

import '../data/models/client.dart';
import '../utils/scoring.dart';
import 'app_shell_widgets.dart';

class CustomerCard extends StatelessWidget {
  const CustomerCard({super.key, required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: .1),
                  child: const Icon(Icons.person_outline),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(client.businessName, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                StatusPill(label: client.segment, color: segmentColor(client.segment)),
              ],
            ),
            const Divider(height: 24),
            Text('Renovacion: ${client.renewalDate}'),
            Text('Score preliminar: ${client.preScore}'),
            Text('Ubicacion: ${client.location}'),
          ],
        ),
      ),
    );
  }
}
