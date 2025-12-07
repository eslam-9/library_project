import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:library_project/feature/admin/viewmodel/admin_category_books_notifier.dart';
import 'package:library_project/feature/admin/viewmodel/admin_category_books_state.dart';

class AdminCategoryBooksBody extends ConsumerWidget {
  final int categoryId;
  final String? categoryDescription;

  const AdminCategoryBooksBody({
    super.key,
    required this.categoryId,
    this.categoryDescription,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminCategoryBooksProvider(categoryId));

    return Column(
      children: [
        if (categoryDescription != null && categoryDescription!.isNotEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            color: Colors.white.withOpacity(0.7),
            child: Text(
              categoryDescription!,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF231480).withOpacity(0.8),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        Expanded(child: _buildBody(context, ref, state)),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AdminCategoryBooksState state,
  ) {
    if (state is AdminCategoryBooksLoading ||
        state is AdminCategoryBooksInitial) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF231480)),
        ),
      );
    } else if (state is AdminCategoryBooksError) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48.w, color: Colors.red),
              SizedBox(height: 16.h),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: const Color(0xFF231480),
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(adminCategoryBooksProvider(categoryId).notifier)
                      .refreshBooks();
                },
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
    } else if (state is AdminCategoryBooksLoaded) {
      if (state.books.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.menu_book_outlined,
                size: 64.w,
                color: const Color(0xFF231480).withOpacity(0.3),
              ),
              SizedBox(height: 16.h),
              Text(
                'No books in this category',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: const Color(0xFF231480).withOpacity(0.6),
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(adminCategoryBooksProvider(categoryId).notifier)
              .refreshBooks();
        },
        child: ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: state.books.length,
          itemBuilder: (context, index) {
            final book = state.books[index];
            return _buildBookCard(book);
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildBookCard(Map<String, dynamic> book) {
    final title = book['title'] as String? ?? 'Unknown Title';
    final author = book['author'] as String?;
    final description = book['description'] as String?;
    final dailyPrice = (book['daily_price'] as num?)?.toDouble() ?? 0.0;
    final totalCopies = book['total_copies'] as int? ?? 0;
    final availableCopies = book['available_copies'] as int? ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF231480),
                      ),
                    ),
                    if (author != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        'by $author',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (description != null && description.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              description,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          SizedBox(height: 12.h),
          Divider(color: Colors.grey[300]),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Price',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                  Text(
                    '\$${dailyPrice.toStringAsFixed(2)}/day',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Copies',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                  Text(
                    '$totalCopies',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF231480),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                  Text(
                    '$availableCopies',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: availableCopies > 0
                          ? Colors.green[700]
                          : Colors.red[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
