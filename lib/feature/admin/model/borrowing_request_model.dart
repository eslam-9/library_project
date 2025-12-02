class BorrowingRequest {
  final int id;
  final String memberName;
  final String memberEmail;
  final String bookTitle;
  final int daysRequested;
  final double totalCost;
  final DateTime requestedAt;
  final int copyId;

  BorrowingRequest({
    required this.id,
    required this.memberName,
    required this.memberEmail,
    required this.bookTitle,
    required this.daysRequested,
    required this.totalCost,
    required this.requestedAt,
    required this.copyId,
  });
}
