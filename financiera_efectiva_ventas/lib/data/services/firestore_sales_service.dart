import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/client.dart';
import '../models/credit_request.dart';
import '../models/route_visit.dart';
import '../repositories/firestore_sales_repository.dart';
import '../repositories/mock_sales_repository.dart';
import '../repositories/sales_repository.dart';

class FirestoreSalesService {
  const FirestoreSalesService();

  static const clientsCollection = 'sales_clients';
  static const requestsCollection = 'sales_credit_requests';
  static const routeVisitsCollection = 'sales_route_visits';
  static const scoringFeaturesCollection = 'sales_scoring_features';

  FirebaseFirestore? get _firestore {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseFirestore.instance;
  }

  Future<SalesRepository> loadRepository() async {
    final firestore = _firestore;
    const fallback = MockSalesRepository();
    if (firestore == null) return fallback;

    final snapshots = await Future.wait([
      firestore.collection(clientsCollection).get(),
      firestore.collection(requestsCollection).get(),
      firestore.collection(routeVisitsCollection).get(),
    ]);

    final clients = snapshots[0].docs
        .map((doc) => Client.fromJson(doc.data()))
        .where((client) => client.dni.isNotEmpty || client.name.isNotEmpty)
        .toList();
    final requests = snapshots[1].docs
        .map((doc) => CreditRequest.fromJson(doc.data()))
        .where((request) => request.client.isNotEmpty)
        .toList();
    final routeVisits = snapshots[2].docs
        .map((doc) => RouteVisit.fromJson(doc.data()))
        .where((visit) => visit.client.isNotEmpty)
        .toList();

    return FirestoreSalesRepository(
      clients: clients.isEmpty ? fallback.clients : clients,
      requests: requests.isEmpty ? fallback.requests : requests,
      routeVisits: routeVisits.isEmpty ? fallback.routeVisits : routeVisits,
    );
  }

  Future<void> syncRepository(SalesRepository repository) async {
    final firestore = _firestore;
    if (firestore == null) return;

    final batch = firestore.batch();

    for (final client in repository.clients) {
      final id = client.dni.isEmpty ? client.name : client.dni;
      batch.set(
        firestore.collection(clientsCollection).doc(id),
        client.toJson(),
        SetOptions(merge: true),
      );
      batch.set(
        firestore.collection(scoringFeaturesCollection).doc(id),
        _featureRowFromClient(client),
        SetOptions(merge: true),
      );
    }

    for (final request in repository.requests) {
      final id = '${request.client}_${request.amount}'.replaceAll('/', '-');
      batch.set(
        firestore.collection(requestsCollection).doc(id),
        request.toJson(),
        SetOptions(merge: true),
      );
    }

    for (final visit in repository.routeVisits) {
      final id = '${visit.time}_${visit.client}'.replaceAll('/', '-');
      batch.set(
        firestore.collection(routeVisitsCollection).doc(id),
        visit.toJson(),
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  Map<String, int> buildSyncSummary(SalesRepository repository) {
    return {
      clientsCollection: repository.clients.length,
      requestsCollection: repository.requests.length,
      routeVisitsCollection: repository.routeVisits.length,
      scoringFeaturesCollection: repository.clients.length,
    };
  }

  Map<String, Object?> _featureRowFromClient(Client client) {
    final scoreCampo = switch (client.segment) {
      'PREMIER' => 180,
      'ESTANDAR' => 145,
      _ => 95,
    };
    return {
      'dni': client.dni,
      'capacidad_ahorro': (client.preScore * .25).round(),
      'regularidad_ingresos': (client.preScore * .20).round(),
      'disciplina_financiera': (client.preScore * .20).round(),
      'vinculo_institucion': (client.preScore * .20).round(),
      'riesgo': (client.preScore * .15).round(),
      'score_transaccional': client.preScore,
      'score_campo': scoreCampo,
      'score_final': client.preScore + scoreCampo,
      'segmento_final': client.segment,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
