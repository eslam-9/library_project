import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_project/feature/member/viewmodel/member_browse_books_state.dart';
import 'package:library_project/service/member_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MemberBrowseBooksNotifier extends StateNotifier<MemberBrowseBooksState> {
  MemberBrowseBooksNotifier() : super(MemberBrowseBooksInitial()) {
    loadBooks();
  }

  Future<void> loadBooks() async {
    state = MemberBrowseBooksLoading();
    try {
      // Get member ID
      final user = Supabase.instance.client.auth.currentUser;
      int? memberId;
      if (user != null) {
        memberId = await MemberService.getMemberIdByProfileId(user.id);
      }

      // Fetch available books
      final books = await MemberService.fetchAvailableBooks();

      state = MemberBrowseBooksLoaded(
        allBooks: books,
        filteredBooks: books,
        searchQuery: '',
        memberId: memberId,
      );
    } catch (error) {
      state = MemberBrowseBooksError(_mapError(error));
    }
  }

  void searchBooks(String query) {
    final currentState = state;
    if (currentState is MemberBrowseBooksLoaded) {
      final lowerQuery = query.toLowerCase();
      final filtered = lowerQuery.isEmpty
          ? currentState.allBooks
          : currentState.allBooks.where((book) {
              return book.title.toLowerCase().contains(lowerQuery);
            }).toList();

      state = currentState.copyWith(
        filteredBooks: filtered,
        searchQuery: query,
      );
    }
  }

  Future<bool> checkIfAlreadyBorrowed(int bookId) async {
    final currentState = state;
    if (currentState is MemberBrowseBooksLoaded &&
        currentState.memberId != null) {
      try {
        return await MemberService.checkIfAlreadyBorrowed(
          currentState.memberId!,
          bookId,
        );
      } catch (error) {
        return false;
      }
    }
    return false;
  }

  Future<void> requestBorrowing({
    required int bookId,
    required int days,
    required double dailyPrice,
  }) async {
    final currentState = state;
    if (currentState is MemberBrowseBooksLoaded &&
        currentState.memberId != null) {
      try {
        await MemberService.requestBorrowing(
          memberId: currentState.memberId!,
          bookId: bookId,
          days: days,
          dailyPrice: dailyPrice,
        );
        // Reload books after successful request
        await loadBooks();
      } catch (error) {
        rethrow;
      }
    } else {
      throw Exception('Member ID not found');
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

final memberBrowseBooksProvider =
    StateNotifierProvider<MemberBrowseBooksNotifier, MemberBrowseBooksState>(
      (ref) => MemberBrowseBooksNotifier(),
    );
