import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_project/feature/admin/viewmodel/admin_category_books_state.dart';
import 'package:library_project/service/admin_service.dart';
import 'package:postgrest/postgrest.dart';

class AdminCategoryBooksNotifier
    extends StateNotifier<AdminCategoryBooksState> {
  final int categoryId;

  AdminCategoryBooksNotifier({required this.categoryId})
    : super(AdminCategoryBooksInitial()) {
    loadBooks();
  }

  Future<void> loadBooks() async {
    state = AdminCategoryBooksLoading();
    try {
      final books = await AdminService.fetchBooksByCategory(categoryId);
      state = AdminCategoryBooksLoaded(
        books: books,
        categoryId: categoryId,
        categoryName: '', // Will be set from screen
      );
    } catch (error) {
      state = AdminCategoryBooksError(_mapError(error));
    }
  }

  Future<void> refreshBooks() async {
    await loadBooks();
  }

  String _mapError(Object error) {
    if (error is PostgrestException) {
      return error.message;
    }
    return 'Failed to load books. Please try again.';
  }
}

// Simplified provider using just categoryId as the parameter
final adminCategoryBooksProvider =
    StateNotifierProvider.family<
      AdminCategoryBooksNotifier,
      AdminCategoryBooksState,
      int
    >((ref, categoryId) => AdminCategoryBooksNotifier(categoryId: categoryId));
