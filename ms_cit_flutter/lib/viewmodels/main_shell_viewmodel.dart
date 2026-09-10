import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class MainShellViewModel extends ChangeNotifier {
  MainShellViewModel(this.currentUser);

  final UserModel currentUser;
  int selectedIndex = 0;

  static const List<String> tabLabels = [
    'Dashboard',
    'Requests',
    'Reports',
    'Settings',
  ];

  void selectTab(int index) {
    if (index == selectedIndex) return;
    selectedIndex = index;
    notifyListeners();
  }
}
