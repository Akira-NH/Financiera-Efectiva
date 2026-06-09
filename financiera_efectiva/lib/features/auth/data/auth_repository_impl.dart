import '../domain/entities/user.dart';
import '../domain/repositories/auth_repository.dart';
import 'auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._datasource);

  final AuthLocalDatasource _datasource;

  @override
  Future<User> login({required String email, required String password}) {
    return _datasource.login(email: email, password: password);
  }

  @override
  Future<User> register({
    required String fullName,
    required String email,
    required String password,
  }) {
    return _datasource.register(
      fullName: fullName,
      email: email,
      password: password,
    );
  }
}
