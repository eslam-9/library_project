class MemberBook {
  final int id;
  final String title;
  final String? author;
  final String? description;
  final int availableCopies;

  const MemberBook({
    required this.id,
    required this.title,
    this.author,
    this.description,
    required this.availableCopies,
  });
}
