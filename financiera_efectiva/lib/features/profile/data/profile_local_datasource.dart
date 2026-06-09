import '../domain/entities/client_profile.dart';

class ProfileLocalDatasource {
  Future<ClientProfile> getProfile() async {
    return const ClientProfile(
      fullName: 'Cliente Demo',
      document: '1000000000',
      email: 'cliente@demo.com',
      phone: '3001234567',
    );
  }
}
