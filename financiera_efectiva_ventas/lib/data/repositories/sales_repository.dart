import '../models/client.dart';
import '../models/credit_request.dart';
import '../models/route_visit.dart';

abstract class SalesRepository {
  List<Client> get clients;
  List<RouteVisit> get routeVisits;
  List<CreditRequest> get requests;
}
