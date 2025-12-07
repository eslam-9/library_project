import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:library_project/feature/admin/view/widgets/admin_category_books_body.dart';
import 'package:library_project/feature/admin/viewmodel/admin_category_books_notifier.dart';

class AdminCategoryBooksScreen extends ConsumerWidget {
  final int categoryId;
  final String categoryName;
  final String? categoryDescription;

  const AdminCategoryBooksScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.categoryDescription,
  });

  static const String routeName = '/adminCategoryBooks';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCDBFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDCDBFD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF231480)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              categoryName,
              style: TextStyle(
                color: const Color(0xFF231480),
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Category Books',
              style: TextStyle(
                color: const Color(0xFF231480).withOpacity(0.6),
                fontSize: 12.sp,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              ref
                  .read(adminCategoryBooksProvider(categoryId).notifier)
                  .refreshBooks();
            },
            icon: const Icon(Icons.refresh_outlined, color: Color(0xFF231480)),
            tooltip: 'Reload',
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: AdminCategoryBooksBody(
        categoryId: categoryId,
        categoryDescription: categoryDescription,
      ),
    );
  }
}
