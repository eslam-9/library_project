sealed class AdminCategoryBooksState {}

class AdminCategoryBooksInitial extends AdminCategoryBooksState {}

class AdminCategoryBooksLoading extends AdminCategoryBooksState {}

class AdminCategoryBooksLoaded extends AdminCategoryBooksState {
  final List<Map<String, dynamic>> books;
  final int categoryId;
  final String categoryName;

  AdminCategoryBooksLoaded({
    required this.books,
    required this.categoryId,
    required this.categoryName,
  });
}

class AdminCategoryBooksError extends AdminCategoryBooksState {
  final String message;

  AdminCategoryBooksError(this.message);
}
