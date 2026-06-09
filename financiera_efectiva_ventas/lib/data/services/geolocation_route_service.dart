import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../../config/route_function_config.dart';
import '../models/route_visit.dart';

class GeolocationRouteService {
  const GeolocationRouteService();

  Future<RouteCalculation> calculateRoute(List<RouteVisit> visits) async {
    final geolocatedVisits = visits
        .where((visit) => visit.latitude != 0 && visit.longitude != 0)
        .toList();

    if (geolocatedVisits.length < 2) {
      return const RouteCalculation.empty();
    }

    final googleRoutesResult = await _calculateWithGoogleRoutes(geolocatedVisits);
    if (googleRoutesResult != null) {
      return googleRoutesResult;
    }

    try {
      final uri = _buildOsrmUri(geolocatedVisits);
      final response = await NetworkAssetBundle(uri).loadString('');
      final json = jsonDecode(response) as Map<String, dynamic>;
      final routes = json['routes'] as List<dynamic>? ?? [];
      if (routes.isEmpty) {
        return _calculateOffline(geolocatedVisits);
      }

      final route = routes.first as Map<String, dynamic>;
      return RouteCalculation(
        distanceKm: ((route['distance'] as num?)?.toDouble() ?? 0) / 1000,
        durationMinutes: ((route['duration'] as num?)?.toDouble() ?? 0) / 60,
        source: RouteCalculationSource.api,
      );
    } catch (_) {
      return _calculateOffline(geolocatedVisits);
    }
  }

  Future<RouteCalculation?> _calculateWithGoogleRoutes(List<RouteVisit> visits) async {
    final functionUrl = RouteFunctionConfig.googleRoutesFunctionUrl;
    if (functionUrl.isEmpty) return null;

    try {
      final uri = _buildGoogleRoutesFunctionUri(functionUrl, visits);
      final response = await NetworkAssetBundle(uri).loadString('');
      final json = jsonDecode(response) as Map<String, dynamic>;
      final calculation = _parseGoogleRouteResponse(json);

      return calculation;
    } catch (_) {
      return null;
    }
  }

  Uri _buildGoogleRoutesFunctionUri(String functionUrl, List<RouteVisit> visits) {
    final points = visits
        .map((visit) => '${visit.latitude.toStringAsFixed(6)},${visit.longitude.toStringAsFixed(6)}')
        .join(';');
    return Uri.parse(functionUrl).replace(queryParameters: {'points': points});
  }

  RouteCalculation? _parseGoogleRouteResponse(Map<String, dynamic> json) {
    final normalizedDistance = (json['distanceMeters'] as num?)?.toDouble() ?? 0;
    final normalizedDuration = (json['durationSeconds'] as num?)?.toDouble() ?? 0;

    if (normalizedDistance > 0 && normalizedDuration > 0) {
      return RouteCalculation(
        distanceKm: normalizedDistance / 1000,
        durationMinutes: normalizedDuration / 60,
        source: RouteCalculationSource.googleRoutes,
        encodedPolyline: json['encodedPolyline'] as String? ?? '',
      );
    }

    final routes = json['routes'] as List<dynamic>? ?? [];
    if (routes.isEmpty) return null;

    final route = routes.first as Map<String, dynamic>;
    final legs = route['legs'] as List<dynamic>? ?? [];
    if (legs.isEmpty) return null;

    var distanceMeters = 0.0;
    var durationSeconds = 0.0;
    for (final legValue in legs) {
      final leg = legValue as Map<String, dynamic>;
      distanceMeters += (leg['distance']?['value'] as num?)?.toDouble() ?? 0;
      durationSeconds += (leg['duration']?['value'] as num?)?.toDouble() ?? 0;
    }

    if (distanceMeters <= 0 || durationSeconds <= 0) return null;

    return RouteCalculation(
      distanceKm: distanceMeters / 1000,
      durationMinutes: durationSeconds / 60,
      source: RouteCalculationSource.googleRoutes,
      encodedPolyline: route['overview_polyline']?['points'] as String? ?? '',
    );
  }

  Uri _buildOsrmUri(List<RouteVisit> visits) {
    final coordinates = visits
        .map((visit) => '${visit.longitude.toStringAsFixed(6)},${visit.latitude.toStringAsFixed(6)}')
        .join(';');
    return Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/$coordinates?overview=false&steps=false',
    );
  }

  RouteCalculation _calculateOffline(List<RouteVisit> visits) {
    var distance = 0.0;
    for (var index = 0; index < visits.length - 1; index++) {
      distance += _haversineKm(visits[index], visits[index + 1]);
    }

    const cityTrafficFactor = 1.35;
    const averageSpeedKmH = 24.0;
    final adjustedDistance = distance * cityTrafficFactor;
    final minutes = adjustedDistance / averageSpeedKmH * 60;

    return RouteCalculation(
      distanceKm: adjustedDistance,
      durationMinutes: minutes,
      source: RouteCalculationSource.offlineEstimate,
    );
  }

  double _haversineKm(RouteVisit from, RouteVisit to) {
    const earthRadiusKm = 6371.0;
    final dLat = _degreesToRadians(to.latitude - from.latitude);
    final dLon = _degreesToRadians(to.longitude - from.longitude);
    final lat1 = _degreesToRadians(from.latitude);
    final lat2 = _degreesToRadians(to.latitude);
    final a = pow(sin(dLat / 2), 2) +
        cos(lat1) * cos(lat2) * pow(sin(dLon / 2), 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}

class RouteCalculation {
  const RouteCalculation({
    required this.distanceKm,
    required this.durationMinutes,
    required this.source,
    this.encodedPolyline = '',
  });

  const RouteCalculation.empty()
      : distanceKm = 0,
        durationMinutes = 0,
        source = RouteCalculationSource.offlineEstimate,
        encodedPolyline = '';

  final double distanceKm;
  final double durationMinutes;
  final RouteCalculationSource source;
  final String encodedPolyline;

  String get sourceLabel {
    return switch (source) {
      RouteCalculationSource.api => 'Ruta optimizada',
      RouteCalculationSource.googleRoutes => 'Ruta optimizada',
      RouteCalculationSource.offlineEstimate => 'Ruta estimada',
    };
  }
}

enum RouteCalculationSource { api, googleRoutes, offlineEstimate }
