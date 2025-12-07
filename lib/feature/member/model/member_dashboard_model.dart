class MemberStats {
  final int totalBorrowed;
  final int activeBorrowings;
  final int overdueBorrowings;

  const MemberStats({
    required this.totalBorrowed,
    required this.activeBorrowings,
    required this.overdueBorrowings,
  });

  const MemberStats.empty()
    : totalBorrowed = 0,
      activeBorrowings = 0,
      overdueBorrowings = 0;
}

class MemberBorrowingRecord {
  final int id;
  final String bookTitle;
  final String status;
  final DateTime borrowedAt;
  final DateTime? dueAt;
  final DateTime? returnedAt;

  const MemberBorrowingRecord({
    required this.id,
    required this.bookTitle,
    required this.status,
    required this.borrowedAt,
    this.dueAt,
    this.returnedAt,
  });
}

class MemberDashboardData {
  final MemberStats stats;
  final List<MemberBorrowingRecord> recentBorrowings;

  const MemberDashboardData({
    required this.stats,
    required this.recentBorrowings,
  });

  const MemberDashboardData.empty()
    : stats = const MemberStats.empty(),
      recentBorrowings = const [];
}
