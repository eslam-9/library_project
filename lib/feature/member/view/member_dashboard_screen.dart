import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:library_project/feature/authentication/viewmodel/auth_notifier.dart';
import 'package:library_project/feature/authentication/viewmodel/auth_state.dart';
import 'package:library_project/feature/member/model/member_dashboard_model.dart';
import 'package:library_project/feature/member/view/member_books_screen.dart';
import 'package:library_project/feature/member/view/widgets/member_borrowing_tile.dart';
import 'package:library_project/feature/member/view/widgets/member_stat_card.dart';
import 'package:library_project/feature/member/viewmodel/member_dashboard_notifier.dart';
import 'package:library_project/feature/member/viewmodel/member_dashboard_state.dart';

class MemberDashboardScreen extends ConsumerWidget {
  const MemberDashboardScreen({super.key});
  static const String routeName = '/memberDashboard';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(memberDashboardProvider);
    final notifier = ref.read(memberDashboardProvider.notifier);
    final authState = ref.watch(authNotifierProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);

    String userName = 'Member';
    if (authState is AuthenticationLoaded) {
      userName = authState.user.name;
    }

    Widget body;

    if (state is MemberDashboardLoading || state is MemberDashboardInitial) {
      body = const _MemberLoadingState();
    } else if (state is MemberDashboardError) {
      body = _MemberErrorState(
        message: state.message,
        onRetry: notifier.refreshDashboard,
      );
    } else if (state is MemberDashboardLoaded) {
      body = RefreshIndicator(
        color: const Color(0xFF231480),
        onRefresh: notifier.refreshDashboard,
        child: _MemberDashboardBody(data: state.data, userName: userName),
      );
    } else {
      body = const _MemberLoadingState();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFDCDBFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDCDBFD),
        elevation: 0,
        title: Text(
          'My Library',
          style: TextStyle(
            color: const Color(0xFF231480),
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.of(
                context,
              ).pushNamed(MemberBooksScreen.routeName);
              await notifier.refreshDashboard();
            },
            icon: const Icon(
              Icons.menu_book_outlined,
              color: Color(0xFF231480),
            ),
            tooltip: 'Browse books',
          ),
          IconButton(
            onPressed: () async {
              await authNotifier.signOut();
            },
            icon: const Icon(Icons.logout, color: Color(0xFF231480)),
            tooltip: 'Sign out',
          ),
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

class _MemberDashboardBody extends StatelessWidget {
  final MemberDashboardData data;
  final String userName;

  const _MemberDashboardBody({required this.data, required this.userName});

  @override
  Widget build(BuildContext context) {
    final stats = [
      (
        'Total Borrowed',
        data.stats.totalBorrowed.toString(),
        Icons.menu_book_outlined,
        const Color(0xFF231480),
      ),
      (
        'Currently Borrowed',
        data.stats.activeBorrowings.toString(),
        Icons.assignment_outlined,
        const Color(0xFF8E2DE2),
      ),
      (
        'Overdue',
        data.stats.overdueBorrowings.toString(),
        Icons.warning_amber_outlined,
        const Color(0xFFFF6B6B),
      ),
    ];

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      children: [
        Text(
          'Hi, $userName 👋',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF231480),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Here is an overview of your reading activity.',
          style: TextStyle(fontSize: 16.sp, color: const Color(0xFF6F6F6F)),
        ),
        SizedBox(height: 24.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16.h,
            crossAxisSpacing: 8.w,
            childAspectRatio: 1,
          ),
          itemCount: stats.length,
          itemBuilder: (_, index) {
            final stat = stats[index];
            return MemberStatCard(
              title: stat.$1,
              value: stat.$2,
              icon: stat.$3,
              backgroundColor: stat.$4,
            );
          },
        ),
        SizedBox(height: 32.h),
        const _MemberSectionHeader(
          title: 'Your Recent Borrowings',
          subtitle: 'Books you have borrowed recently',
        ),
        SizedBox(height: 16.h),
        if (data.recentBorrowings.isEmpty)
          const _MemberEmptySection(
            message: 'You have not borrowed any books yet.',
          )
        else
          ...data.recentBorrowings.map(
            (record) => MemberBorrowingTile(record: record),
          ),
        SizedBox(height: 32.h),
      ],
    );
  }
}

class _MemberSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _MemberSectionHeader({required this.title, required this.subtitle});

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
          style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6F6F6F)),
        ),
      ],
    );
  }
}

class _MemberLoadingState extends StatelessWidget {
  const _MemberLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF231480)),
    );
  }
}

class _MemberErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _MemberErrorState({required this.message, required this.onRetry});

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

class _MemberEmptySection extends StatelessWidget {
  final String message;

  const _MemberEmptySection({required this.message});

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
        style: TextStyle(fontSize: 14.sp, color: const Color(0xFF989898)),
      ),
    );
  }
}
