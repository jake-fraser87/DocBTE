import '../models/user_model.dart';

/// AuthService owns "how do we authenticate". Today it's hardcoded;
/// tomorrow this same class can call a real API — nothing above it
/// (ViewModel/View) needs to change.
class AuthService {
  // --- Hardcoded credentials for now ---
  static const String _hardcodedUsername = 'admin';
  static const String _hardcodedPassword = 'admin123';

  static const UserModel _hardcodedUser = UserModel(
    username: 'admin',
    displayName: 'Admin User',
    role: 'Desk Administrator',
    zone: 'PCMC Zone',
  );

  Future<UserModel> login(String username, String password) async {
    // Simulate network latency so the loading state in the ViewModel
    // has something real to show.
    await Future.delayed(const Duration(milliseconds: 700));

    if (username.trim() == _hardcodedUsername && password == _hardcodedPassword) {
      return _hardcodedUser;
    }
    throw AuthException('Invalid username or password.');
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}
