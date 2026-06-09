import '../domain/entities/operation_history_item.dart';

class OperationsMockData {
  const OperationsMockData._();

  static const history = [
    OperationHistoryItem(
      type: 'Transferencia',
      date: '19/05/2026',
      amount: 120000,
      status: 'Exitosa',
    ),
    OperationHistoryItem(
      type: 'Pago de servicio',
      date: '18/05/2026',
      amount: 85000,
      status: 'Exitosa',
    ),
  ];
}
