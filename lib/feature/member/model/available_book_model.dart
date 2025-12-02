class AvailableBook {
  final int id;
  final String title;
  final String? author;
  final String? description;
  final String? categoryName;
  final double dailyPrice;
  final int availableCopies;

  AvailableBook({
    required this.id,
    required this.title,
    this.author,
    this.description,
    this.categoryName,
    required this.dailyPrice,
    required this.availableCopies,
  });
}
