import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../viewmodels/main_shell_viewmodel.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final user = context.read<MainShellViewModel>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        toolbarHeight: 84,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('MS-CIT', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.orangeDark)),
                Text('Certificate Verification', style: TextStyle(fontSize: 11, color: AppColors.inkSoft)),
              ],
            ),
            Row(
              children: [
                _circleIcon(Icons.search),
                const SizedBox(width: 8),
                _circleIcon(Icons.notifications_none_rounded),
                const SizedBox(width: 10),
                const CircleAvatar(radius: 17, backgroundColor: AppColors.orangeSoft, child: Icon(Icons.person, color: AppColors.orangeDark, size: 18)),
              ],
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: vm.refresh,
        child: vm.status == LoadStatus.loading && vm.stats == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Certificate Verification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink)),
                      Text(
                        'Welcome, ${user.displayName.split(' ').first}!',
                        style: const TextStyle(fontSize: 11, color: AppColors.inkSoft, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.line),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _fakeSelect(vm.dateRangeLabel),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: _fakeDate(vm.fromDate)),
                            const SizedBox(width: 10),
                            Expanded(child: _fakeDate(vm.toDate)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (vm.stats != null) ...[
                    StatCard(
                      label: 'TOTAL REQUESTS',
                      value: vm.stats!.totalRequests,
                      accent: AppColors.blue,
                      accentSoft: AppColors.blueSoft,
                      icon: Icons.description_outlined,
                    ),
                    StatCard(
                      label: 'PENDING',
                      value: vm.stats!.pending.total,
                      split: vm.stats!.pending,
                      accent: AppColors.amber,
                      accentSoft: AppColors.amberSoft,
                      icon: Icons.access_time_rounded,
                    ),
                    StatCard(
                      label: 'APPROVED',
                      value: vm.stats!.approved.total,
                      split: vm.stats!.approved,
                      accent: AppColors.green,
                      accentSoft: AppColors.greenSoft,
                      icon: Icons.check_circle_outline,
                    ),
                    StatCard(
                      label: 'REJECTED',
                      value: vm.stats!.rejected.total,
                      split: vm.stats!.rejected,
                      accent: AppColors.red,
                      accentSoft: AppColors.redSoft,
                      icon: Icons.close_rounded,
                    ),
                    StatCard(
                      label: 'PARTIALLY APPROVED',
                      value: vm.stats!.partiallyApproved.total,
                      split: vm.stats!.partiallyApproved,
                      accent: AppColors.teal,
                      accentSoft: AppColors.tealSoft,
                      icon: Icons.hourglass_bottom_rounded,
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  static Widget _circleIcon(IconData icon) => CircleAvatar(
        radius: 17,
        backgroundColor: AppColors.orangeSoft,
        child: Icon(icon, size: 17, color: AppColors.orangeDark),
      );

  static Widget _fakeSelect(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: AppColors.ink)),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.inkSoft),
          ],
        ),
      );

  static Widget _fakeDate(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.ink)),
            const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.inkSoft),
          ],
        ),
      );
}
