import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:library_project/feature/admin/model/admin_dashboard_model.dart';
import 'package:library_project/feature/admin/view/widgets/admin_stat_card.dart';
import 'package:library_project/feature/admin/view/widgets/borrowing_tile.dart';
import 'package:library_project/feature/admin/viewmodel/admin_dashboard_notifier.dart';
import 'package:library_project/feature/admin/viewmodel/admin_dashboard_state.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminDashboardProvider);
    final notifier = ref.read(adminDashboardProvider.notifier);

    Widget body;

    if (state is AdminDashboardLoading || state is AdminDashboardInitial) {
      body = const _LoadingState();
    } else if (state is AdminDashboardError) {
      body = _ErrorState(
        message: state.message,
        onRetry: notifier.refreshDashboard,
      );
    } else if (state is AdminDashboardLoaded) {
      body = RefreshIndicator(
        color: const Color(0xFF231480),
        onRefresh: notifier.refreshDashboard,
        child: _DashboardBody(data: state.data),
      );
    } else {
      body = const _LoadingState();
    }

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
            onPressed: notifier.refreshDashboard,
            icon: const Icon(Icons.refresh_outlined, color: Color(0xFF231480)),
            tooltip: 'Reload',
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(child: body),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final AdminDashboardData data;

  const _DashboardBody({required this.data});

  @override
  Widget build(BuildContext context) {
    final stats = [
      (
        'Members',
        data.stats.totalMembers.toString(),
        Icons.people_alt_outlined,
        const Color(0xFF231480)
      ),
      (
        'Books',
        data.stats.totalBooks.toString(),
        Icons.menu_book_outlined,
        const Color(0xFF8E2DE2)
      ),
      (
        'Copies',
        data.stats.totalCopies.toString(),
        Icons.inventory_2_outlined,
        const Color(0xFF4A00E0)
      ),
      (
        'Categories',
        data.stats.totalCategories.toString(),
        Icons.category_outlined,
        const Color(0xFF6C2BD9)
      ),
      (
        'Borrowed',
        data.stats.activeBorrowings.toString(),
        Icons.assignment_outlined,
        const Color(0xFFF7971E)
      ),
      (
        'Available Copies',
        data.stats.availableCopies.toString(),
        Icons.check_circle_outline,
        const Color(0xFF30C48D)
      ),
    ];

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      children: [
        Text(
          'Good day, Admin 👋',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF231480),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Here’s a quick overview of what’s happening in your library.',
          style: TextStyle(
            fontSize: 16.sp,
            color: const Color(0xFF6F6F6F),
          ),
        ),
        SizedBox(height: 24.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16.h,
            crossAxisSpacing: 16.w,
            childAspectRatio: 1.25,
          ),
          itemCount: stats.length,
          itemBuilder: (_, index) {
            final stat = stats[index];
            return AdminStatCard(
              title: stat.$1,
              value: stat.$2,
              icon: stat.$3,
              backgroundColor: stat.$4,
            );
          },
        ),
        SizedBox(height: 32.h),
        _SectionHeader(
          title: 'Recent Borrowings',
          subtitle: 'Latest activity from members',
        ),
        SizedBox(height: 16.h),
        if (data.recentBorrowings.isEmpty)
          const _EmptySection(message: 'No borrowings logged yet.')
        else
          ...data.recentBorrowings
              .map((record) => BorrowingTile(record: record)),
        SizedBox(height: 24.h),
        _SectionHeader(
          title: 'Categories',
          subtitle: 'Keep an eye on knowledge areas',
        ),
        SizedBox(height: 16.h),
        if (data.categories.isEmpty)
          const _EmptySection(message: 'No categories found.')
        else
          Column(
            children: data.categories
                .map(
                  (category) => Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    margin: EdgeInsets.only(bottom: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8.r,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.folder_open, color: const Color(0xFF231480)),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.name,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF231480),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Created ${_formatDate(category.createdAt)}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF989898),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Color(0xFF989898)),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        SizedBox(height: 32.h),
      ],
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF231480),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF6F6F6F),
          ),
        ),
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF231480),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 42.w, color: Colors.redAccent),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF231480),
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF231480),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String message;

  const _EmptySection({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 22.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14.sp,
          color: const Color(0xFF989898),
        ),
      ),
    );
  }
}

