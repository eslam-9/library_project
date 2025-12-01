import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_project/feature/member/viewmodel/member_dashboard_state.dart';
import 'package:library_project/service/member_service.dart';

class MemberDashboardNotifier extends StateNotifier<MemberDashboardState> {
  MemberDashboardNotifier() : super(MemberDashboardInitial()) {
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    state = MemberDashboardLoading();
    try {
      final data = await MemberService.fetchDashboardData();
      state = MemberDashboardLoaded(data);
    } catch (error) {
      state = MemberDashboardError(_mapError(error));
    }
  }

  Future<void> refreshDashboard() async {
    await loadDashboard();
  }

  String _mapError(Object error) {
    return 'Failed to load your library data. Please try again.';
  }
}

final memberDashboardProvider =
    StateNotifierProvider<MemberDashboardNotifier, MemberDashboardState>(
      (ref) => MemberDashboardNotifier(),
    );
