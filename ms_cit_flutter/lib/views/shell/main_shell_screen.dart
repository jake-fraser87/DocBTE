import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../viewmodels/main_shell_viewmodel.dart';
import '../../viewmodels/reports_viewmodel.dart';
import '../../viewmodels/requests_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../dashboard/dashboard_screen.dart';
import '../reports/reports_screen.dart';
import '../requests/requests_screen.dart';
import '../settings/settings_screen.dart';

/// Hosts the bottom nav and lazily provides each tab's ViewModel.
/// Each screen only ever talks to its own ViewModel — this is the only
/// place that knows about all four.
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
              children: [
                ChangeNotifierProvider(
                  create: (_) => DashboardViewModel(DataService()),
                  child: const DashboardScreen(),
                ),
                ChangeNotifierProvider(
                  create: (_) => RequestsViewModel(DataService()),
                  child: const RequestsScreen(),
                ),
                ChangeNotifierProvider(
                  create: (_) => ReportsViewModel(DataService()),
                  child: const ReportsScreen(),
                ),
                ChangeNotifierProvider(
                  create: (_) => SettingsViewModel(AuthService(), user),
                  child: const SettingsScreen(),
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: shellVm.selectedIndex,
              onTap: shellVm.selectTab,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
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
