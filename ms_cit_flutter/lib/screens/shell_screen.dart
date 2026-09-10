import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import 'home_screen.dart';
import 'reports_screen.dart';
import 'requests_screen.dart';
import 'settings_screen.dart';

// ============================================================================
// VIEWMODEL — just tracks which tab is active and who's logged in. No
// service of its own: it doesn't fetch anything, it only coordinates.
// ============================================================================

class MainShellViewModel extends ChangeNotifier {
  MainShellViewModel(this.currentUser);

  final UserModel currentUser;
  int selectedIndex = 0;

  static const List<String> tabLabels = [
    'Home',
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

// ============================================================================
// VIEW — hosts the bottom nav and lazily provides each tab's own
// ViewModel (each of which owns its own Service). Each tab screen only
// ever talks to its own ViewModel — this is the only place that knows
// about all four.
// ============================================================================

class MainShellScreen extends StatelessWidget {
  final UserModel user;
  const MainShellScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MainShellViewModel(user),
      child: Consumer<MainShellViewModel>(
        builder: (context, shellVm, _) {
          return Scaffold(
            body: IndexedStack(
              index: shellVm.selectedIndex,
              children: const [
                HomeScreen(),
                RequestsScreen(),
                ReportsScreen(),
                SettingsScreen(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: shellVm.selectedIndex,
              onTap: shellVm.selectTab,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.description_outlined), activeIcon: Icon(Icons.description), label: 'Requests'),
                BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Reports'),
                BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
              ],
            ),
          );
        },
      ),
    );
  }
}
