import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  FirebaseAuthService._();

  static final FirebaseAuthService instance = FirebaseAuthService._();

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  Future<void> register({
    required String fullName,
    required String documentNumber,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );

    final user = credential.user;
    if (user == null) return;

    await user.updateDisplayName(fullName.trim());
    await _firestore.collection('clients').doc(user.uid).set({
      'fullName': fullName.trim(),
      'documentType': 'DNI',
      'documentNumber': documentNumber.trim(),
      'email': email.trim().toLowerCase(),
      'totalBalance': 1000,
      'savingsBalance': 1000,
      'activeLoansBalance': 0,
      'financialProfileSeeded': true,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.setLanguageCode('es');
    await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String messageForAuthError(Object error) {
    if (error is! FirebaseAuthException) {
      return 'No se pudo completar la operación. Intenta nuevamente.';
    }

    return switch (error.code) {
      'invalid-email' => 'El correo no tiene un formato válido.',
      'user-disabled' => 'Este usuario está deshabilitado.',
      'user-not-found' => 'No existe una cuenta con ese correo.',
      'wrong-password' => 'La contraseña es incorrecta.',
      'invalid-credential' => 'Correo o contraseña incorrectos.',
      'email-already-in-use' => 'Ya existe una cuenta con ese correo.',
      'weak-password' => 'La contraseña es demasiado débil.',
      'network-request-failed' => 'Revisa tu conexión a internet.',
      _ => 'Error de autenticación: ${error.code}',
    };
  }
}
