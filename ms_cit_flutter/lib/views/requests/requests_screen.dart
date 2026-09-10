import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/dashboard_viewmodel.dart' show LoadStatus;
import '../../viewmodels/main_shell_viewmodel.dart';
import '../../viewmodels/requests_viewmodel.dart';
import '../widgets/request_card.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RequestsViewModel>();
    final user = context.read<MainShellViewModel>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.orange, AppColors.orangeDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(22), bottomRight: Radius.circular(22)),
            ),
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
                const SizedBox(height: 14),
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
            child: vm.status == LoadStatus.loading && vm.requests.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : vm.requests.isEmpty
                    ? const Center(
                        child: Text('No requests match your search.', style: TextStyle(color: AppColors.inkSoft)),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                        children: [
                          const Text('Application Requests', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink)),
                          const SizedBox(height: 12),
                          for (final r in vm.requests) RequestCard(request: r),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
