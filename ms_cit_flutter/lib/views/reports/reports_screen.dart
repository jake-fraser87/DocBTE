import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/dashboard_viewmodel.dart' show LoadStatus;
import '../../viewmodels/reports_viewmodel.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReportsViewModel>();

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text('Verification Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink)),
      ),
      body: vm.status == LoadStatus.loading && vm.turnaround == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
              children: [
                _reportCard(
                  title: 'This Week — Requests by Corporation',
                  trailing: '▲ 12%',
                  trailingColor: AppColors.green,
                  child: Column(
                    children: [
                      for (final v in vm.corporationVolumes)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              SizedBox(width: 52, child: Text(v.corporationCode, style: const TextStyle(fontSize: 11, color: AppColors.inkSoft, fontWeight: FontWeight.w600))),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: v.ratio,
                                    minHeight: 9,
                                    backgroundColor: AppColors.orangeSoft,
                                    valueColor: const AlwaysStoppedAnimation(AppColors.orange),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(width: 26, child: Text('${v.count}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.ink))),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (vm.turnaround != null)
                  _reportCard(
                    title: 'Turnaround Time',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _metric('${vm.turnaround!.avgDays}', 'avg days', AppColors.ink),
                        _metric('${vm.turnaround!.slaPercent}%', 'within SLA', AppColors.green),
                        _metric('${vm.turnaround!.closedToday}', 'closed today', AppColors.ink),
                      ],
                    ),
                  ),
                _reportCard(
                  title: 'Export',
                  child: Row(
                    children: [
                      Expanded(child: _exportButton('Download CSV')),
                      const SizedBox(width: 10),
                      Expanded(child: _exportButton('Download PDF')),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  static Widget _reportCard({required String title, String? trailing, Color? trailingColor, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.ink)),
              if (trailing != null) Text(trailing, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: trailingColor)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  static Widget _metric(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.inkSoft, fontWeight: FontWeight.w600)),
      ],
    );
  }

  static Widget _exportButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: AppColors.paper, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.orangeDark)),
    );
  }
}
