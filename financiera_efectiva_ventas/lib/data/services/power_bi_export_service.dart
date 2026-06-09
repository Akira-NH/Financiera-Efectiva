import '../models/client.dart';
import '../models/credit_request.dart';
import '../models/route_visit.dart';

class PowerBiExportService {
  const PowerBiExportService();

  String buildClientCsv(List<Client> clients) {
    return _toCsv(
      [
        'dni',
        'nombres',
        'telefono',
        'ubicacion',
        'edad',
        'negocio',
        'rubro',
        'antiguedad_negocio',
        'tenencia_local',
        'calificacion_sbs',
        'deuda_total',
        'score_preliminar',
        'segmento',
        'fecha_renovacion',
      ],
      clients.map((client) => client.toJson()),
    );
  }

  String buildRequestsCsv(List<CreditRequest> requests) {
    return _toCsv(
      ['cliente', 'monto', 'segmento', 'estado'],
      requests.map((request) => request.toJson()),
    );
  }

  String buildRouteCsv(List<RouteVisit> visits) {
    return _toCsv(
      ['hora', 'cliente', 'direccion', 'objetivo', 'color_estado'],
      visits.map((visit) => visit.toJson()),
    );
  }

  PowerBiDataset buildDataset({
    required List<Client> clients,
    required List<CreditRequest> requests,
    required List<RouteVisit> routeVisits,
  }) {
    return PowerBiDataset(
      clientsCsv: buildClientCsv(clients),
      requestsCsv: buildRequestsCsv(requests),
      routeCsv: buildRouteCsv(routeVisits),
    );
  }

  String _toCsv(Iterable<String> headers, Iterable<Map<String, Object?>> rows) {
    final headerList = headers.toList();
    final lines = <String>[
      headerList.map(_escape).join(','),
      for (final row in rows)
        headerList.map((header) => _escape(row[header]?.toString() ?? '')).join(','),
    ];
    return lines.join('\n');
  }

  String _escape(String value) {
    final escaped = value.replaceAll('"', '""');
    if (escaped.contains(',') || escaped.contains('\n') || escaped.contains('"')) {
      return '"$escaped"';
    }
    return escaped;
  }
}

class PowerBiDataset {
  const PowerBiDataset({
    required this.clientsCsv,
    required this.requestsCsv,
    required this.routeCsv,
  });

  final String clientsCsv;
  final String requestsCsv;
  final String routeCsv;

  int get totalRows {
    return _dataRows(clientsCsv) + _dataRows(requestsCsv) + _dataRows(routeCsv);
  }

  int _dataRows(String csv) {
    final lines = csv.split('\n');
    return lines.isEmpty ? 0 : lines.length - 1;
  }
}
