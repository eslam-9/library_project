import 'package:library_project/feature/admin/model/borrowing_request_model.dart';

sealed class AdminBorrowingRequestsState {}

class AdminBorrowingRequestsInitial extends AdminBorrowingRequestsState {}

class AdminBorrowingRequestsLoading extends AdminBorrowingRequestsState {}

class AdminBorrowingRequestsLoaded extends AdminBorrowingRequestsState {
  final List<BorrowingRequest> requests;

  AdminBorrowingRequestsLoaded(this.requests);
}

class AdminBorrowingRequestsError extends AdminBorrowingRequestsState {
  final String message;

  AdminBorrowingRequestsError(this.message);
}
