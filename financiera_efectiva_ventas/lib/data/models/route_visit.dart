import 'package:flutter/material.dart';

class RouteVisit {
  const RouteVisit(
    this.time,
    this.client,
    this.address,
    this.objective,
    this.statusColor,
    [
    this.latitude = 0,
    this.longitude = 0,
  ]
  );

  final String time;
  final String client;
  final String address;
  final String objective;
  final Color statusColor;
  final double latitude;
  final double longitude;

  factory RouteVisit.fromJson(Map<String, Object?> json) {
    return RouteVisit(
      json['hora'] as String? ?? '',
      json['cliente'] as String? ?? '',
      json['direccion'] as String? ?? '',
      json['objetivo'] as String? ?? '',
      Color(json['color_estado'] as int? ?? 0xFF3135FF),
      (json['latitud'] as num?)?.toDouble() ?? 0,
      (json['longitud'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'hora': time,
      'cliente': client,
      'direccion': address,
      'objetivo': objective,
      'color_estado': statusColor.toARGB32(),
      'latitud': latitude,
      'longitud': longitude,
    };
  }
}
