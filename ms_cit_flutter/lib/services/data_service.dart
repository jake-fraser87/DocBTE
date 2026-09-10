import '../models/dashboard_stats_model.dart';
import '../models/report_model.dart';
import '../models/request_model.dart';

/// Stands in for a future REST/GraphQL client. ViewModels only depend on
/// this interface's method signatures, so swapping mock data for a real
/// API later is a one-file change.
class DataService {
  Future<DashboardStatsModel> fetchDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const DashboardStatsModel(
      totalRequests: 0,
      pending: DeskSplit(deskOne: 8, deskTwo: 0),
      approved: DeskSplit(deskOne: 0, deskTwo: 12),
      rejected: DeskSplit(deskOne: 0, deskTwo: 0),
      partiallyApproved: DeskSplit(deskOne: 2, deskTwo: 1),
    );
  }

  Future<List<RequestModel>> fetchRequests({String query = ''}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final all = [
      RequestModel(
        srNo: 1,
        reqId: '2101001001',
        status: RequestStatus.pending,
        corporation: 'Pimpri-Chinchwad Municipal Corporation',
        date: DateTime(2026, 9, 8, 10, 25, 36),
        deskOneCount: 8,
        deskTwoCount: 0,
      ),
      RequestModel(
        srNo: 2,
        reqId: '2101001002',
        status: RequestStatus.pending,
        corporation: 'Pimpri-Chinchwad Municipal Corporation',
        date: DateTime(2026, 9, 8, 17, 30, 49),
        deskOneCount: 8,
        deskTwoCount: 0,
      ),
      RequestModel(
        srNo: 3,
        reqId: '2101001003',
        status: RequestStatus.pending,
        corporation: 'Pimpri-Chinchwad Municipal Corporation',
        date: DateTime(2026, 9, 9, 10, 11, 16),
        deskOneCount: 8,
        deskTwoCount: 0,
      ),
      RequestModel(
        srNo: 4,
        reqId: '2101001004',
        status: RequestStatus.approved,
        corporation: 'Pimpri-Chinchwad Municipal Corporation',
        date: DateTime(2026, 9, 9, 14, 2, 10),
        deskOneCount: 0,
        deskTwoCount: 12,
      ),
    ];

    if (query.trim().isEmpty) return all;
    return all
        .where((r) => r.reqId.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

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
