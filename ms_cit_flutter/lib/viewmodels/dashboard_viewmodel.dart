import 'package:flutter/foundation.dart';
import '../models/dashboard_stats_model.dart';
import '../services/data_service.dart';

enum LoadStatus { idle, loading, loaded, error }

class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel(this._dataService) {
    loadStats();
  }

  final DataService _dataService;

  LoadStatus status = LoadStatus.idle;
  DashboardStatsModel? stats;
  String dateRangeLabel = 'Last 15 Days';
  String fromDate = '08/27/2026';
  String toDate = '09/10/2026';

  Future<void> loadStats() async {
    status = LoadStatus.loading;
    notifyListeners();
    try {
      stats = await _dataService.fetchDashboardStats();
      status = LoadStatus.loaded;
    } catch (_) {
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> refresh() => loadStats();
}
