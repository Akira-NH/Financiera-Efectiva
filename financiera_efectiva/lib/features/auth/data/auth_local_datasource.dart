import '../domain/entities/user.dart';

class AuthLocalDatasource {
  Future<User> login({required String email, required String password}) async {
    return User(id: 'client-001', fullName: 'Cliente Demo', email: email);
  }

  Future<User> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    return User(id: 'client-001', fullName: fullName, email: email);
  }
}
