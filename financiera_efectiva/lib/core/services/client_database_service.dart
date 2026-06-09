import '../../features/auth/domain/entities/client_account.dart';

class ClientDatabaseService {
  ClientDatabaseService._();

  static final ClientDatabaseService instance = ClientDatabaseService._();

  final List<ClientAccount> _clients = [
    const ClientAccount(
      id: 'CLI-001',
      documentType: 'DNI',
      documentNumber: '12345678',
      fullName: 'Ana Martinez',
      email: 'ana@financiera.com',
      phone: '3001234567',
      password: '123456',
    ),
    const ClientAccount(
      id: 'CLI-002',
      documentType: 'CC',
      documentNumber: '1002003004',
      fullName: 'Carlos Gomez',
      email: 'carlos@financiera.com',
      phone: '3109876543',
      password: 'credito1',
    ),
    const ClientAccount(
      id: 'CLI-003',
      documentType: 'CE',
      documentNumber: 'A123456',
      fullName: 'Mariana Rojas',
      email: 'mariana@financiera.com',
      phone: '3205557788',
      password: 'ahorro1',
    ),
  ];

  ClientAccount? _currentClient;

  ClientAccount? get currentClient => _currentClient;

  List<ClientAccount> get clients => List.unmodifiable(_clients);

  bool login({
    required String documentType,
    required String documentNumber,
    required String password,
  }) {
    final client = _findByDocument(documentType, documentNumber);
    if (client == null || client.password != password) return false;
    _currentClient = client;
    return true;
  }

  bool register(ClientAccount account) {
    final exists =
        _findByDocument(account.documentType, account.documentNumber) != null;
    if (exists) return false;
    _clients.add(account);
    _currentClient = account;
    return true;
  }

  bool changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    final client = _currentClient;
    if (client == null || client.password != currentPassword) return false;

    final index = _clients.indexWhere((item) => item.id == client.id);
    if (index == -1) return false;

    final updated = client.copyWith(password: newPassword);
    _clients[index] = updated;
    _currentClient = updated;
    return true;
  }

  bool resetPasswordByDocument({
    required String documentType,
    required String documentNumber,
    required String newPassword,
  }) {
    final client = _findByDocument(documentType, documentNumber);
    if (client == null) return false;

    final index = _clients.indexWhere((item) => item.id == client.id);
    if (index == -1) return false;

    final updated = client.copyWith(password: newPassword);
    _clients[index] = updated;
    if (_currentClient?.id == client.id) {
      _currentClient = updated;
    }
    return true;
  }

  void logout() {
    _currentClient = null;
  }

  ClientAccount? _findByDocument(String documentType, String documentNumber) {
    for (final client in _clients) {
      if (client.documentType == documentType &&
          client.documentNumber == documentNumber.trim()) {
        return client;
      }
    }
    return null;
  }
}
