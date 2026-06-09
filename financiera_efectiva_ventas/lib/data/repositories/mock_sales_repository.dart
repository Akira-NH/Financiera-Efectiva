import 'package:flutter/material.dart';

import '../models/client.dart';
import '../models/credit_request.dart';
import '../models/route_visit.dart';
import 'sales_repository.dart';

class MockSalesRepository implements SalesRepository {
  const MockSalesRepository();

  @override
  List<Client> get clients => const [
        Client(
          name: 'Maria Quispe Ramos',
          dni: '74211890',
          phone: '987 554 210',
          location: 'San Juan de Lurigancho',
          age: 39,
          businessName: 'Bodega El Progreso',
          businessType: 'Comercio minorista',
          businessAge: '6 anos',
          premises: 'Alquilado',
          sbsRating: 'Normal',
          totalDebt: '14,200',
          preScore: 672,
          segment: 'ESTANDAR',
          renewalDate: 'Hoy',
        ),
        Client(
          name: 'Jose Huaman Flores',
          dni: '45881200',
          phone: '955 310 447',
          location: 'Villa El Salvador',
          age: 45,
          businessName: 'Ferreteria Huaman',
          businessType: 'Ferreteria',
          businessAge: '11 anos',
          premises: 'Propio',
          sbsRating: 'Normal',
          totalDebt: '22,600',
          preScore: 758,
          segment: 'PREMIER',
          renewalDate: 'Hoy',
        ),
        Client(
          name: 'Rosa Medina Soto',
          dni: '70444116',
          phone: '933 808 551',
          location: 'Comas',
          age: 34,
          businessName: 'Confecciones Rosa',
          businessType: 'Textil',
          businessAge: '3 anos',
          premises: 'Familiar',
          sbsRating: 'CPP',
          totalDebt: '7,900',
          preScore: 428,
          segment: 'BASICO',
          renewalDate: 'Manana',
        ),
      ];

  @override
  List<RouteVisit> get routeVisits => const [
        RouteVisit(
          '08:30',
          'Maria Quispe',
          'Av. Los Jardines 104',
          'Renovacion',
          Color(0xFF001B70),
          -11.9847,
          -77.0036,
        ),
        RouteVisit(
          '10:00',
          'Jose Huaman',
          'Mz. F Lt. 12',
          'Visita de campo',
          Color(0xFF3135FF),
          -12.2152,
          -76.9432,
        ),
        RouteVisit(
          '11:40',
          'Rosa Medina',
          'Jr. Los Telares 225',
          'Documentos',
          Color(0xFFE9C46A),
          -11.9336,
          -77.0479,
        ),
        RouteVisit(
          '14:20',
          'Carlos Vega',
          'Mercado Central puesto 18',
          'Buro y firma',
          Color(0xFFE76F51),
          -12.0464,
          -77.0428,
        ),
      ];

  @override
  List<CreditRequest> get requests => const [
        CreditRequest('Maria Quispe Ramos', 'S/ 12,000', 'ESTANDAR', 'Visita realizada'),
        CreditRequest('Jose Huaman Flores', 'S/ 24,000', 'PREMIER', 'Aprobado'),
        CreditRequest('Rosa Medina Soto', 'S/ 6,000', 'BASICO', 'Contactado'),
      ];
}
