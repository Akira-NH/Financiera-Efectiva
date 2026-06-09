import '../constants/storage_keys.dart';
import 'local_storage_service.dart';

class SessionService {
  SessionService(this._storage);

  final LocalStorageService _storage;

  Future<void> saveSession({required String clientName}) async {
    await _storage.setBool(StorageKeys.isLoggedIn, true);
    await _storage.setString(StorageKeys.clientName, clientName);
  }

  Future<void> clearSession() async {
    await _storage.setBool(StorageKeys.isLoggedIn, false);
  }

  Future<bool> isLoggedIn() {
    return _storage.getBool(StorageKeys.isLoggedIn);
  }
}
