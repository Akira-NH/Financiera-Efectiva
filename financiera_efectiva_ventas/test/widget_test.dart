import 'package:financiera_efectiva_ventas/app.dart';
import 'package:financiera_efectiva_ventas/data/repositories/mock_sales_repository.dart';
import 'package:financiera_efectiva_ventas/data/services/firestore_sales_service.dart';
import 'package:financiera_efectiva_ventas/data/services/power_bi_export_service.dart';
import 'package:financiera_efectiva_ventas/utils/scoring.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows sales force dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const FuerzaVentasApp());
    await tester.pumpAndSettle();

    expect(find.text('Financiera Efectiva | Fuerza de Ventas'), findsOneWidget);
    expect(find.text('Cartera diaria'), findsOneWidget);
    expect(find.text('Maria Quispe Ramos'), findsWidgets);
    expect(find.text('Sincronizado'), findsOneWidget);
  });

  test('classifies final scores from scoring rules', () {
    expect(classifyFinal(760, false), 'PREMIER');
    expect(classifyFinal(620, false), 'ESTANDAR');
    expect(classifyFinal(360, false), 'BASICO');
    expect(classifyFinal(900, true), 'NO APLICA');
  });

  test('builds Firestore sync summary and Power BI dataset', () {
    const repository = MockSalesRepository();
    const firestore = FirestoreSalesService();
    const exporter = PowerBiExportService();

    final summary = firestore.buildSyncSummary(repository);
    final dataset = exporter.buildDataset(
      clients: repository.clients,
      requests: repository.requests,
      routeVisits: repository.routeVisits,
    );

    expect(summary[FirestoreSalesService.clientsCollection], 3);
    expect(dataset.clientsCsv, contains('dni,nombres,telefono'));
    expect(dataset.requestsCsv, contains('cliente,monto,segmento,estado'));
    expect(dataset.totalRows, 10);
  });
}
