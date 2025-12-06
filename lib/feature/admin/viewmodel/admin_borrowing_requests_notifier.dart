import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_project/feature/admin/viewmodel/admin_borrowing_requests_state.dart';
import 'package:library_project/service/admin_service.dart';
import 'package:postgrest/postgrest.dart';

class AdminBorrowingRequestsNotifier
    extends StateNotifier<AdminBorrowingRequestsState> {
  AdminBorrowingRequestsNotifier() : super(AdminBorrowingRequestsInitial()) {
    loadRequests();
  }

  Future<void> loadRequests() async {
    state = AdminBorrowingRequestsLoading();
    try {
      final requests = await AdminService.fetchPendingBorrowingRequests();
      state = AdminBorrowingRequestsLoaded(requests);
    } catch (error) {
      state = AdminBorrowingRequestsError(_mapError(error));
    }
  }

  Future<void> approveRequest(int borrowingId) async {
    try {
      await AdminService.approveBorrowingRequest(borrowingId);
      // Reload requests after approval
      await loadRequests();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> declineRequest(int borrowingId) async {
    try {
      await AdminService.declineBorrowingRequest(borrowingId);
      // Reload requests after declining
      await loadRequests();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> refreshRequests() async {
    await loadRequests();
  }

  String _mapError(Object error) {
    if (error is PostgrestException) {
      return error.message;
    }
    return 'Failed to load borrowing requests. Please try again.';
  }
}

final adminBorrowingRequestsProvider =
    StateNotifierProvider<
      AdminBorrowingRequestsNotifier,
      AdminBorrowingRequestsState
    >((ref) => AdminBorrowingRequestsNotifier());
