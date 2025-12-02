import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:library_project/feature/member/model/available_book_model.dart';
import 'package:library_project/service/member_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MemberBrowseBooksScreen extends StatefulWidget {
  const MemberBrowseBooksScreen({super.key});
  static const String routeName = '/memberBrowseBooks';

  @override
  State<MemberBrowseBooksScreen> createState() =>
      _MemberBrowseBooksScreenState();
}

class _MemberBrowseBooksScreenState extends State<MemberBrowseBooksScreen> {
  List<AvailableBook> _books = [];
  bool _isLoading = true;
  int? _memberId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        _memberId = await MemberService.getMemberIdByProfileId(user.id);
      }

      final books = await MemberService.fetchAvailableBooks();
      setState(() {
        _books = books;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load books'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showBorrowDialog(AvailableBook book) async {
    if (_memberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Member ID not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if already borrowed
    final alreadyBorrowed = await MemberService.checkIfAlreadyBorrowed(
      _memberId!,
      book.id,
    );

    if (alreadyBorrowed) {
      if (mounted) {
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

    if (mounted) {
      await showDialog(
        context: context,
        builder: (context) => _BorrowRequestDialog(
          book: book,
          memberId: _memberId!,
          onSuccess: () {
            _loadData();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCDBFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDCDBFD),
        elevation: 0,
        title: Text(
          'Browse Books',
          style: TextStyle(
            color: const Color(0xFF231480),
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF231480)),
              ),
            )
          : _books.isEmpty
          ? Center(
              child: Text(
                'No books available',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: const Color(0xFF231480).withOpacity(0.6),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: _books.length,
                itemBuilder: (context, index) {
                  final book = _books[index];
                  return _buildBookCard(book);
                },
              ),
            ),
    );
  }

  Widget _buildBookCard(AvailableBook book) {
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
                    ? () => _showBorrowDialog(book)
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
}

class _BorrowRequestDialog extends StatefulWidget {
  final AvailableBook book;
  final int memberId;
  final VoidCallback onSuccess;

  const _BorrowRequestDialog({
    required this.book,
    required this.memberId,
    required this.onSuccess,
  });

  @override
  State<_BorrowRequestDialog> createState() => _BorrowRequestDialogState();
}

class _BorrowRequestDialogState extends State<_BorrowRequestDialog> {
  int _days = 7;
  bool _isSubmitting = false;

  double get _totalCost => widget.book.dailyPrice * _days;

  Future<void> _submitRequest() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      await MemberService.requestBorrowing(
        memberId: widget.memberId,
        bookId: widget.book.id,
        days: _days,
        dailyPrice: widget.book.dailyPrice,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Borrowing request submitted successfully'),
            backgroundColor: Color(0xFF231480),
          ),
        );
        widget.onSuccess();
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit request: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: Text(
        'Borrow Book',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF231480),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.book.title,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Text(
            'Daily Price: \$${widget.book.dailyPrice.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 24.h),
          Text(
            'Number of Days',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _days.toDouble(),
                  min: 1,
                  max: 15,
                  divisions: 14,
                  label: '$_days days',
                  activeColor: const Color(0xFF231480),
                  onChanged: (value) {
                    setState(() {
                      _days = value.toInt();
                    });
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '$_days',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF231480),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Cost:',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '\$${_totalCost.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitRequest,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF231480),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: _isSubmitting
              ? SizedBox(
                  height: 20.h,
                  width: 20.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Request Borrow'),
        ),
      ],
    );
  }
}
