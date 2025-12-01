import 'package:library_project/feature/admin/model/admin_dashboard_model.dart';

sealed class AdminDashboardState {}

class AdminDashboardInitial extends AdminDashboardState {}

class AdminDashboardLoading extends AdminDashboardState {}

class AdminDashboardLoaded extends AdminDashboardState {
  final AdminDashboardData data;

  AdminDashboardLoaded(this.data);
}

class AdminDashboardError extends AdminDashboardState {
  final String message;

  AdminDashboardError(this.message);
}

