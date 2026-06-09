import 'firebase_auth_service.dart';

class PasswordResetService {
  PasswordResetService._();

  static final PasswordResetService instance = PasswordResetService._();

  Future<void> sendResetEmail({required String email}) async {
    await FirebaseAuthService.instance.sendPasswordResetEmail(email);
  }
}
