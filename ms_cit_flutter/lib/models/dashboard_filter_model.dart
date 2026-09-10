/// Preset choices for the Home screen's date-range dropdown.
/// [custom] is selected automatically the moment the user picks a
/// from/to date by hand via the date pickers.
enum DateRangePreset { today, last7Days, last15Days, last30Days, thisMonth, custom }

extension DateRangePresetX on DateRangePreset {
  String get label {
    switch (this) {
      case DateRangePreset.today:
        return 'Today';
      case DateRangePreset.last7Days:
        return 'Last 7 Days';
      case DateRangePreset.last15Days:
        return 'Last 15 Days';
      case DateRangePreset.last30Days:
        return 'Last 30 Days';
      case DateRangePreset.thisMonth:
        return 'This Month';
      case DateRangePreset.custom:
        return 'Custom Range';
    }
  }
}

/// The Home screen's current selection: which date-range preset is
/// active, plus the concrete from/to dates it resolves to. This is a
/// plain value object (the "M" for the Home screen's own selection
/// state) — no Flutter widget code, no business logic beyond deriving
/// dates from a preset.
class DashboardFilter {
  final DateRangePreset preset;
  final DateTime fromDate;
  final DateTime toDate;

  const DashboardFilter({
    required this.preset,
    required this.fromDate,
    required this.toDate,
  });

  DashboardFilter copyWith({
    DateRangePreset? preset,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return DashboardFilter(
      preset: preset ?? this.preset,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Resolves a preset into concrete from/to dates. Picking [custom]
  /// this way just seeds it with the last-15-days range — the caller
  /// is expected to overwrite it with real picker input right after.
  factory DashboardFilter.fromPreset(DateRangePreset preset) {
    final today = _today();
    switch (preset) {
      case DateRangePreset.today:
        return DashboardFilter(preset: preset, fromDate: today, toDate: today);
      case DateRangePreset.last7Days:
        return DashboardFilter(
          preset: preset,
          fromDate: today.subtract(const Duration(days: 6)),
          toDate: today,
        );
      case DateRangePreset.last15Days:
        return DashboardFilter(
          preset: preset,
          fromDate: today.subtract(const Duration(days: 14)),
          toDate: today,
        );
      case DateRangePreset.last30Days:
        return DashboardFilter(
          preset: preset,
          fromDate: today.subtract(const Duration(days: 29)),
          toDate: today,
        );
      case DateRangePreset.thisMonth:
        return DashboardFilter(
          preset: preset,
          fromDate: DateTime(today.year, today.month, 1),
          toDate: today,
        );
      case DateRangePreset.custom:
        return DashboardFilter(
          preset: preset,
          fromDate: today.subtract(const Duration(days: 14)),
          toDate: today,
        );
    }
  }

  static const List<DateRangePreset> presets = DateRangePreset.values;
}
