class MemberBook {
  final int id;
  final String title;
  final String? author;
  final String? description;
  final int availableCopies;
  final double dailyPrice;

  const MemberBook({
    required this.id,
    required this.title,
    this.author,
    this.description,
    required this.availableCopies,
    required this.dailyPrice,
  });
}
