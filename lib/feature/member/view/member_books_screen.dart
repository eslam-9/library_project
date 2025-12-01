import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:library_project/feature/member/model/member_books_model.dart';
import 'package:library_project/feature/member/viewmodel/member_dashboard_notifier.dart';
import 'package:library_project/service/member_service.dart';

final memberBooksProvider = FutureProvider<List<MemberBook>>((ref) async {
  return MemberService.fetchAllBooks();
});

class MemberBooksScreen extends ConsumerWidget {
  const MemberBooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(memberBooksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFDCDBFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDCDBFD),
        elevation: 0,
        title: Text(
          'All Books',
          style: TextStyle(
            color: const Color(0xFF231480),
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(memberBooksProvider);
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
          error: (error, _) => _BooksError(message: 'Failed to load books.'),
          data: (books) {
            if (books.isEmpty) {
              return const _BooksEmpty();
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              itemCount: books.length,
              itemBuilder: (_, index) {
                final book = books[index];
                return _BookTile(book: book, ref: ref);
              },
            );
          },
        ),
      ),
    );
  }
}

class _BookTile extends StatelessWidget {
  final MemberBook book;
  final WidgetRef ref;

  const _BookTile({required this.book, required this.ref});

  @override
  Widget build(BuildContext context) {
    final available = book.availableCopies;

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
                  book.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF231480),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCDBFD),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Available: $available',
                  style: TextStyle(
                    color: const Color(0xFF231480),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (book.author != null && book.author!.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              book.author!,
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6F6F6F)),
            ),
          ],
          if (book.description != null && book.description!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              book.description!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF989898)),
            ),
          ],
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: available == 0
                  ? null
                  : () async {
                      try {
                        await MemberService.borrowBook(book.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Book borrowed successfully'),
                              backgroundColor: Color(0xFF231480),
                            ),
                          );
                        }
                        ref.invalidate(memberBooksProvider);
                        await ref
                            .read(memberDashboardProvider.notifier)
                            .refreshDashboard();
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Failed to borrow book. Please try again.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF231480),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Text(
                'Borrow',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BooksEmpty extends StatelessWidget {
  const _BooksEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Text(
          'No books found in the library.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.sp, color: const Color(0xFF989898)),
        ),
      ),
    );
  }
}

class _BooksError extends StatelessWidget {
  final String message;

  const _BooksError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.sp, color: const Color(0xFF989898)),
        ),
      ),
    );
  }
}
