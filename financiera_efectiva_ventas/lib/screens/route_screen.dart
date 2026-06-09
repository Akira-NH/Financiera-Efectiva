import 'package:flutter/material.dart';

import '../data/repositories/sales_repository.dart';
import '../data/services/geolocation_route_service.dart';
import '../widgets/app_shell_widgets.dart';
import '../widgets/route_map.dart';

class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key, required this.repository});

  final SalesRepository repository;

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  final routeService = const GeolocationRouteService();
  late Future<RouteCalculation> routeCalculation;

  @override
  void initState() {
    super.initState();
    routeCalculation = _calculateRoute();
  }

  Future<RouteCalculation> _calculateRoute() {
    return routeService.calculateRoute(widget.repository.routeVisits);
  }

  void _refreshRoute() {
    setState(() {
      routeCalculation = _calculateRoute();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScrollView(
      children: [
        const SectionTitle(
          title: 'Planificacion de ruta',
          subtitle: 'Mapa operativo de visitas del dia con geolocalizacion.',
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<RouteCalculation>(
                  future: routeCalculation,
                  builder: (context, snapshot) {
                    final calculation = snapshot.data;
                    final loading = snapshot.connectionState == ConnectionState.waiting;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RouteMap(
                          visits: widget.repository.routeVisits,
                          calculation: calculation,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            StatusPill(
                              label: loading
                                  ? 'Calculando ruta...'
                                  : '${calculation?.distanceKm.toStringAsFixed(1) ?? '--'} km',
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            StatusPill(
                              label: loading
                                  ? 'Calculando tiempo'
                                  : '${calculation?.durationMinutes.round() ?? '--'} min',
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            StatusPill(
                              label: calculation?.sourceLabel ?? 'Ruta optimizada',
                              color: const Color(0xFFF4B740),
                            ),
                            OutlinedButton.icon(
                              onPressed: loading ? null : _refreshRoute,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Recalcular'),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                for (final visit in widget.repository.routeVisits)
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: visit.statusColor.withValues(alpha: .12),
                      child: Icon(Icons.storefront, color: visit.statusColor),
                    ),
                    title: Text(visit.client),
                    subtitle: Text(
                      '${visit.address} | ${visit.objective}\n'
                      '${visit.latitude.toStringAsFixed(5)}, ${visit.longitude.toStringAsFixed(5)}',
                    ),
                    isThreeLine: true,
                    trailing: Text(
                      visit.time,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
