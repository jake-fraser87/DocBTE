import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel(this._authService, this.currentUser);

  final AuthService _authService;
  final UserModel currentUser;

  bool pushNotifications = true;
  bool autoRefreshDashboard = false;
  bool isLoggingOut = false;

  void togglePushNotifications(bool value) {
    pushNotifications = value;
    notifyListeners();
  }

  void toggleAutoRefresh(bool value) {
    autoRefreshDashboard = value;
    notifyListeners();
  }

  Future<void> logout(VoidCallback onComplete) async {
    isLoggingOut = true;
    notifyListeners();
    await _authService.logout();
    isLoggingOut = false;
    notifyListeners();
    onComplete();
  }
}
