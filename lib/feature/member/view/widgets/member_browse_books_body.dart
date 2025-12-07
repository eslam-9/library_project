import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:library_project/feature/member/model/available_book_model.dart';
import 'package:library_project/feature/member/viewmodel/member_browse_books_notifier.dart';
import 'package:library_project/feature/member/viewmodel/member_browse_books_state.dart';
import 'package:library_project/feature/member/view/widgets/borrow_request_dialog.dart';

class MemberBrowseBooksBody extends ConsumerWidget {
  final TextEditingController searchController;

  const MemberBrowseBooksBody({super.key, required this.searchController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(memberBrowseBooksProvider);

    return Column(
      children: [
        // Search Bar
        if (state is MemberBrowseBooksLoaded)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search books by name...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF231480)),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: const BorderSide(
                    color: Color(0xFF231480),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        // Books List
        Expanded(child: _buildBody(context, ref, state)),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    MemberBrowseBooksState state,
  ) {
    if (state is MemberBrowseBooksLoading ||
        state is MemberBrowseBooksInitial) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF231480)),
        ),
      );
    } else if (state is MemberBrowseBooksError) {
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
                  ref.read(memberBrowseBooksProvider.notifier).refreshBooks();
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
    } else if (state is MemberBrowseBooksLoaded) {
      if (state.filteredBooks.isEmpty) {
        return Center(
          child: Text(
            searchController.text.isEmpty
                ? 'No books available'
                : 'No books found matching "${searchController.text}"',
            style: TextStyle(
              fontSize: 18.sp,
              color: const Color(0xFF231480).withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          await ref.read(memberBrowseBooksProvider.notifier).refreshBooks();
        },
        child: ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: state.filteredBooks.length,
          itemBuilder: (context, index) {
            final book = state.filteredBooks[index];
            return _buildBookCard(context, ref, book);
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildBookCard(
    BuildContext context,
    WidgetRef ref,
    AvailableBook book,
  ) {
    final hasAvailableCopies = book.availableCopies > 0;

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
                      book.title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF231480),
                      ),
                    ),
                    if (book.author != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        'by ${book.author}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    if (book.categoryName != null) ...[
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF231480).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          book.categoryName!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF231480),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (book.description != null) ...[
            SizedBox(height: 12.h),
            Text(
              book.description!,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
              maxLines: 2,
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
                    '\$${book.dailyPrice.toStringAsFixed(2)}/day',
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
                    'Available Copies',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                  Text(
                    '${book.availableCopies}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: hasAvailableCopies
                          ? const Color(0xFF231480)
                          : Colors.red,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: hasAvailableCopies
                    ? () => _showBorrowDialog(context, ref, book)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF231480),
                  foregroundColor: Colors.white,
                  minimumSize: Size(50.w, 58.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                ),
                child: const Text('Borrow'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showBorrowDialog(
    BuildContext context,
    WidgetRef ref,
    AvailableBook book,
  ) async {
    final notifier = ref.read(memberBrowseBooksProvider.notifier);

    // Check if already borrowed
    final alreadyBorrowed = await notifier.checkIfAlreadyBorrowed(book.id);

    if (alreadyBorrowed) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'You already have a pending or active borrowing for this book',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (context) => BorrowRequestDialog(
          book: book,
          onSubmit: (days, dailyPrice) async {
            await notifier.requestBorrowing(
              bookId: book.id,
              days: days,
              dailyPrice: dailyPrice,
            );
          },
        ),
      );
    }
  }
}
