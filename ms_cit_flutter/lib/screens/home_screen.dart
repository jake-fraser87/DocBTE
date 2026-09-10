import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_decorations.dart';
import '../models/dashboard_filter_model.dart';
import '../models/dashboard_stats_model.dart';
import '../widgets/stat_card.dart';
import 'shell_screen.dart';

// ============================================================================
// SERVICE — Home screen's own data source.
//
// TEMPORARY MOCK IMPLEMENTATION: the backend endpoint for dashboard
// stats isn't available yet, so fetchDashboardStats() below returns
// generated data derived from the selected filter instead of leaving
// the UI blank. The method's signature (a DashboardFilter in, a
// DashboardStatsModel out) is the real contract the ViewModel depends
// on, so swapping this body for a real HTTP call later needs no
// changes anywhere else.
// ============================================================================

class HomeService {
  Future<DashboardStatsModel> fetchDashboardStats(DashboardFilter filter) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // Scale the mock numbers by the selected date range so the cards
    // visibly change when the user changes the selection/date above —
    // this also stands in for "the dashboard depends on the filter".
    final daySpan = filter.toDate.difference(filter.fromDate).inDays.abs() + 1;

    final pending = DeskSplit(deskOne: 3 + daySpan, deskTwo: (daySpan / 3).floor());
    final approved = DeskSplit(deskOne: (daySpan / 2).floor(), deskTwo: 4 + daySpan);
    final rejected = DeskSplit(deskOne: (daySpan / 5).floor(), deskTwo: (daySpan / 6).floor());
    final partiallyApproved = DeskSplit(deskOne: 1 + (daySpan / 4).floor(), deskTwo: (daySpan / 7).floor());

    return DashboardStatsModel(
      // BUG FIX: this used to be hardcoded to 0 regardless of the
      // splits below, which is exactly why the "TOTAL REQUESTS" card
      // always rendered blank/zero. It must be derived from the
      // actual per-status counts instead.
      totalRequests: pending.total + approved.total + rejected.total + partiallyApproved.total,
      pending: pending,
      approved: approved,
      rejected: rejected,
      partiallyApproved: partiallyApproved,
    );
  }
}

// ============================================================================
// VIEWMODEL
// ============================================================================

enum HomeLoadStatus { idle, loading, loaded, error }

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._service) : filter = DashboardFilter.fromPreset(DateRangePreset.last15Days) {
    loadStats();
  }

  final HomeService _service;

  HomeLoadStatus status = HomeLoadStatus.idle;
  DashboardStatsModel? stats;
  String? errorMessage;
  DashboardFilter filter;

  Future<void> loadStats() async {
    status = HomeLoadStatus.loading;
    notifyListeners();
    try {
      stats = await _service.fetchDashboardStats(filter);
      status = HomeLoadStatus.loaded;
      errorMessage = null;
    } catch (_) {
      status = HomeLoadStatus.error;
      errorMessage = 'Could not load dashboard data.';
    }
    notifyListeners();
  }

  Future<void> refresh() => loadStats();

  /// Called from the dropdown. Switching to a preset other than
  /// [DateRangePreset.custom] recomputes both dates automatically;
  /// switching to Custom just marks the mode without moving the dates.
  void selectPreset(DateRangePreset preset) {
    if (preset == filter.preset) return;
    filter = preset == DateRangePreset.custom
        ? filter.copyWith(preset: preset)
        : DashboardFilter.fromPreset(preset);
    loadStats();
  }

  /// Called from the date pickers. Picking a date by hand always moves
  /// the selection into Custom Range mode, even if a preset was active.
  void setCustomRange({DateTime? from, DateTime? to}) {
    filter = filter.copyWith(
      preset: DateRangePreset.custom,
      fromDate: from ?? filter.fromDate,
      toDate: to ?? filter.toDate,
    );
    loadStats();
  }
}

