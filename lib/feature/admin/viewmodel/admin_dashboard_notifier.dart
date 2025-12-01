import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_project/feature/admin/viewmodel/admin_dashboard_state.dart';
import 'package:library_project/service/admin_service.dart';
import 'package:postgrest/postgrest.dart';

class AdminDashboardNotifier extends StateNotifier<AdminDashboardState> {
  AdminDashboardNotifier() : super(AdminDashboardInitial()) {
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    state = AdminDashboardLoading();
    try {
      final data = await AdminService.fetchDashboardData();
      state = AdminDashboardLoaded(data);
    } catch (error) {
      state = AdminDashboardError(_mapError(error));
    }
  }

  Future<void> refreshDashboard() async {
    await loadDashboard();
  }

  String _mapError(Object error) {
    if (error is PostgrestException) {
      return error.message;
    }
    return 'Failed to load admin data. Please try again.';
  }
}

final adminDashboardProvider =
    StateNotifierProvider<AdminDashboardNotifier, AdminDashboardState>(
  (ref) => AdminDashboardNotifier(),
);

