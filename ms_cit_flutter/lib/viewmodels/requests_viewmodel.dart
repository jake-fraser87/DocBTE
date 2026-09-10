import 'package:flutter/foundation.dart';
import '../models/request_model.dart';
import '../services/data_service.dart';
import 'dashboard_viewmodel.dart' show LoadStatus;

class RequestsViewModel extends ChangeNotifier {
  RequestsViewModel(this._dataService) {
    loadRequests();
  }

  final DataService _dataService;

  LoadStatus status = LoadStatus.idle;
  List<RequestModel> requests = [];
  String searchQuery = '';

  Future<void> loadRequests() async {
    status = LoadStatus.loading;
    notifyListeners();
    try {
      requests = await _dataService.fetchRequests(query: searchQuery);
      status = LoadStatus.loaded;
    } catch (_) {
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  void onSearchChanged(String value) {
    searchQuery = value;
    loadRequests();
  }
}
