import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:library_project/feature/admin/view/widgets/admin_dashboard_body.dart';
import 'package:library_project/feature/admin/viewmodel/admin_dashboard_notifier.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});
  static const String routeName = '/adminDashboard';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCDBFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDCDBFD),
        elevation: 0,
        title: Text(
          'Admin Dashboard',
          style: TextStyle(
            color: const Color(0xFF231480),
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(adminDashboardProvider.notifier).refreshDashboard();
            },
            icon: const Icon(Icons.refresh_outlined, color: Color(0xFF231480)),
            tooltip: 'Reload',
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: const SafeArea(child: AdminDashboardBody()),
    );
  }
}
