import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_decorations.dart';
import '../models/report_model.dart';

// ============================================================================
// SERVICE — TEMPORARY MOCK IMPLEMENTATION. Swap these method bodies for
// real HTTP calls once the backend is available.
// ============================================================================

class ReportsService {
  Future<List<CorporationVolume>> fetchCorporationVolumes() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const [
      CorporationVolume(corporationCode: 'PCMC', count: 18, maxScaleCount: 18),
      CorporationVolume(corporationCode: 'PMC', count: 12, maxScaleCount: 18),
      CorporationVolume(corporationCode: 'NMC', count: 8, maxScaleCount: 18),
      CorporationVolume(corporationCode: 'KDMC', count: 4, maxScaleCount: 18),
    ];
  }

  Future<TurnaroundStats> fetchTurnaroundStats() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const TurnaroundStats(avgDays: 1.4, slaPercent: 94, closedToday: 42);
  }
}

// ============================================================================
// VIEWMODEL
// ============================================================================

enum ReportsLoadStatus { idle, loading, loaded, error }

class ReportsViewModel extends ChangeNotifier {
  ReportsViewModel(this._service) {
    loadReports();
  }

  final ReportsService _service;

  ReportsLoadStatus status = ReportsLoadStatus.idle;
  List<CorporationVolume> corporationVolumes = [];
  TurnaroundStats? turnaround;

  Future<void> loadReports() async {
    status = ReportsLoadStatus.loading;
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.fetchCorporationVolumes(),
        _service.fetchTurnaroundStats(),
      ]);
      corporationVolumes = results[0] as List<CorporationVolume>;
      turnaround = results[1] as TurnaroundStats;
      status = ReportsLoadStatus.loaded;
    } catch (_) {
      status = ReportsLoadStatus.error;
    }
    notifyListeners();
  }
}

// ============================================================================
// VIEW
// ============================================================================

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportsViewModel(ReportsService()),
      child: const _ReportsView(),
    );
  }
}

class _ReportsView extends StatelessWidget {
  const _ReportsView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReportsViewModel>();

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text('Verification Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink)),
      ),
      body: vm.status == ReportsLoadStatus.loading && vm.turnaround == null
          ? const Center(child: CircularProgressIndicator())
          : vm.status == ReportsLoadStatus.error && vm.turnaround == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_rounded, size: 40, color: AppColors.inkSoft),
                      const SizedBox(height: 10),
                      const Text('Could not load reports.', style: TextStyle(color: AppColors.inkSoft)),
                      const SizedBox(height: 10),
                      OutlinedButton(onPressed: vm.loadReports, child: const Text('Retry')),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
                  children: [
                    _reportCard(
                      title: 'This Week — Requests by Corporation',
                      trailing: '▲ 12%',
                      trailingColor: AppColors.green,
                      child: Column(
                        children: [
                          for (final v in vm.corporationVolumes)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
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
      decoration: AppDecorations.card(),
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
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.inkSoft, fontWeight: FontWeight.w600)),
      ],
    );
  }

  static Widget _exportButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: AppColors.paper, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.orangeDark)),
    );
  }
}
