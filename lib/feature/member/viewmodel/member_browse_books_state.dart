import 'package:library_project/feature/member/model/available_book_model.dart';

sealed class MemberBrowseBooksState {}

class MemberBrowseBooksInitial extends MemberBrowseBooksState {}

class MemberBrowseBooksLoading extends MemberBrowseBooksState {}

class MemberBrowseBooksLoaded extends MemberBrowseBooksState {
  final List<AvailableBook> allBooks;
  final List<AvailableBook> filteredBooks;
  final String searchQuery;
  final int? memberId;

  MemberBrowseBooksLoaded({
    required this.allBooks,
    required this.filteredBooks,
    this.searchQuery = '',
    this.memberId,
  });

  MemberBrowseBooksLoaded copyWith({
    List<AvailableBook>? allBooks,
    List<AvailableBook>? filteredBooks,
    String? searchQuery,
    int? memberId,
  }) {
    return MemberBrowseBooksLoaded(
      allBooks: allBooks ?? this.allBooks,
      filteredBooks: filteredBooks ?? this.filteredBooks,
      searchQuery: searchQuery ?? this.searchQuery,
      memberId: memberId ?? this.memberId,
    );
  }
}

class MemberBrowseBooksError extends MemberBrowseBooksState {
  final String message;

  MemberBrowseBooksError(this.message);
}
