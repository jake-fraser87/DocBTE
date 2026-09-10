import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum LoginStatus { idle, loading, success, error }

/// The "VM" in MVVM. Holds all state the LoginScreen needs to render,
/// and exposes intents (login()) the View can call. No Flutter widget
/// code lives here — this class is trivially unit-testable.
class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._authService);

  final AuthService _authService;

  LoginStatus status = LoginStatus.idle;
  String? errorMessage;
  bool obscurePassword = true;
  UserModel? loggedInUser;

  bool get isLoading => status == LoginStatus.loading;

  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    if (username.trim().isEmpty || password.isEmpty) {
      status = LoginStatus.error;
      errorMessage = 'Enter both username and password.';
      notifyListeners();
      return false;
    }

    status = LoginStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.login(username, password);
      loggedInUser = user;
      status = LoginStatus.success;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      status = LoginStatus.error;
      errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      status = LoginStatus.error;
      errorMessage = 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    }
  }

  void reset() {
    status = LoginStatus.idle;
    errorMessage = null;
    loggedInUser = null;
    notifyListeners();
  }
}