// ============================================================================
// VIEW
// ============================================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(HomeService()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  static final DateFormat _dateFmt = DateFormat('dd MMM yyyy');

  Future<void> _pickDate(BuildContext context, HomeViewModel vm, {required bool isFrom}) async {
    final initial = isFrom ? vm.filter.fromDate : vm.filter.toDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    if (isFrom) {
      vm.setCustomRange(from: picked);
    } else {
      vm.setCustomRange(to: picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final user = context.read<MainShellViewModel>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        toolbarHeight: 84,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
        child: _buildBody(context, vm, user.displayName),
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeViewModel vm, String displayName) {
    if (vm.status == HomeLoadStatus.loading && vm.stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.status == HomeLoadStatus.error && vm.stats == null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.cloud_off_rounded, size: 44, color: AppColors.inkSoft),
          const SizedBox(height: 14),
          Text(
            vm.errorMessage ?? 'Something went wrong.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.inkSoft, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              onPressed: vm.loadStats,
              child: const Text('Retry'),
            ),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Subtract the ListView's own horizontal padding (18 each side)
        // to get the width actually available to the cards.
        final contentWidth = constraints.maxWidth - 36;
        final columns = contentWidth > 720 ? 3 : (contentWidth > 460 ? 2 : 1);

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Certificate Verification', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.ink)),
                Row(
                  children: [
                    if (vm.status == HomeLoadStatus.loading)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: SizedBox(
                          width: 13,
                          height: 13,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.orange),
                        ),
                      ),
                    Text(
                      'Welcome, ${displayName.split(' ').first}!',
                      style: const TextStyle(fontSize: 11, color: AppColors.inkSoft, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _FilterCard(vm: vm, dateFmt: _dateFmt, onPickDate: (isFrom) => _pickDate(context, vm, isFrom: isFrom)),
            const SizedBox(height: 18),
            if (vm.stats != null) _StatGrid(stats: vm.stats!, columns: columns, maxWidth: contentWidth),
          ],
        );
      },
    );
  }

  static Widget _circleIcon(IconData icon) => CircleAvatar(
        radius: 17,
        backgroundColor: AppColors.orangeSoft,
        child: Icon(icon, size: 17, color: AppColors.orangeDark),
      );
}

/// The selection controls: a real dropdown for the date-range preset,
/// plus two real date pickers for the from/to dates. Replaces the old
/// non-interactive placeholder boxes.
class _FilterCard extends StatelessWidget {
  final HomeViewModel vm;
  final DateFormat dateFmt;
  final void Function(bool isFrom) onPickDate;

  const _FilterCard({required this.vm, required this.dateFmt, required this.onPickDate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DATE RANGE', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.inkSoft, letterSpacing: 0.4)),
          const SizedBox(height: 8),
          DropdownButtonFormField<DateRangePreset>(
            value: vm.filter.preset,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.inkSoft),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: DashboardFilter.presets
                .map((p) => DropdownMenuItem(value: p, child: Text(p.label, style: const TextStyle(fontSize: 13.5))))
                .toList(),
            onChanged: (preset) {
              if (preset != null) vm.selectPreset(preset);
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _DateField(
                  label: 'From',
                  date: vm.filter.fromDate,
                  dateFmt: dateFmt,
                  onTap: () => onPickDate(true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateField(
                  label: 'To',
                  date: vm.filter.toDate,
                  dateFmt: dateFmt,
                  onTap: () => onPickDate(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final DateFormat dateFmt;
  final VoidCallback onTap;

  const _DateField({required this.label, required this.date, required this.dateFmt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.inkSoft, letterSpacing: 0.3)),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateFmt.format(date), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.ink)),
                const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.inkSoft),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Responsive grid of dashboard cards — 1 column on narrow phones, up
/// to 3 on wide/tablet layouts, instead of a fixed-width layout.
class _StatGrid extends StatelessWidget {
  final DashboardStatsModel stats;
  final int columns;
  final double maxWidth;

  const _StatGrid({required this.stats, required this.columns, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final cards = [
      StatCard(
        label: 'TOTAL REQUESTS',
        value: stats.totalRequests,
        accent: AppColors.blue,
        accentSoft: AppColors.blueSoft,
        icon: Icons.description_outlined,
      ),
      StatCard(
        label: 'PENDING',
        value: stats.pending.total,
        split: stats.pending,
        accent: AppColors.amber,
        accentSoft: AppColors.amberSoft,
        icon: Icons.access_time_rounded,
      ),
      StatCard(
        label: 'APPROVED',
        value: stats.approved.total,
        split: stats.approved,
        accent: AppColors.green,
        accentSoft: AppColors.greenSoft,
        icon: Icons.check_circle_outline,
      ),
      StatCard(
        label: 'REJECTED',
        value: stats.rejected.total,
        split: stats.rejected,
        accent: AppColors.red,
        accentSoft: AppColors.redSoft,
        icon: Icons.close_rounded,
      ),
      StatCard(
        label: 'PARTIALLY APPROVED',
        value: stats.partiallyApproved.total,
        split: stats.partiallyApproved,
        accent: AppColors.teal,
        accentSoft: AppColors.tealSoft,
        icon: Icons.hourglass_bottom_rounded,
      ),
    ];

    if (columns == 1) {
      return Column(
        children: [for (final c in cards) Padding(padding: const EdgeInsets.only(bottom: 12), child: c)],
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final c in cards)
          SizedBox(
            width: (maxWidth - (columns - 1) * 12) / columns,
            child: c,
          ),
      ],
    );
  }
}
