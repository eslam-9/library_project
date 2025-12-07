import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:library_project/feature/admin/view/widgets/admin_borrowing_requests_body.dart';

class AdminBorrowingRequestsScreen extends ConsumerWidget {
  const AdminBorrowingRequestsScreen({super.key});
  static const String routeName = '/adminBorrowingRequests';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCDBFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDCDBFD),
        elevation: 0,
        title: Text(
          'Borrowing Requests',
          style: TextStyle(
            color: const Color(0xFF231480),
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const AdminBorrowingRequestsBody(),
    );
  }
}
