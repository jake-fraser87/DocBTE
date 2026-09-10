import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_decorations.dart';
import '../models/request_model.dart';
import '../widgets/request_card.dart';
import 'shell_screen.dart';

// ============================================================================
// SERVICE — TEMPORARY MOCK IMPLEMENTATION. Swap the body of
// fetchRequests() for a real HTTP call once the backend is available;
// the ViewModel only depends on this method's signature.
// ============================================================================

class RequestsService {
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
    return all.where((r) => r.reqId.toLowerCase().contains(query.toLowerCase())).toList();
  }
}

// ============================================================================
// VIEWMODEL
// ============================================================================

enum RequestsLoadStatus { idle, loading, loaded, error }

class RequestsViewModel extends ChangeNotifier {
  RequestsViewModel(this._service) {
    loadRequests();
  }

  final RequestsService _service;

  RequestsLoadStatus status = RequestsLoadStatus.idle;
  List<RequestModel> requests = [];
  String searchQuery = '';

  Future<void> loadRequests() async {
    status = RequestsLoadStatus.loading;
    notifyListeners();
    try {
      requests = await _service.fetchRequests(query: searchQuery);
      status = RequestsLoadStatus.loaded;
    } catch (_) {
      status = RequestsLoadStatus.error;
    }
    notifyListeners();
  }

  void onSearchChanged(String value) {
    searchQuery = value;
    loadRequests();
  }
}

// ============================================================================
// VIEW
// ============================================================================

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RequestsViewModel(RequestsService()),
      child: const _RequestsView(),
    );
  }
}

class _RequestsView extends StatelessWidget {
  const _RequestsView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RequestsViewModel>();
    final user = context.read<MainShellViewModel>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 22),
            decoration: AppDecorations.headerGradient,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Welcome ${user.displayName.split(' ').first}', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Colors.white)),
                    const CircleAvatar(radius: 17, backgroundColor: Colors.white, child: Icon(Icons.person, color: AppColors.orangeDark, size: 18)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: vm.onSearchChanged,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search by Request ID...',
                          hintStyle: const TextStyle(color: Colors.white70, fontSize: 13),
                          prefixIcon: const Icon(Icons.search, color: Colors.white70, size: 18),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.16),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.35)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.filter_alt_outlined, size: 16, color: AppColors.orangeDark),
                      label: const Text('Filter', style: TextStyle(color: AppColors.orangeDark, fontWeight: FontWeight.w700, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: const Size(0, 46),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: vm.status == RequestsLoadStatus.loading && vm.requests.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : vm.status == RequestsLoadStatus.error
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cloud_off_rounded, size: 40, color: AppColors.inkSoft),
                            const SizedBox(height: 10),
                            const Text('Could not load requests.', style: TextStyle(color: AppColors.inkSoft)),
                            const SizedBox(height: 10),
                            OutlinedButton(onPressed: vm.loadRequests, child: const Text('Retry')),
                          ],
                        ),
                      )
                    : vm.requests.isEmpty
                        ? const Center(
                            child: Text('No requests match your search.', style: TextStyle(color: AppColors.inkSoft)),
                          )
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                            children: [
                              const Text('Application Requests', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink)),
                              const SizedBox(height: 14),
                              for (final r in vm.requests) RequestCard(request: r),
                            ],
                          ),
          ),
        ],
      ),
    );
  }
}
