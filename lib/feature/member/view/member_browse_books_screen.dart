import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:library_project/feature/member/viewmodel/member_browse_books_notifier.dart';
import 'package:library_project/feature/member/view/widgets/member_browse_books_body.dart';

class MemberBrowseBooksScreen extends ConsumerStatefulWidget {
  const MemberBrowseBooksScreen({super.key});
  static const String routeName = '/memberBrowseBooks';

  @override
  ConsumerState<MemberBrowseBooksScreen> createState() =>
      _MemberBrowseBooksScreenState();
}

class _MemberBrowseBooksScreenState
    extends ConsumerState<MemberBrowseBooksScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref
        .read(memberBrowseBooksProvider.notifier)
        .searchBooks(_searchController.text);
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
      body: MemberBrowseBooksBody(searchController: _searchController),
    );
  }
}
