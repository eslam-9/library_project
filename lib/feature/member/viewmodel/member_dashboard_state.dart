import 'package:library_project/feature/member/model/member_dashboard_model.dart';

sealed class MemberDashboardState {}

class MemberDashboardInitial extends MemberDashboardState {}

class MemberDashboardLoading extends MemberDashboardState {}

class MemberDashboardLoaded extends MemberDashboardState {
  final MemberDashboardData data;

  MemberDashboardLoaded(this.data);
}

class MemberDashboardError extends MemberDashboardState {
  final String message;

  MemberDashboardError(this.message);
}
