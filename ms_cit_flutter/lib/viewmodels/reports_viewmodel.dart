import 'package:flutter/foundation.dart';
import '../models/report_model.dart';
import '../services/data_service.dart';
import 'dashboard_viewmodel.dart' show LoadStatus;

class ReportsViewModel extends ChangeNotifier {
  ReportsViewModel(this._dataService) {
    loadReports();
  }

  final DataService _dataService;

  LoadStatus status = LoadStatus.idle;
  List<CorporationVolume> corporationVolumes = [];
  TurnaroundStats? turnaround;

  Future<void> loadReports() async {
    status = LoadStatus.loading;
    notifyListeners();
    try {
      final results = await Future.wait([
        _dataService.fetchCorporationVolumes(),
        _dataService.fetchTurnaroundStats(),
      ]);
      corporationVolumes = results[0] as List<CorporationVolume>;
      turnaround = results[1] as TurnaroundStats;
      status = LoadStatus.loaded;
    } catch (_) {
      status = LoadStatus.error;
    }
    notifyListeners();
  }
}
