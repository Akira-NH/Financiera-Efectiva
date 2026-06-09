import '../models/client.dart';
import '../models/credit_request.dart';
import '../models/route_visit.dart';
import 'sales_repository.dart';

class FirestoreSalesRepository implements SalesRepository {
  const FirestoreSalesRepository({
    required this.clients,
    required this.routeVisits,
    required this.requests,
  });

  @override
  final List<Client> clients;

  @override
  final List<RouteVisit> routeVisits;

  @override
  final List<CreditRequest> requests;
}
