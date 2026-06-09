import 'package:financiera_efectiva/app/app.dart';
import 'package:financiera_efectiva/core/services/client_database_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('navigates from splash to login', (tester) async {
    await tester.pumpWidget(const FinancieraEfectivaApp());
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
  });

  test('authenticates and changes password for seeded client', () {
    final database = ClientDatabaseService.instance;

    expect(
      database.login(
        documentType: 'DNI',
        documentNumber: '12345678',
        password: '123456',
      ),
      isTrue,
    );

    expect(
      database.changePassword(currentPassword: '123456', newPassword: '654321'),
      isTrue,
    );

    database.logout();

    expect(
      database.login(
        documentType: 'DNI',
        documentNumber: '12345678',
        password: '654321',
      ),
      isTrue,
    );

    expect(
      database.changePassword(currentPassword: '654321', newPassword: '123456'),
      isTrue,
    );
  });
}
