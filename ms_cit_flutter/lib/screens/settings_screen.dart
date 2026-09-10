import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_decorations.dart';
import '../models/user_model.dart';
import 'login_screen.dart';
import 'shell_screen.dart';

// ============================================================================
// SERVICE — Settings screen's own data source for account actions.
// TEMPORARY MOCK IMPLEMENTATION: logout() just simulates latency today;
// swap it for a real "invalidate session" API call later.
// ============================================================================

class SettingsService {
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}

// ============================================================================
// VIEWMODEL
// ============================================================================

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel(this._service, this.currentUser);

  final SettingsService _service;
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
    await _service.logout();
    isLoggingOut = false;
    notifyListeners();
    onComplete();
  }
}

// ============================================================================
// VIEW
// ============================================================================

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<MainShellViewModel>().currentUser;
    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel(SettingsService(), user),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    final user = vm.currentUser;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppDecorations.card(),
            child: Row(
              children: [
                const CircleAvatar(radius: 27, backgroundColor: AppColors.orangeSoft, child: Icon(Icons.person, color: AppColors.orangeDark, size: 26)),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.displayName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ink)),
                    const SizedBox(height: 2),
                    Text('${user.role} · ${user.zone}', style: const TextStyle(fontSize: 12, color: AppColors.inkSoft)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _group([
            _switchRow(
              icon: Icons.notifications_none_rounded,
              iconColor: AppColors.amber,
              iconBg: AppColors.amberSoft,
              label: 'Push notifications',
              value: vm.pushNotifications,
              onChanged: vm.togglePushNotifications,
            ),
            _switchRow(
              icon: Icons.refresh_rounded,
              iconColor: AppColors.blue,
              iconBg: AppColors.blueSoft,
              label: 'Auto-refresh dashboard',
              value: vm.autoRefreshDashboard,
              onChanged: vm.toggleAutoRefresh,
            ),
            _navRow(
              icon: Icons.schedule_rounded,
              iconColor: AppColors.teal,
              iconBg: AppColors.tealSoft,
              label: 'Default range: Last 15 Days',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 18),
          _group([
            _navRow(
              icon: Icons.lock_reset_rounded,
              iconColor: AppColors.orangeDark,
              iconBg: AppColors.orangeSoft,
              label: 'Change password',
              onTap: () {},
            ),
            _navRow(
              icon: Icons.logout_rounded,
              iconColor: AppColors.red,
              iconBg: AppColors.redSoft,
              label: vm.isLoggingOut ? 'Logging out…' : 'Log out',
              onTap: vm.isLoggingOut
                  ? null
                  : () => vm.logout(() {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      }),
              showChevron: false,
            ),
          ]),
        ],
      ),
    );
  }

  static Widget _group(List<Widget> children) {
    return Container(
      decoration: AppDecorations.card(),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  static Widget _rowIcon(IconData icon, Color color, Color bg) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(9)),
      child: Icon(icon, size: 16, color: color),
    );
  }

  static Widget _switchRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.line))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            _rowIcon(icon, iconColor, iconBg),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.ink)),
          ]),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.orange),
        ],
      ),
    );
  }

  static Widget _navRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    VoidCallback? onTap,
    bool showChevron = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.line))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              _rowIcon(icon, iconColor, iconBg),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.ink)),
            ]),
            if (showChevron) const Icon(Icons.chevron_right_rounded, color: AppColors.inkSoft),
          ],
        ),
      ),
    );
  }
}
