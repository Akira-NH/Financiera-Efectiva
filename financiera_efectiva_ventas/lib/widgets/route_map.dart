import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/models/route_visit.dart';
import '../data/services/geolocation_route_service.dart';

class RouteMap extends StatelessWidget {
  const RouteMap({
    super.key,
    required this.visits,
    this.calculation,
  });

  final List<RouteVisit> visits;
  final RouteCalculation? calculation;

  @override
  Widget build(BuildContext context) {
    final geolocatedVisits = visits
        .where((visit) => visit.latitude != 0 && visit.longitude != 0)
        .toList();

    if (geolocatedVisits.length < 2 || _shouldUseFallbackMap) {
      return FallbackRouteMap(visits: visits);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 300,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _centerOf(geolocatedVisits),
            zoom: 10,
          ),
          markers: _markersFor(geolocatedVisits),
          polylines: _polylinesFor(geolocatedVisits, calculation),
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }

  bool get _shouldUseFallbackMap {
    return kIsWeb || defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux || defaultTargetPlatform == TargetPlatform.macOS;
  }

  LatLng _centerOf(List<RouteVisit> visits) {
    final lat = visits.fold<double>(0, (sum, visit) => sum + visit.latitude) / visits.length;
    final lng = visits.fold<double>(0, (sum, visit) => sum + visit.longitude) / visits.length;
    return LatLng(lat, lng);
  }

  Set<Marker> _markersFor(List<RouteVisit> visits) {
    return {
      for (var index = 0; index < visits.length; index++)
        Marker(
          markerId: MarkerId('visit_$index'),
          position: LatLng(visits[index].latitude, visits[index].longitude),
          infoWindow: InfoWindow(
            title: visits[index].client,
            snippet: visits[index].address,
          ),
        ),
    };
  }

  Set<Polyline> _polylinesFor(List<RouteVisit> visits, RouteCalculation? calculation) {
    final decodedRoute = _decodePolyline(calculation?.encodedPolyline ?? '');
    final points = decodedRoute.isNotEmpty
        ? decodedRoute
        : [
            for (final visit in visits) LatLng(visit.latitude, visit.longitude),
          ];

    return {
      Polyline(
        polylineId: const PolylineId('daily_route'),
        points: points,
        color: const Color(0xFF3135FF),
        width: 5,
      ),
    };
  }

  List<LatLng> _decodePolyline(String encoded) {
    if (encoded.isEmpty) return const [];

    final points = <LatLng>[];
    var index = 0;
    var lat = 0;
    var lng = 0;

    while (index < encoded.length) {
      final latResult = _decodeNextValue(encoded, index);
      index = latResult.nextIndex;
      lat += latResult.value;

      final lngResult = _decodeNextValue(encoded, index);
      index = lngResult.nextIndex;
      lng += lngResult.value;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  _PolylineDecodeValue _decodeNextValue(String encoded, int startIndex) {
    var index = startIndex;
    var shift = 0;
    var result = 0;
    var byte = 0;

    do {
      byte = encoded.codeUnitAt(index++) - 63;
      result |= (byte & 0x1F) << shift;
      shift += 5;
    } while (byte >= 0x20 && index < encoded.length);

    final value = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
    return _PolylineDecodeValue(value, index);
  }
}

class FallbackRouteMap extends StatelessWidget {
  const FallbackRouteMap({super.key, required this.visits});

  final List<RouteVisit> visits;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD8DEE8)),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: RoutePainter())),
          Positioned.fill(
            child: CustomPaint(
              painter: CoordinateRoutePainter(visits: visits),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final positions = _normalizedPositions(visits);
              return Stack(
                children: [
                  for (var index = 0; index < visits.length && index < positions.length; index++)
                    Positioned(
                      left: constraints.maxWidth * positions[index].dx,
                      top: constraints.maxHeight * positions[index].dy,
                      child: Tooltip(
                        message: '${visits[index].client}\n${visits[index].address}',
                        child: MapPin(label: '${index + 1}'),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  List<Offset> _normalizedPositions(List<RouteVisit> visits) {
    final geolocated = visits.where((visit) => visit.latitude != 0 && visit.longitude != 0).toList();
    if (geolocated.isEmpty) return _pinPositions.take(visits.length).toList();

    final minLat = geolocated.map((visit) => visit.latitude).reduce(min);
    final maxLat = geolocated.map((visit) => visit.latitude).reduce(max);
    final minLng = geolocated.map((visit) => visit.longitude).reduce(min);
    final maxLng = geolocated.map((visit) => visit.longitude).reduce(max);
    final latSpan = max(maxLat - minLat, .0001);
    final lngSpan = max(maxLng - minLng, .0001);

    return [
      for (final visit in visits)
        Offset(
          .10 + ((visit.longitude - minLng) / lngSpan) * .75,
          .10 + (1 - (visit.latitude - minLat) / latSpan) * .75,
        ),
    ];
  }
}

const _pinPositions = [
  Offset(.07, .13),
  Offset(.35, .28),
  Offset(.64, .16),
  Offset(.82, .68),
  Offset(.22, .70),
];

class RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFD5E4EC)
      ..strokeWidth = 1;
    for (var offset = 32.0; offset < size.width; offset += 56) {
      canvas.drawLine(Offset(offset, 0), Offset(offset, size.height), gridPaint);
    }
    for (var offset = 28.0; offset < size.height; offset += 48) {
      canvas.drawLine(Offset(0, offset), Offset(size.width, offset), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CoordinateRoutePainter extends CustomPainter {
  const CoordinateRoutePainter({required this.visits});

  final List<RouteVisit> visits;

  @override
  void paint(Canvas canvas, Size size) {
    final positions = _positions(size);
    if (positions.length < 2) return;

    final roadPaint = Paint()
      ..color = const Color(0xFF3135FF)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(positions.first.dx + 18, positions.first.dy + 18);
    for (final position in positions.skip(1)) {
      path.lineTo(position.dx + 18, position.dy + 18);
    }
    canvas.drawPath(path, roadPaint);
  }

  List<Offset> _positions(Size size) {
    final geolocated = visits.where((visit) => visit.latitude != 0 && visit.longitude != 0).toList();
    if (geolocated.isEmpty) {
      return [
        for (final offset in _pinPositions.take(visits.length))
          Offset(size.width * offset.dx, size.height * offset.dy),
      ];
    }

    final minLat = geolocated.map((visit) => visit.latitude).reduce(min);
    final maxLat = geolocated.map((visit) => visit.latitude).reduce(max);
    final minLng = geolocated.map((visit) => visit.longitude).reduce(min);
    final maxLng = geolocated.map((visit) => visit.longitude).reduce(max);
    final latSpan = max(maxLat - minLat, .0001);
    final lngSpan = max(maxLng - minLng, .0001);

    return [
      for (final visit in visits)
        Offset(
          size.width * (.10 + ((visit.longitude - minLng) / lngSpan) * .75),
          size.height * (.10 + (1 - (visit.latitude - minLat) / latSpan) * .75),
        ),
    ];
  }

  @override
  bool shouldRepaint(covariant CoordinateRoutePainter oldDelegate) {
    return oldDelegate.visits != visits;
  }
}

class MapPin extends StatelessWidget {
  const MapPin({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _PolylineDecodeValue {
  const _PolylineDecodeValue(this.value, this.nextIndex);

  final int value;
  final int nextIndex;
}
