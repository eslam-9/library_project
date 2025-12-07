class AdminStats {
  final int totalMembers;
  final int totalBooks;
  final int totalCategories;
  final int totalCopies;
  final int activeBorrowings;
  final int availableCopies;

  const AdminStats({
    required this.totalMembers,
    required this.totalBooks,
    required this.totalCategories,
    required this.totalCopies,
    required this.activeBorrowings,
    required this.availableCopies,
  });

  const AdminStats.empty()
    : totalMembers = 0,
      totalBooks = 0,
      totalCategories = 0,
      totalCopies = 0,
      activeBorrowings = 0,
      availableCopies = 0;
}

class CategorySummary {
  final int id;
  final String name;
  final String? description;
  final DateTime createdAt;

  const CategorySummary({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });
}

class BorrowingRecord {
  final int id;
  final String memberLabel;
  final String bookTitle;
  final String status;
  final DateTime borrowedAt;
  final DateTime? dueAt;
  final DateTime? returnedAt;

  const BorrowingRecord({
    required this.id,
    required this.memberLabel,
    required this.bookTitle,
    required this.status,
    required this.borrowedAt,
    this.dueAt,
    this.returnedAt,
  });
}

class AdminDashboardData {
  final AdminStats stats;
  final List<CategorySummary> categories;
  final List<BorrowingRecord> recentBorrowings;

  const AdminDashboardData({
    required this.stats,
    required this.categories,
    required this.recentBorrowings,
  });

  const AdminDashboardData.empty()
    : stats = const AdminStats.empty(),
      categories = const [],
      recentBorrowings = const [];
}
