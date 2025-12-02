import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:library_project/service/admin_service.dart';

final adminBooksProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  return AdminService.fetchAllBooks();
});

class AdminBooksScreen extends ConsumerWidget {
  const AdminBooksScreen({super.key});
  static const String routeName = '/adminBooks';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(adminBooksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFDCDBFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDCDBFD),
        elevation: 0,
        title: Text(
          'Manage Books',
          style: TextStyle(
            color: const Color(0xFF231480),
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(adminBooksProvider);
            },
            icon: const Icon(Icons.refresh_outlined, color: Color(0xFF231480)),
            tooltip: 'Reload',
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: booksAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF231480)),
          ),
          error: (error, _) => Center(
            child: Text(
              'Failed to load books.',
              style: TextStyle(fontSize: 16.sp, color: const Color(0xFF989898)),
            ),
          ),
          data: (books) {
            if (books.isEmpty) {
              return Center(
                child: Text(
                  'No books found.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF989898),
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              itemCount: books.length,
              itemBuilder: (_, index) {
                final book = books[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10.r,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              book['title'] ?? 'Untitled',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF231480),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCDBFD),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              'Available: ${book['available_copies']}',
                              style: TextStyle(
                                color: const Color(0xFF231480),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (book['author'] != null) ...[
                        SizedBox(height: 6.h),
                        Text(
                          book['author'],
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF6F6F6F),
                          ),
                        ),
                      ],
                      if (book['description'] != null) ...[
                        SizedBox(height: 8.h),
                        Text(
                          book['description'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: const Color(0xFF989898),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
